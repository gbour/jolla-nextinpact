
.import '../lib/htmlparser2.js' as HtmlParser
.import '../lib/iso8859-15.js' as Iso

var STATE_ARTICLE = 1 //
var STATE_H1      = 2      //
var STATE_A       = 3       //
var STATE_DATE    = 4
var STATE_SUBTITLE = 5
var STATE_COMMENTS = 6

var states = ['',
    /* STATE_ARTICLE  */ 'article',
    /* STATE_H1       */ 'h1',
    /* STATE_A        */ 'a',
    /* STATE_DATE     */ 'span',
    /* STATE_SUBTITLE */ 'span',
    /* STATE_COMMENTS */ 'span'
];


function Article() {
}

Article.prototype = {
    _url: 'http://m.nextinpact.com/?page=%{page}',
    url: function(params) {
        var tmp = this._url;
        for(var key in params) {
            tmp = tmp.replace('%{'+key+'}', params[key]);
        }

        console.log('url='+tmp)
        return tmp;
    },

    fetch: function (m) {
        var articles = []
        var article  = null
        var parent   = {tag: null, attrs:[]}
        var state    = [0]

        HtmlParser.HTMLParser(m, {
            start: function (tag, attrs, unary) {
                //console.log(state+','+tag)

                try {
                    if(state[0] == 0 && tag === 'article') {
                        state.unshift(STATE_ARTICLE);
                        article = {};

                    } else if(state[0] == STATE_ARTICLE && tag == 'h1') {
                        state.unshift(STATE_H1);

                    } else if(state[0] == STATE_H1 && tag == 'a') {
                        state.unshift(STATE_A);
                        article.link = attrs.href.value;

                    } else if(state[0] == STATE_ARTICLE && tag == 'img' &&
                              attrs.class.value == 'ded-image') {
                        article.icon = 'http:' + attrs['data-src'].value;
                    } else if(state[0] == STATE_ARTICLE && tag == 'span' &&
                              attrs.class.value == 'date_pub') {
                        state.unshift(STATE_DATE);
                    } else if(state[0] == STATE_ARTICLE && tag == 'span' &&
                              attrs.class.value == 'soustitre') {
                        state.unshift(STATE_SUBTITLE);
                    } else if(state[0] == STATE_ARTICLE && tag == 'span' &&
                              attrs.class.value == 'nbcomment') {
                        state.unshift(STATE_COMMENTS);
                    }
                } catch(e) {
                    console.log('e='+e)

                }

                parent = {tag: tag, attrs: attrs}
            },

            end: function (tag) {
                //console.log('end='+tag+','+state[0] + ','+states[state[0]]);

                if(states[state[0]] == tag) {
                    console.log("unshift " + tag)
                    state.shift()
                }

                if (tag == 'article') {
                    articles.push(article);
                }
            },

            chars: function (text) {
                text = text.trim();

                try {
                    if(state[0] == STATE_A) {
                        article.title = Iso.map(text);
                    } else if(state[0] == STATE_DATE) {
                        article.timestamp = text;
                    } else if(state[0] == STATE_SUBTITLE) {
                        // remove '- ' at start
                        article.subtitle = Iso.map(text.substr(2));
                    } else if(state[0] == STATE_COMMENTS) {
                        article.comments = text;
                    }
                } catch (e) {}
            }
        })

        return articles;
    }
}
