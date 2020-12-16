/*
    Copyright 2020 Guillaume Bour.
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
import "../lib/tags.js" as Tags
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

        PullDownMenu {
            MenuItem {
                text: qsTr("Open in browser")
                onClicked: Qt.openUrlExternally("https://nextinpact.com" + model.link)
            }
        }

        contentHeight: columns.height + columns.anchors.topMargin

        PageHeader {
        }

        Column {
            id: columns
            width: parent.width

            anchors {
                top: parent.top
                topMargin: 120

                left: parent.left
                leftMargin: 20
                right: parent.right
                rightMargin: 20
            }

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

                text: {
                    // legacy author: 'Par xx', v7: 'xx'
                    var x = model.author
                    // if v7 & not empty
                    if (typeof(model.icon) !== 'string' && x !== '') {
                        x = 'Par ' + model.author||''
                    }
                    return x
                }
                font.pixelSize: Theme.fontSizeExtraSmall
                horizontalAlignment: Text.AlignRight
            }


            Row {
                // Brief & Subscriber tags are not both displayed at the same time
                Tag {
                    id: brief
                    color: "#064358"
                    text: qsTr("brief")
                    visible: model.type === 1

                    anchors {
                        left: parent.left
                        top: parent.top
                        //bottomMargin: 3
                    }
                }

                Tag {
                    id: subscriber
                    color: "#da7012"
                    text: qsTr("subscriber")
                    visible: model.subscriber

                    anchors {
                        left: parent.left
                        top: parent.top
                    }
                }

                Tag {
                    id: tag
                    color: Tags.color(model.tag)
                    text: qsTranslate("Tags", model.subtag ? model.subtag : model.tag)
                    //font.pixelSize: Theme.fontSizeTiny
                    visible: model.tag !== ''

                    anchors {
                        left: brief.visible ? brief.right : (subscriber.visible ? subscriber.right : parent.left)
                        leftMargin: (brief.visible || subscriber.visible) ? 5 : 0
                    }
                }

                Image {
                    id: favorite
                    source: 'qrc:/res/heart-s.png'
                    visible: model.star

                    anchors {
                        bottom: tag.bottom
                        bottomMargin: -10
                        left: tag.right
                        leftMargin: 5
                    }
                }

                anchors.top: author.bottom
                height: 100
            }

            Label {
                id: content
                width: parent.width
                topPadding: 50

                text: model.content||''
                textFormat: Text.RichText
                font.pixelSize: Theme.fontSizeExtraSmall
                verticalAlignment: Text.AlignJustify
                horizontalAlignment: Text.AlignJustify
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

        //NOTE : model already contains all db fields
        // so we need to check of mode.content is empty (NULL?) or not
        if (model.content !== "") {
            read_timer.condstart()
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

    WorkerScript {
        id: articleScraper
        source: Qt.resolvedUrl("../logic/scrapers/article.js")
        onMessage: function(m) {
            console.log("article:worker reply", Utils.dump(m))

            //refresh(m.article)
            var ret = articlesModel.setContent(model.index, m.article)
            if (ret) {
                read_timer.condstart()
            }
        }

        function load() {
            articleScraper.sendMessage({action: 'scrape', id: model.id})
        }
    }

    Timer {
        id: read_timer
        interval: 5000 // 5 secs
        running: false
        onTriggered: {
            //console.log('timer', model.id, model.title, model.unread)
            articlesModel.toggleRead(model.index, true)
        }

        function condstart() {
            if (model.unread === 1) {
                read_timer.start()
            }
        }
    }
}
