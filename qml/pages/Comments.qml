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

import QtQuick 2.0
import Sailfish.Silica 1.0

import "../components"
import "../lib/utils.js" as Utils

Page {
    id: comments
    property int newsid;
    property int type; // article type
    // current displayed comment (on top of the viewport)
    property int current: listview.indexAt(listview.width/2, listview.contentY)
    // is loading operation currently running
    property bool loading: false

    onCurrentChanged: function() {
        if (status === PageStatus.Inactive || loading) {
            return
        }

        var last   = listview.model.rowCount();
        var bottom = listview.indexAt(listview.width/2, listview.contentY + listview.height);
        console.log('current changed:', current, bottom, last, status)

        // either top comment is last-5,
        // or bottom comment is last
        if (current >= last - 5 || bottom === last - 1) {
            var page = Math.floor(bottom / 10) + 2;
            //console.log('loading next comments (page', page, ')')
            commentScraper.load(page);
        }
    }

    SilicaListView {
        id: listview
        anchors.fill: parent
        anchors.topMargin: 100

        model: commentsModel
        delegate: CommentsDelegate {}

        /** onMovementEnded is only triggered for manual moves, not scrolls
            furthermore, there are no specific scroll events

            onCurrentIndexChanged/onCurrentItemChanged does not works at all either
            listview.currentIndex always returns -1

            'onContentHeightChanged' works for both mouse & slides moves but is triggered way too often
        */

        // triggered when we hit the end of the list
        // we decrement by 10 pixel, or we end pointing `after` the last element (indexAt() returning -1)
        onAtYEndChanged: function() {
            var bottom = listview.indexAt(listview.width/2, listview.contentY + listview.height-10);
            var page = Math.floor(bottom/10) + 2;
            console.log('hitting bottom: idx', bottom+1, ', loading page #', page);

            commentScraper.load(page);
        }
    }

/*
    Rectangle {
        x: width/2 // Theme.paddingMedium*4
        y: 500 //height-100 //100
        width: 20
        height: 20
        color: 'red'
    }
    Rectangle {
        x: listview.width/2 // Theme.paddingMedium*4
        y: listview.height //height-100 //100
        width: 20
        height: 20
        color: 'blue'
    }
*/

    onStatusChanged: {
        //TODO: save and restore position (last comment at top)

        if (status === PageStatus.Activating) {
            listview.model.setArticle(newsid, type);

            if (listview.model.rowCount() === 0) {
                //console.debug('Comments::status activating. loading page 1')
                commentScraper.load(1)
            }
        }
    }

    WorkerScript {
        id: commentScraper
        source: Qt.resolvedUrl("../logic/scrapers/comments.js")
        onMessage: function(m) {
            console.log('comments::worker reply', Utils.dump(m));
            if (m.comments.length === 0) {
                loading = false
                return;
            }

            var is = m.comments[0].num;
            var expected = 10* (m.page-1) + 1;
            //console.log('1st comment:', is, expected)
            if (is !== expected) {
                return
            }

            m.comments.forEach(function(comment) {
                listview.model.addComment(comment)
            })

            loading = false
        }

        function load(page) {
            if (loading) {
                return
            }
            loading = true

            this.sendMessage({action: 'scrap', id: newsid, type: type, page: page})
        }
    }
}

