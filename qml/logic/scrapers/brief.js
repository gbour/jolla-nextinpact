/*
    Copyright 2019 Guillaume Bour.
    This file is part of «NextINpact app».

    «NextINpact app» is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    any later version.

    «NextINpact app» is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with «NextINpact app».  If not, see <http://www.gnu.org/licenses/>.
*/
.pragma library

/*
   NOTE: WorkerScripts does not support .include keyword to import js libraries,
         we need to use Qt.include() instead.
         /!\ this last one imports all functions into the current namespace
*/
Qt.include('../../lib/htmlparser2.js')
Qt.include('../../lib/iso8859-15.js')
Qt.include('../../lib/utils.js')

var STATE_ARTICLE    = 1
var STATE_TITLE      = 2
var STATE_CONTENT    = 3
var STATE_NBCOMMENTS = 4

var states = ['',
    /* STATE_ARTICLE    */ 'article',
    /* STATE_TITLE      */ 'h2',
    /* STATE_CONTENT    */ 'div',
    /* STATE_NBCOMMENTS */ 'span'
];


function Brief() {
}

Brief.prototype = {
    fetch: function(uri, callback) {
        //console.debug('Brief.fetch', uri);
        var http = new XMLHttpRequest();
        http.open("GET", uri, true);

        var self = this;
        http.onreadystatechange = function() {
            if (http.readyState === XMLHttpRequest.DONE && http.status === 200) {
               //console.log(http.responseText)

                var briefs = self.scrap(http.responseText);
                //console.log(dump(briefs));
                callback(briefs);
            }
        }

        http.send();
    },

    scrap: function (m) {
        var articles = []
        var article  = null
        var parent   = {tag: null, attrs:[]}
        var state    = [0]

        var content_inc = 0;
        var position    = 0;
        // `spacer` is here to re-introduce missing space before or after a link (<a> tag)
        var spacer      = false;

        HTMLParser(m, {
            start: function (tag, attrs, unary) {
                //console.log(tag)

                try {
                    if (state[0] === 0) {
                        //console.log('tag', tag);

                        if (tag === 'article' && attrs.class.value === 'brief-item') {
                            //console.log('brief article');
                            state.unshift(STATE_ARTICLE);

                            article = {
                                'title'   : '',
                                'content' : '',
                                'comments': 0,
                                'position': position += 1,
                            }
                        }
                    } else if(state[0] === STATE_ARTICLE) {
                        if(tag === 'h2') {
                            state.unshift(STATE_TITLE);
                        } else if(attrs.class.value === 'brief-content') {
                            state.unshift(STATE_CONTENT);
                            content_inc = 0
                        } else if(tag === 'span' && attrs.class.value === 'nb_comments') {
                            state.unshift(STATE_NBCOMMENTS);
                        }

                    } else if(state[0] === STATE_TITLE) {
                        article.link = attrs.href.value;
                        // ie: /brief/my-wonderful-article-1234.htm
                        article.id   = article.link.split('.')[0].split('-').pop()
                    } else if(state[0] === STATE_CONTENT) {
                        if (spacer) {
                            article.content += ' '
                            spacer = false
                        }

                        article.content += html2qt(tag, attrs);
                        if (tag === 'div') {
                            content_inc += 1;
                        }
                    }

                } catch(e) {
                    //console.log('e=' + e + '(tag=' + tag + ')')
                    //console.log(dump(attrs))
                }

                parent = {tag: tag, attrs: attrs}
            },

            end: function (tag) {
                //console.log('end='+tag+','+state[0] + ','+states[state[0]]);

                if(state[0] === STATE_CONTENT) {
                    if (tag === 'div') {
                        content_inc -= 1;

                        if (content_inc <= 0) {
                            //console.log('> final', article.content)
                            state.shift(); return
                        }
                    }

                    article.content += '</'+tag+'>';
                }

                if(state[0] === STATE_ARTICLE && tag === states[STATE_ARTICLE]) {
                    articles.push(article);
                }

                if(states[state[0]] === tag) {
                    state.shift()
                }
            },

            chars: function (text) {
                text = text.trim();

                try {
                    if(state[0] === STATE_TITLE) {
                        article.title += iso_map(text);
                    } else if(state[0] === STATE_CONTENT) {
                        var _text = iso_map(text)
                        // no space before dot, comma, dash, closing brace and bracket, quotes
                        if (spacer && _text.length > 0 && ".,-)]'\"".indexOf(_text[0]) < 0) {
                            article.content += ' '
                        }
                        // no space after space, dash, open brace and bracket, quotes
                        spacer = (_text.length > 0 && " -(['\"".indexOf(_text[_text.length-1]) < 0)

                        article.content += _text;
                    } else if(state[0] === STATE_NBCOMMENTS) {
                        article.comments = parseInt(text);
                    }
                } catch (e) {}
            }
        })

        return articles;
    }
}

WorkerScript.onMessage = function (msg) {
    console.log('briefs::workerscript:: msg=', dump(msg));

    var scraper = new Brief();
    scraper.fetch(msg.uri, function(briefs) {
        //console.log(dump(briefs));
        WorkerScript.sendMessage({reply: 'counter', count: briefs.length})

        briefs.forEach(function(brief) {
            //console.log('brief:', brief.title, brief.comments, msg.parent.id);
            brief.type   = 1;

            brief.parent = msg.parent.id;
            ['date','timestamp','icon'].forEach(function(field) { brief[field] = msg.parent[field]; });
            // we use date field milliseconds to reflect Lebrief articles correct order
            // NOTES: articles are displayed more recent first, but we want briefs
            //        to appears in the same way as online, so we "kind of" reverse them.
            brief.date.setMilliseconds(briefs.length +1 -brief.position);

            WorkerScript.sendMessage({reply: 'brief', brief: brief});
        });
    });
}
