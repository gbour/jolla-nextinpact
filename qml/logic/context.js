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

function init() {
    //NOTHING TO DO
}

function load(url, scraper, callback) {
    var http = new XMLHttpRequest();
    http.open("GET", url, true);
    // not possible - http.setRequestHeader("User-Agent", "Jolla/NextINpact 0.1")

    http.onreadystatechange = function() {
        if (http.readyState === XMLHttpRequest.DONE && http.status === 200) {
           //console.log(http.responseText)

            var content = scraper.fetch(http.responseText);
            //console.log(articles);
            callback(content);
        }
    }

    http.send();
}

