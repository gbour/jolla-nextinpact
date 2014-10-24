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

CoverBackground {

    Image {
        id: logo
        source: 'qrc:/res/logo-big.png'

        anchors {
            horizontalCenter: parent.horizontalCenter
            //top: parent.top
            //topMargin: 10
            verticalCenter: parent.verticalCenter
            centerIn: parent
        }
    }

    Label {
        id: label
        text: "NextINpact"

        anchors {
            top: logo.bottom
            topMargin: 5
            horizontalCenter: parent.horizontalCenter
        }
    }

/*
    CoverActionList {
        id: coverAction

        CoverAction {
            iconSource: "image://theme/icon-cover-refresh"
        }
    }
   */
}


