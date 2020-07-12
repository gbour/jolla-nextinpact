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

Item {
    property string color
    property string text

    width: fill.width

    Rectangle {
        id: fill
        color: parent.color
        radius: 6

        width: tagname.width + 20
        height: tagname.height + 4

        anchors {
            bottom: parent.bottom
            left: parent.left
            leftMargin: -10
        }
    }

    Label {
        id: tagname
        text: parent.text
        font.pixelSize: Theme.fontSizeTiny-8
        color: "#fff"
        font.family: "Arial"

        anchors {
            bottom: parent.bottom
            bottomMargin: 2
            left: parent.left
        }
    }
}
