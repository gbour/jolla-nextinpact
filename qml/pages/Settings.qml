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

import "../lib/utils.js" as Utils

Page {
    id: settingsPage
    property var deleteMap: {
        // idx to days
        0: 0,
        1: 30,
        2: 90,
        3: 180,

        // days to idx
        30: 1,
        90: 2,
        180: 3,
    }

    SilicaFlickable {
        anchors.fill: parent

        Column {
            anchors.fill: parent
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 20

            PageHeader {
                title: qsTr("Settings")
            }

            ComboBox {
                id: delete_cb
                label: qsTr("Delete entries older than")
                currentIndex: 0
                menu: ContextMenu {
                    MenuItem { text: qsTr("never") }
                    MenuItem { text: qsTr("1 month") }
                    MenuItem { text: qsTr("3 month") }
                    MenuItem { text: qsTr("6 month") }
                }
                description: qsTr("Based on publication date")
                onCurrentIndexChanged: {
                    db.setConfig('cleanup.frequency', deleteMap[currentIndex])
                }
            }
        }
    }

    //Component.onCompleted: {
    onStatusChanged: {
        if (status == PageStatus.Activating) {
            var freq = db.getConfig('cleanup')
            freq = parseInt(freq['frequency']) || 0
            delete_cb.currentIndex = deleteMap[freq]

        } else if (status === PageStatus.Deactivating) {
            if (db.cleanup()) {
                articlesModel.update()
            }
        }
    }
}
