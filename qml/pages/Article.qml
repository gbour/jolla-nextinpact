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

import "../lib/utils.js" as Utils

Page {
    id: detail

    // article object.
    // From Articles.qml, it contains only a subset of fiels (no author or content).
    // After onCompleted(), it has the same fields as in database
    property var model;

    //allowedOrientations: defaultOrientationTransition

    onStatusChanged: {
        if (status === PageStatus.Active && !pageStack._currentContainer.attachedContainer) {
            var params = {
                newsid: model.id,
                type: model.type,
                //page: 1
            }

            pageStack.pushAttached(Qt.resolvedUrl("Comments.qml"), params, PageStackAction.Animated)
        }
    }

    SilicaFlickable {
        id: view
        //quickScroll: true
        anchors.fill: parent

        contentHeight: columns.height

        anchors.margins: Theme.horizontalPageMargin
        anchors.topMargin: 120

        PageHeader {
        }

        Column {
            id: columns
            width: parent.width

            Label {
                id: title
                width: parent.width

                text: model.title
                font.pixelSize: Theme.fontSizeSmall
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                color: Theme.highlightColor
            }

            Label {
                id: subtitle

                text: model.type === 1 ? 'LeBrief' : model.subtitle
                font.pixelSize: Theme.fontSizeExtraSmall
                font.italic: true
                wrapMode: Text.WordWrap
                color: Theme.primaryColor
            }

            Label {
                id: author
                width: parent.width

                text: model.author||'None'
                font.pixelSize: Theme.fontSizeExtraSmall
                horizontalAlignment: Text.AlignRight
            }


            Label {
                id: content
                width: parent.width
                topPadding: 50

                text: model.content||'None'
                textFormat: Text.RichText
                font.pixelSize: Theme.fontSizeExtraSmall
                verticalAlignment: Qt.AlignJustify
                wrapMode: Text.WordWrap
                color:  Theme.secondaryColor

                // links opened in a browser
                onLinkActivated: Qt.openUrlExternally(link)
            }

            Label {
                text: '⌁'

                width: parent.width
                padding: 10
                horizontalAlignment: Qt.AlignRight
            }

        }
    }

    VerticalScrollDecorator { flickable: view }


    Component.onCompleted: {
        //console.log('loading article', model.id)
        // try first to load article from database
        var article = db.getContent(model.id)
        if (article !== undefined && article.content.length > 0) {
            refresh(article)
            return
        }

        // if not already fetched & stored, then do it & refresh the page
        console.log('article', model.id, 'not found in db, fetchin now');
        articleScraper.load()

    }

    Component.onDestruction: function() {
        // when leaving article page, stop 'read' timer if not triggered yet
        read_timer.stop()
    }

    function refresh(_article) {
        // merge article fields into model
        // NOTE: we have to use a temp variable and to reassign to `model` property for
        //       trigger page update
        var _tmp = model
        for(var prop in _article) {
            _tmp[prop] = _article[prop]
        }
        model = _tmp

        if (model.unread === 1) {
            read_timer.start()
        }
    }

    WorkerScript {
        id: articleScraper
        source: Qt.resolvedUrl("../logic/scrapers/article.js")
        onMessage: function(m) {
            //console.log("article:worker reply", Utils.dump(m))
            db.setContent(model.id, m.article)
            refresh(m.article)
        }

        function load() {
            articleScraper.sendMessage({action: 'scrape', uri: model.link})
        }
    }

    Timer {
        id: read_timer
        interval: 5000 // 5 secs
        running: false
        onTriggered: {
            //console.log('timer', model.id, model.title, model.unread)
            db.toggleRead(model.id, true)
            articlesListModel.updateModel()
        }
    }
}
