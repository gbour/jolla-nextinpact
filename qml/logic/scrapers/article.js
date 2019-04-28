/*
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

var STATE_ARTICLE   = 1
var STATE_TITLE     = 2
var STATE_SUBTITLE  = 3
var STATE_CONTENT   = 4
var STATE_READTIME  = 5
var STATE_DATE      = 6
var STATE_AUTHOR    = 7

var states = ['',
    /* STATE_ARTICLE  */ 'div',
    /* STATE_TITLE    */ 'h1',
    /* STATE_SUBTITLE */ 'span',
    /* STATE_CONTENT  */ 'div',
    /* STATE_READTIME */ 'div',
    /* STATE_DATE     */ 'p',
    /* STATE_AUTHOR   */ 'p'
];


function Article() {
}

Article.prototype = {
    fetch: function(uri, callback) {
        //console.debug('Article.fetch', uri);
        var http = new XMLHttpRequest();
        http.open("GET", uri, true);
        // not possible - http.setRequestHeader("User-Agent", "Jolla/NextINpact 0.1")

        var self = this;
        http.onreadystatechange = function() {
            if (http.readyState === XMLHttpRequest.DONE && http.status === 200) {
               //console.log(http.responseText)

                var content = self.scrap(http.responseText);
                //console.log(dump(content));
                callback(content);
            }
        }

        http.send();
    },

    scrap: function (m) {
        var article  = {}

        var articles = []
        var parent   = {tag: null, attrs:[]}
        var state    = [0]

        var cnt  = 0

        HTMLParser(m, {
            start: function (tag, attrs, unary) {
                try {
                    if (state[0] === 0) {

                        if (tag === 'div' && attrs.class.value === 'content-header') {
                            state.unshift(STATE_ARTICLE);
                            article = {
                                'title': '',
                                'subtitle': '',
                                'date': '',
                                'author': '',
                                'duration':'',
                                'content': ''
                            }
                        } else if (tag === 'div' && attrs.class.value === 'actu_content') {
                            state.unshift(STATE_CONTENT);
                        } else if (tag === 'div' && attrs.class.value === 'read-time') {
                            state.unshift(STATE_READTIME);
                        } else if (tag === 'p' && attrs.itemprop.value === 'dateCreated') {
                            state.unshift(STATE_DATE);
                        } else if (tag === 'p' && attrs.itemprop.value === 'author') {
                            state.unshift(STATE_AUTHOR);
                        }
                    } else if(state[0] === STATE_ARTICLE) {
                        if(tag === 'h1') {
                            state.unshift(STATE_TITLE);
                        } else if(tag === 'span' && attrs.class.value === 'actu-sub') {
                            state.unshift(STATE_SUBTITLE);
                        }
                    } else if(state[0] === STATE_CONTENT) {
                        article.content += html2qt(tag, attrs);
                        if (tag === 'div') {
                            cnt += 1;
                        }

                    }

                } catch(e) {
                    //console.log('e=' + e + '(tag=' + tag + ')')
                    //console.log(dump(attrs))
                }

                parent = {tag: tag, attrs: attrs}
            },

            end: function (tag) {
                if(state[0] === STATE_CONTENT) {
                    if (tag === 'div') {
                        cnt -= 1;

                        if (cnt <= 0) {
                            articles.push(article);
                            state.shift();
                            return
                        }
                    }

                    article.content += '</'+tag+'>';
                }

                if(states[state[0]] === tag) {
                    state.shift()
                }

            },

            chars: function (text) {
                //text = text.trim();

                try {
                    if(state[0] === STATE_TITLE) {
                        article.title = iso_map(text);
                    } else if(state[0] === STATE_SUBTITLE) {
                        article.subtitle = iso_map(text);
                    } else if(state[0] === STATE_CONTENT) {
                        article.content += iso_map(text, false);
                    } else if(state[0] === STATE_READTIME) {
                        article.duration += iso_map(text);
                    } else if(state[0] === STATE_DATE) {
                        article.date += iso_map(text);
                    } else if(state[0] === STATE_AUTHOR) {
                        article.author += iso_map(text);
                    }
                } catch (e) {}
            }
        })

        return article;
    }
}

WorkerScript.onMessage = function (msg) {
    console.log('article::workerscript:: msg=', dump(msg));

    var scraper = new Article();
    scraper.fetch(msg.uri, function(article) {
        WorkerScript.sendMessage({reply: 'article', article: article});
    });
}
