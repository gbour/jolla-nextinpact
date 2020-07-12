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

ListItem {
    x: Theme.paddingSmall
    width: parent.width - 2*Theme.paddingSmall
    // better than height, include selection height
    contentHeight: Math.max(icon.height, title.height+subtitle.height) + 15

    property string link;

    Image {
        id: icon
        source: model.icon
        width: parent.width / 3 // 300
        height: width * 0.8     // 240

        fillMode: Image.PreserveAspectFit

        anchors {
            left: parent.left
            topMargin: 10
        }
    }

    Label {
        id: title
        text: model.title
        font.pixelSize: Theme.fontSizeSmall - 4 //Tiny
        wrapMode: Text.WordWrap
        horizontalAlignment: Text.AlignJustify
        color: model.unread ? Theme.primaryColor : Theme.secondaryColor
        lineHeight: 0.85

        anchors {
            left: icon.right
            leftMargin: 10

            right: parent.right
            rightMargin: 5
        }
    }

    Label {
        id: timestamp
        text: model.timestamp
        font.pixelSize: Theme.fontSizeTiny  - 2
        color: "#ea8211"

        anchors {
            bottom: icon.bottom
            bottomMargin: -4
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
        font.pixelSize: Theme.fontSizeTiny  //- 2 //8 //Theme.fontSizeExtraSmall
        font.italic: true
        styleColor: "#8a979d"
        color: model.unread ? Theme.primaryColor : Theme.secondaryColor
        wrapMode: Text.WordWrap
        horizontalAlignment: Text.AlignJustify

        anchors {
            bottom: icon.bottom
            bottomMargin: -5

            left: dash.right
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
