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

import "../lib/tags.js" as Tags

ListItem {
    x: Theme.paddingSmall
    width: parent.width - 2*Theme.paddingSmall
    // better than height, include selection height
    contentHeight: Math.max(icon.height, title.height+subtitle.height) + 15

    property string link;

    menu: contextMenu
    ContextMenu {
        id: contextMenu
        MenuItem {
            text: model.star ? qsTr("♡ Unmark as favorite") : qsTr("♥ Mark as favorite")
            onClicked: articlesModel.toggleFavorite(model.index, model.star)
        }
        MenuItem {
            text: model.unread ? qsTr("📖 Mark as read") : qsTr("📕 Mark as unread")
            onClicked: {
                articlesModel.toggleRead(model.index, model.unread)
            }
        }
    }

    Image {
        id: icon
        source: {
            // legacy support (< v7)
            if (typeof(model.icon) === 'string') {
                return model.icon
            }

            return 'https://cdnx.nextinpact.com/data-next/images/bd/square-linked-media/%1.jpg'.arg(model.icon)
        }
        width: parent.width / 3 // 300
        height: width * 0.8     // 240

        fillMode: Image.PreserveAspectFit

        anchors {
            left: parent.left
            topMargin: 10
        }
    }

    Image {
        id: favorite
        source: 'qrc:/res/heart-s.png'
        visible: model.star

        anchors {
            top: icon.top
            topMargin: 10
            left: icon.left
            leftMargin: 5
        }
    }

    Image {
        id: blur
        source: 'qrc:/res/blur60.png'

        anchors {
            bottom: icon.bottom
            left: icon.left
            right: icon.right
        }
        height: 31
    }

    // Brief & Subscriber tags are not both displayed at the same time
    Tag {
        id: brief
        color: "#064358"
        text: qsTr("brief")
        visible: model.type === 1

        anchors {
            left: icon.left
            bottom: icon.bottom
            bottomMargin: 3
        }
    }

    Tag {
        id: subscriber
        color: "#da7012"
        text: qsTr("subscriber")
        visible: model.subscriber

        anchors {
            left: icon.left
            bottom: icon.bottom
            bottomMargin: 3
        }
    }

    Tag {
        id: tag
        color: Tags.color(model.tag)
        text: qsTranslate("Tags", model.subtag ? model.subtag : model.tag)
        visible: model.tag !== ''

        anchors {
            left: brief.visible ? brief.right : (subscriber.visible ? subscriber.right : icon.left)
            leftMargin: (brief.visible || subscriber.visible) ? 5 : 0
            bottom: icon.bottom
            bottomMargin: 3
        }
    }

    Label {
        id: title
        text: model.title
        font.pixelSize: Theme.fontSizeSmall - 4
        wrapMode: Text.WordWrap
        horizontalAlignment: Text.AlignJustify
        color: model.unread ? Theme.primaryColor : Theme.secondaryColor
        lineHeight: 0.90 //0.85

        anchors {
            left: icon.right
            leftMargin: 10

            right: parent.right
            rightMargin: 5
        }
    }

    Label {
        id: timestamp
        //TODO:
        //  - compatibility mode
        //text: model.timestamp
        text: {
            var d = new Date(model.date)
            var h = d.getHours()
            h = h < 10 ? '0'+h : h

            var m = d.getHours()
            m = m < 10 ? '0'+m : m

            return "%1:%2".arg(h).arg(m)
        }
        font.pixelSize: Theme.fontSizeTiny  - 2
        color: "#ea8211"

        anchors {
            //bottom: icon.bottom
            //bottomMargin: -4
            top: subtitle.top
            topMargin: 2

            left: icon.right
            leftMargin: 10
        }
    }

    Label {
        id: dash
        text: " - "
        font.pixelSize: Theme.fontSizeTiny  - 2
        font.italic: true
        styleColor: "#8a979d"

        anchors {
            top: subtitle.top
            left: timestamp.right
        }
    }

    Label {
        id: subtitle
        text: model.type === 1 ? "LeBrief" : model.subtitle
        font.pixelSize: Theme.fontSizeTiny
        font.italic: true
        styleColor: "#8a979d"
        color: model.unread ? Theme.primaryColor : Theme.secondaryColor
        wrapMode: Text.WordWrap
        horizontalAlignment: Text.AlignJustify

        anchors {
            bottom: icon.bottom
            bottomMargin: -5

            left: dash.right
            right: comments_counter.left
            rightMargin: 5
        }
    }

    Label {
        id: comments_counter
        text: model.nbcomments || ''
        font.pixelSize: Theme.fontSizeTiny - 4
        styleColor: "#8a979d"
        font.family: "Arial"

        anchors {
            bottom: icon.bottom
            bottomMargin: -3

            right: comments_icon.left
            rightMargin: 5
        }
    }

    Image {
        id: comments_icon
        source: 'qrc:/res/comments.png'
        visible: model.nbcomments > 0

        anchors {
            bottom: icon.bottom
            bottomMargin: -8

            right: parent.right
            rightMargin: 5
        }
    }
}
