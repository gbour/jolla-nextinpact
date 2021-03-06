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

import "../lib/utils.js" as Utils

CoverBackground {
    id: cover
    property var stats;
    // NOTE: default value is required to use it as visible selector
    //       the object is initialized later in onStatusChanged callback (Activating state)
    property var articlesPageStack: {'loading': false}

    // Background image
    Image {
        x: -Theme.paddingLarge
        y: 100
        source: 'qrc:/res/cover-background.png'
    }

    // Loader
    BusyIndicator {
        id: loaderCover
        visible: articlesPageStack.loading
        running: true
        anchors.centerIn: parent

        NumberAnimation on rotation {
            from: 0; to: 360
            duration: 2000
            running: articlesPageStack.loading
            loops: Animation.Infinite
        }
    }

    // Articles statistics
    Column {
        id: statsCover
        visible: !articlesPageStack.loading

        anchors { top: parent.top; topMargin: Theme.paddingLarge }
        width: cover.width - (2 * Theme.paddingLarge)
        x: Theme.paddingLarge
        spacing: Theme.paddingSmall

        Item {
            width: parent.width
            height: 30

            Label {
                text: "Next"

                anchors {
                    left: parent.left
                    top: parent.top
                    bottom: parent.bottom
                }
                width: Theme.itemSizeSmall

                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignRight
                wrapMode: Text.NoWrap
                font.pixelSize: Theme.fontSizeExtraLarge
                font.bold: true

            }
        }
        Item {
            width: parent.width
            height: Theme.paddingSmall
            id: label2


            Label {
                text: "Inpact"
                anchors.left: parent.left

                anchors {
                    top: parent.top
                    bottom: parent.bottom
                    topMargin: 15
                }
                width: Theme.itemSizeSmall

                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignLeft
                wrapMode: Text.NoWrap
                font.pixelSize: Theme.fontSizeExtraLarge
                font.bold: true
            }


        }

        Item {
            id: labelTitle2
            width: parent.width
            height: Theme.itemSizeSmall

            Label {
                id: unread

                anchors {
                    left: parent.left
                    top: labelUnread.top
                    bottom: parent.bottom
                }
                width: Theme.itemSizeSmall

                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignRight
                wrapMode: Text.NoWrap
                font.pixelSize: Theme.fontSizeExtraLarge
                text: stats ? stats.unread : '1'
            }

            Label {
                id: labelUnread

                anchors {
                    left: unread.right
                    right: parent.right
                    top: parent.top
                    bottom: parent.bottom
                    leftMargin: Theme.paddingSmall
                    topMargin: 100
                }

                verticalAlignment: Text.AlignVCenter
                font.pixelSize: Theme.fontSizeSmall
                text: qsTr("Unread\narticles")
            }
        }

        Item {
            width: parent.width
            height: Theme.itemSizeSmall

            Label {
                id: total

                anchors {
                    left: parent.left
                    top: labelTotal.top
                }
                width: Theme.itemSizeSmall

                verticalAlignment: Text.AlignTop
                horizontalAlignment: Text.AlignRight
                wrapMode: Text.NoWrap
                font.pixelSize: Theme.fontSizeExtraLarge
                text: stats ? stats.total : '42'
            }

            Label {
                id: labelTotal

                anchors {
                    left: total.right
                    right: parent.right
                    top: parent.top
                    leftMargin: Theme.paddingSmall
                    topMargin: 50
                }
                verticalAlignment: Text.AlignVCenter
                font.pixelSize: Theme.fontSizeSmall
                text: qsTr("Total\narticles")
            }
        }
    }

    CoverActionList {
        id: coverAction

        CoverAction {
            iconSource: "image://theme/icon-cover-refresh"
            onTriggered: {
                if (articlesPageStack.loading) {
                    // already loading
                    return
                }

                console.log('Cover:: refresh articles')
                articlesPageStack.refresh(true, refresh)
            }
        }
    }

    onStatusChanged: {
        if (status == PageStatus.Activating) {
            // get Articles.qml page instance to ask for refresh
            articlesPageStack = pageStack.find(function(page) {
                return page.toString().substr(0, 8) === "Articles"
            })
            if (articlesPageStack === undefined) {
                console.error("ERR:: ArticlesPageStack not found")
            }

            refresh()
        }
    }

    // refresh stats
    function refresh() {
        console.log('Cover:: refresh stats')
        stats = articlesModel.stats();
    }
}
