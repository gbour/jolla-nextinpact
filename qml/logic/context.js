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
            // insert into db
            for(var idx in articles) {
                db.articleAdd(articles[idx])
            }

            callback(articles);

        }

    }

    http.send();
}

