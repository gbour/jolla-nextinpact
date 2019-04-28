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

var STATE_COMMENT = 1
var STATE_AUTHOR  = 2
var STATE_DATE    = 3
var STATE_NUM     = 4
var STATE_CONTENT = 5

var states = ['',
              /* STATE_COMMENT  */ 'div',
              /* STATE_AUTHOR   */ 'span',
              /* STATE_DATE     */ 'span',
              /* STATE_NUM      */ 'span',
              /* STATE_CONTENT  */ 'div'
        ];


function Comments() {
}

Comments.prototype = {
    _url: 'https://m.nextinpact.com/comment/',

    fetch: function(newsid, type, page, callback) {
        //console.debug('Comments.fetch', this._url, newsid, page);
        var http = new XMLHttpRequest();

        http.open("POST", this._url, true)
        http.setRequestHeader('Content-type', 'application/x-www-form-urlencoded');

        var self = this;
        http.onreadystatechange = function() {
            if (http.readyState === XMLHttpRequest.DONE && http.status === 200) {
                //console.log(http.responseText)

                var comments = self.scrap(http.responseText);
                //console.debug('comments::fetch: got', comments.length, ' comments');
                callback(comments);
            }
        }

        http.send('commId=0&newsId='+newsid+'&page='+page+'&type='+type);
    },

    scrap: function (m) {
        //console.log('fetch comments');

        var comments = []
        var comment  = null
        var parent   = {tag: null, attrs:[]}
        var state    = [0]

        var cnt = 0
        var quote_idx = 0;

        HTMLParser(m, {
            start: function (tag, attrs, unary) {
                //console.log(tag)

                try {
                    if (state[0] === 0 && 'class' in attrs) {
                        //NOTE; beware of trailing space !!
                        if (attrs.class.value === 'actu_comm ') {
                            state.unshift(STATE_COMMENT);
                            comment = {
                                'num'    : -1,
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
                        //console.log(text, iso_map(text))
                        comment.content += iso_map(text, false);
                    }
                } catch (e) {}
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


