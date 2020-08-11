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
Qt.include('../../lib/tags.js')

var STATE_ARTICLE = 1
var STATE_H1      = 2
var STATE_A       = 3
var STATE_DATE    = 4
var STATE_SUBTITLE = 5
var STATE_COMMENTS = 6


var states = ['',
    /* STATE_ARTICLE  */ 'article',
    /* STATE_H1       */ 'h1',
    /* STATE_A        */ 'a',
    /* STATE_DATE     */ 'span',
    /* STATE_SUBTITLE */ 'span',
    /* STATE_COMMENTS */ 'span',
];



function Articles() {
}

Articles.prototype = {
    _url: 'https://api-v1.nextinpact.com/api/v1/SimpleContent/list?Page=%{page}&Nb=%{count}',
    url: function(params) {
        // default number of results
        if (params['count'] === undefined) {
            params['count'] = 20;
        }

        var tmp = this._url;
        for(var key in params) {
            tmp = tmp.replace('%{'+key+'}', params[key]);
        }

        console.log('url='+tmp);
        return tmp;
    },

    fetch: function(uri, callback) {
        console.debug('Articles.fetch', uri);
        var http = new XMLHttpRequest();
        http.open("GET", uri, true);
        // not possible - http.setRequestHeader("User-Agent", "Jolla/NextINpact 0.1")

        var self = this;
        http.onreadystatechange = function() {
            if (http.readyState === XMLHttpRequest.DONE && http.status === 200) {
                //console.log(http.responseText)
                //var content = self.scrap(http.responseText);

                var json = JSON.parse(http.responseText)
                console.log(http.responseType, typeof(http.response), typeof(json), json["totalItems"])

                var articles = self.scrap_v7(json);
                //console.log(content);
                //callback(articles);
                self.nbcomments(articles, callback);
            }
        }

        http.send();
    },

    nbcomments: function(articles, callback) {
        var params = ''
        var index = {}
        for (var i in articles) {
            params += '&ids='+articles[i].id
            index[articles[i].id] = articles[i]
        }
        var uri = 'https://api-v1.nextinpact.com/api/v1/Commentaire/count?'+params.substring(1)
        console.log('NbComments.fetch', uri)

        var http = new XMLHttpRequest();
        http.open("GET", uri, true);
        // not possible - http.setRequestHeader("User-Agent", "Jolla/NextINpact 0.1")

        var self = this;
        http.onreadystatechange = function() {
            if (http.readyState === XMLHttpRequest.DONE && http.status === 200) {
                var json = JSON.parse(http.responseText)

                for (var i in json['results']) {
                    index[json['results'][i].contentId].comments = json['results'][i].nbTotal
                }

                callback(articles);
            }
        }

        http.send();
    },


    scrap_v7: function(data) {
        var articles = []

        for (var i in data['results']) {
            var entry = data['results'][i]

            try {
                var article = {
                    'id'        : entry['contentId'],
                    // 0: regular article, 1: brief, 2: hardware
                    'type'      : entry['isBrief'] ? 1 : (entry['isIH'] ? 2 : 0),
                    'title'     : entry['title'],
                    'subtitle'  : entry['subtitle'],
                    'icon'      : entry['imageId'],
                    'subscriber': entry['isPaywalled'],
                    // casting to Date object allows to harmonize date format
                    // 2020-08-07T08:17:12     -> 2020-08-07T08:17:12.00
                    // 2020-08-11T09:35:13.874 -> 2020-08-11T09:35:13.874
                    'date'      : new Date(entry['datePublished']),
                    // nb-comments requires a 2d query
                    'comments'  : 0,
                    // TODO: handle cases no author, 2+ authors
                    'author'    : entry['authors'][0] === undefined ? "" : entry['authors'][0]['name'],
                    'tag'       : normalize(entry['categoryName']),
                    'subtag'    : entry['subCategoryName'].toLowerCase(),
                    // link: deduced from id
                    // timestamp : useless
                    // position  : useless
                }

                console.log(dump(article))
                articles.push(article)
            } catch (e) {
                console.log('e=', e, dump(entry))
            }
        }

        return articles
    },


    scrap: function (m) {
        var articles = []
        var article  = null
        var parent   = {tag: null, attrs:[]}
        var state    = [0]

        HTMLParser(m, {
            start: function (tag, attrs, unary) {
                //console.log(state+','+tag)

                try {
                    if(state[0] === 0 && tag === 'article') {
                        state.unshift(STATE_ARTICLE);
                        article = {
                            'comments': 0,
                            'subscriber': false,
                        };

                        if('data-acturowid' in attrs) {
                            article.id = attrs['data-acturowid'].value
                        }

                        //01/09/2014 16:00:08 => new Date('01 Sept 2014 16:00:08')
                        if('data-datepubli' in attrs) {
                            var elts = attrs['data-datepubli'].value.split('/')
                            elts[1] = MONTHS[parseInt(elts[1])-1];
                            article.date = new Date(elts.join(' '));
                        } else {
                            article.date = new Date();
                        }


                    } else if(state[0] === STATE_ARTICLE && tag === 'h1') {
                        state.unshift(STATE_H1);

                    } else if(state[0] === STATE_H1 && tag === 'a') {
                        state.unshift(STATE_A);
                        article.link = 'http://m.nextinpact.com/'+attrs.href.value;

                    } else if(state[0] === STATE_ARTICLE && tag === 'img' &&
                              'class' in attrs && attrs.class.value === 'ded-image') {
                        if('data-frz-src' in attrs) {
                            article.icon = attrs['data-frz-src'].value;
                        } else {
                            article.icon = attrs['data-src'].value;
                        }

                        if(article.icon.indexOf('//') === 0) {
                            article.icon = 'http:' + article.icon;
                        }

                    } else if(state[0] === STATE_ARTICLE && tag === 'span' &&
                              attrs.class.value === 'date_pub') {
                        state.unshift(STATE_DATE);
                    } else if(state[0] === STATE_ARTICLE && tag === 'span' &&
                              attrs.class.value === 'soustitre') {
                        state.unshift(STATE_SUBTITLE);
                    } else if(state[0] === STATE_ARTICLE && tag === 'span' &&
                              attrs.class.value === 'nb_comments') {
                        state.unshift(STATE_COMMENTS);
                    } else if(state[0] === STATE_ARTICLE && tag === 'img' &&
                              'alt' in attrs && attrs.alt.value === 'badge_abonne') {
                        article.subscriber = true;
                    }

                } catch(e) {
                    console.log('e=' + e + ' (tag=' + tag + ')')
                    console.log(dump(attrs))
                }

                parent = {tag: tag, attrs: attrs}
            },

            end: function (tag) {
                //console.log('end='+tag+','+state[0] + ','+states[state[0]]);

                if(states[state[0]] === tag) {
                    state.shift()
                }

                if (tag === 'article') {
                    articles.push(article);
                }
            },

            chars: function (text) {
                text = text.trim();

                try {
                    if(state[0] === STATE_A) {
                        article.title = iso_map(text);
                    } else if(state[0] === STATE_DATE) {
                        article.timestamp = text;
                    } else if(state[0] === STATE_SUBTITLE) {
                        // remove '- ' at start
                        article.subtitle = iso_map(text.substr(2));
                    } else if(state[0] === STATE_COMMENTS) {
                        article.comments = text;
                    }
                } catch (e) {}
            }
        })

        return articles;
    }
}

WorkerScript.onMessage = function (msg) {
    console.log('articles::workerscript:: msg=', dump(msg), msg.page);

    var scraper = new Articles();
    scraper.fetch(scraper.url({page: msg.page, count: msg.count}), function(articles) {
        //dump(articles);
        WorkerScript.sendMessage({reply: 'counter', count: articles.length})

        articles.forEach(function(article) {
            //console.log(dump(article));
            WorkerScript.sendMessage({reply: 'article', article: article});
        });

        WorkerScript.sendMessage({reply: 'complete'})
    });
}
