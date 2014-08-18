
.import "../lib/htmlparser2.js" as HtmlParser
.import "scraper.js" as Scraper

var state = {
    'key1': null,
}

function init() {
    console.log("context init");
    state['key1'] = 42;

    console.log('key1=' + state['key1']);
}

function refresh(callback) {
    //
    var scraper = new Scraper.Article();

    var http = new XMLHttpRequest();
    http.open("GET", scraper.url({page: 1}), true);
    // not possible - http.setRequestHeader("User-Agent", "Jolla/NextINpact 0.1")

    http.onreadystatechange = function() {
        if (http.readyState === XMLHttpRequest.DONE && http.status === 200) {
           //console.log(http.responseText)

            var articles = scraper.fetch(http.responseText);
            callback(articles);

        }

    }

    http.send();
}

