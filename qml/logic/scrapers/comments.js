/*
    Copyright 2020 Guillaume Bour.
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
Qt.include('../../lib/micromarkdown.js')

var STATE_COMMENT = 1
var STATE_AUTHOR  = 2
var STATE_DATE    = 3
var STATE_NUM     = 4
var STATE_CONTENT = 5
var STATE_DELETED = 6

var states = ['',
              /* STATE_COMMENT  */ 'div',
              /* STATE_AUTHOR   */ 'span',
              /* STATE_DATE     */ 'span',
              /* STATE_NUM      */ 'span',
              /* STATE_CONTENT  */ 'div',
              /* STATE_DELETED  */ 'div'
        ];


function Comments() {
}

Comments.prototype = {
    _url: 'https://api-v1.nextinpact.com/api/v1/Commentaire/list?ArticleId=%1&Page=%2',

    fetch: function(newsid, type, page, callback) {
        console.debug('Comments.fetch', this._url.arg(newsid).arg(page), newsid, page);
        var http = new XMLHttpRequest();

        http.open("GET", this._url.arg(newsid).arg(page), true)
        http.setRequestHeader('Content-type', 'application/x-www-form-urlencoded');

        var self = this;
        http.onreadystatechange = function() {
            if (http.readyState === XMLHttpRequest.DONE && http.status === 200) {
                //console.log(http.responseText)

                //NOTE: expect max 10 comments per page (starting at page 1)
                var comments = self.scrap_v7(JSON.parse(http.responseText), (page-1)*10);
                comments.forEach(function (comment) {
                    comment.article = {id: newsid, type: type}
                })
                console.debug('comments::fetch: got', comments.length, ' comments');
                callback(comments);
            }
        }

        http.send();
    },

    scrap_v7: function(data, commentid) {
        var comments = []
        data['results'].forEach(function(r) {
            var comment = {
                'num'    : ++commentid, //r['comment']['commentId'],
                'author' : r['comment']['userName'],
                'date'   : r['comment']['dateCreated'],
                'content': micromarkdown.parse(r['comment']['content']),
            }

            console.log(r['comment']['content'], comment.content)
            comments.push(comment)
        })

        return comments
    },

    scrap: function (m, commentid) {
        //console.log('fetch comments');

        var comments = []
        var comment  = null
        var parent   = {tag: null, attrs:[]}
        var state    = [0]

        var cnt = 0
        var quote_idx = 0;
        // `spacer` is here to re-introduce missing space before or after a link (<a> tag)
        var spacer      = false;

        HTMLParser(m, {
            start: function (tag, attrs, unary) {
                //console.log(tag)

                try {
                    if (state[0] === 0 && 'class' in attrs) {
                        //NOTE; beware of trailing space !!
                        if (attrs.class.value === 'actu_comm ') {
                            state.unshift(STATE_COMMENT);
                            comment = {
                                'num'    : ++commentid,
                                'author' : '',
                                'date'   : '',
                                'content': ''
                            }
                        } else if (attrs.class.value.indexOf('commentaire_supprime') >= 0) {
                            state.unshift(STATE_DELETED);
                            comment = {
                                'num'    : ++commentid,
                                'author' : '',
                                'date'   : '',
                                'content': ''
                            }
                        }
                    } else if(state[0] === STATE_COMMENT && 'class' in attrs) {
                        if(attrs.class.value === "author_name") {
                            state.unshift(STATE_AUTHOR);
                        } else if(attrs.class.value === 'date_comm') {
                            state.unshift(STATE_DATE);
                        } else if(attrs.class.value === 'actu_comm_num') {
                            state.unshift(STATE_NUM);
                        } else if(attrs.class.value === 'actu_comm_content') {
                            state.unshift(STATE_CONTENT);
                            cnt = 1; quote_idx = -1;
                        }
                    } else if(state[0] === STATE_CONTENT) {
                        if (spacer) {
                            comment.content += ' '
                            spacer = false
                        }

                        /*
                            "<a href='http://google.fr' style='text-decoration: none; color: orange; font-weight: bold' >plop</a> baba."
                            "<div style='margin-left: 20px'>flow</div><div style='margin-left: 0px'></div><br> bobo blabla "
                            "<img src='https://cdn3.nextinpact.com/dlx/68747470733A2F2F63646E322E6E657874696E706163742E636F6D2F736D696C6579732F6469782E676966'/><br>"
                            "<em style='color: grey'>popopo</em>"
                            */

                        comment.content += '<'+tag
                        if (tag === 'a') {
                            comment.content += ' href="'+ attrs.href.value +'"'
                            comment.content += ' style="text-decoration: none; color: orange; font-weight: bold"'
                        } else if (tag === 'em') {
                            comment.content += ' style="color: grey"'
                        } else if (tag === 'img') {
                            comment.content += ' src="'+ attrs.src.value+'" width=50'
                        } else if (tag === 'div' && 'class' in attrs && attrs.class.value === 'quote_bloc') {
                            comment.content += ' style="margin-left: 20px"'
                            quote_idx = cnt
                        }

                        // final tag
                        if (tag === 'img') {
                            comment.content += '/'
                        }

                        comment.content += '>'

                        if (tag === 'div') {
                            cnt += 1;
                        }
                    }
                } catch(e) {
                    console.log('e=' + e + '(tag=' + tag + ')')
                    //console.log(dump(attrs))
                }

                parent = {tag: tag, attrs: attrs}
            },

            end: function (tag) {
                //console.log('end='+tag+','+state[0] + ','+states[state[0]]);

                if(state[0] === STATE_CONTENT) {
                    if (tag === 'div') {
                        cnt -= 1;

                        if (cnt <= 0) {
                            comments.push(comment);
                            state.shift()
                            return
                        }
                    }

                    comment.content += '</'+tag+'>';
                    if (tag === 'div' && cnt === quote_idx) {
                        //TODO: add <br/> only if not followed by a <br/> already
                        comment.content += '<div style="margin-left: 0px"></div><br/>'
                    }

                    return
                } else if(state[0] === STATE_DELETED) {
                    comments.push(comment)
                    state.shift()
                    return
                }

                if(states[state[0]] === tag) {
                    state.shift()
                }

            },

            chars: function (text) {
                text = text.trim();

                try {
                    if(state[0] === STATE_AUTHOR) {
                        comment.author = iso_map(text);
                    } else if(state[0] === STATE_DATE) {
                        comment.date = iso_map(text).replace(/\s+/g, ' ');
                    } else if(state[0] === STATE_NUM) {
                        //console.log(text, ",", parseInt(iso_map(text).substring(1)));
                        comment.num = parseInt(iso_map(text).substring(1));
                    } else if(state[0] === STATE_CONTENT) {
                        var _text = iso_map(text, false)
                        // no space before dot, comma, dash, closing brace and bracket, quotes
                        if (spacer && _text.length > 0 && ".,-)]'\"".indexOf(_text[0]) < 0) {
                            comment.content += ' '
                        }
                        // no space after space, dash, open brace and bracket, quotes
                        spacer = (_text.length > 0 && " -(['\"".indexOf(_text[_text.length-1]) < 0)

                        comment.content += _text;
                    } else if(state[0] === STATE_DELETED) {
                        var _text = iso_map(text, false)
                        // no space before dot, comma, dash, closing brace and bracket, quotes
                        if (spacer && _text.length > 0 && ".,-)]'\"".indexOf(_text[0]) < 0) {
                            comment.content += ' '
                        }
                        // no space after space, dash, open brace and bracket, quotes
                        spacer = (_text.length > 0 && " -(['\"".indexOf(_text[_text.length-1]) < 0)

                        comment.content = "<em style=\"color: grey\">" + _text + "</em>";
                    }
                } catch (e) {
                    console.log(e)
                }
            }
        })

        return comments;
    }
}

WorkerScript.onMessage = function (msg) {
    console.log('comments::workerscript:: msg=', dump(msg));

    var scraper = new Comments();
    scraper.fetch(msg.id, msg.type, msg.page, function(comments) {
        WorkerScript.sendMessage({reply: 'comments', comments: comments, page: msg.page});
    });
}


