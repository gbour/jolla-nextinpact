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
import QtWebKit 3.0

import "../logic/scrapers/article.js" as Scraper

Page {
    id: detail

    // id of current article in the database
    property string artid;
    // url is provided when clicking list item in articles list view
    property alias url: detailview.url;


    SilicaWebView {
        id: detailview

        header: PageHeader {

        }

        experimental.userAgent: "Mozilla/5.0 (Linux; U; Android 2.2; en-us; Nexus One Build/FRF91) AppleWebKit/533.1 (KHTML, like Gecko) Version/4.0 Mobile Safari/533.1"

        url: ""
        //forwardNavigation: false

        //html: "<html><body><title>Yeah!!!</title></body></html>"
        anchors {
            top: parent.top
            left: parent.left
            right: parent.right
            bottom: parent.bottom

        }

        onLoadingChanged: function(req) {
            /*
                started: 0
                stopped: 1
                succeed: 2
                failed:  3
             */
            // starts read timer when the article is completely loaded
            if (req.status === WebView.LoadSucceededStatus) {
                read_timer.start()
            }
        }

    }


    Component.onCompleted: {
        //detailview.loadHtml("<html><body><h1>Yeah!!!</h1></body></html> <b>ploploplop</b>")
    }

    Component.onDestruction: function() {
        // when leaving article page, stop 'read' timer if not triggered yet
        read_timer.stop()
    }

    Timer {
        id: read_timer
        interval: 5000 // 5 secs
        running: false
        onTriggered: {
            db.toggleRead(artid, true);
            articlesListModel.updateModel()
        }
    }
}
