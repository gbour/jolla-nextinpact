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

import "../logic/scrapers/article.js" as Scraper

Page {
    id: detail

    // id of current article in the database
    property string artid;
    // url is provided when clicking list item in articles list view
    property string url;

    // article fields
    property string title;
    property string subtitle;
    property string author;
    property string content;

    //allowedOrientations: defaultOrientationTransition

    onStatusChanged: {
        if (status === PageStatus.Active && !pageStack._currentContainer.attachedContainer) {
            var params = {
                newsid: artid,
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

                text: detail.title
                font.pixelSize: Theme.fontSizeSmall
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                color: Theme.highlightColor
            }

            Label {
                id: subtitle

                text: detail.subtitle
                font.pixelSize: Theme.fontSizeExtraSmall
                font.italic: true
                wrapMode: Text.WordWrap
                color: Theme.primaryColor
            }

            Label {
                id: author
                width: parent.width

                text: detail.author
                font.pixelSize: Theme.fontSizeExtraSmall
                horizontalAlignment: Text.AlignRight
            }


            Label {
                id: content
                width: parent.width
                topPadding: 50

                text: detail.content
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
        //console.log('loading article content', appwin, context, url)

        var article = db.getContent(artid);

        var fn = function(article) {
                    detail.title = article.title
                    detail.subtitle = article.subtitle
                    detail.content = article.content
                    detail.author = article.author
        };
        if (true || article === undefined || article.content === "") {
            var scraper = new Scraper.Article();
            context.load(url, scraper, function(article) {
                db.setContent(artid, article);

                detail.title = article.title
                detail.subtitle = article.subtitle
                detail.content = article.content
                detail.author = article.author
            });
        } else {
            fn(article);
        }
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
