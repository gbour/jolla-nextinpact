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

import QtQuick 2.0
import Sailfish.Silica 1.0

ListModel {
    id: model
/*
    ListElement {
        icon: 'qrc:/res/img1.jpg'
        title: "foo"
        subtitle: "bar"
        timestamp: "13:37"
        comments: 42
    }

    ListElement {
        icon: 'qrc:/res/img2.jpg'
        title: "Homer"
        subtitle: ""
        timestamp: ""
        comments: ""
    }

    ListElement {
        icon: 'qrc:/res/img3.jpg'
        section: 'Yesterday'
        title: "Very long title wrapped on multilines"
        subtitle: "and the subtitle is very long too, sooooo long long long"
        timestamp: "00:00"
        comments: 0
    }
*/
    function init() {
        console.log("ArticleModel::init")
//      append({'title': 'added via javascript'})

        context.refresh(function(articles) {
            // remove all articles
            clear();

            for (var idx in articles) {
                var art = articles[idx];

                art.section = art.date.toLocaleDateString();
                append(art)
            }
        });
    }
}
