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

Page {
    id: statsPage
    property var stats
    property string dbsize

    SilicaFlickable {
        anchors.fill: parent

        Column {
            anchors.fill: parent
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 20

            PageHeader {
                title: qsTr("Statistics")
            }

            Row {
                anchors {
                    margins: 10
                    rightMargin: 10
                }

                Label {
                    text: qsTr("<b>Articles</b> <i>Read<br/>Unread<br/>Total</i>")
                    textFormat: Text.RichText
                    horizontalAlignment: Text.AlignRight

                    width: 300
                    rightPadding: 20
                }

                Label {
                    text: (stats['article-read'] || 0) + '\n' +
                          (stats['article-unread'] || 0) + '\n' +
                          (stats['article-total'] || 0)
                    font.bold: true
                }
            }

            Row {
                anchors {
                    margins: 50
                }

                Label {
                    text: qsTr("<b>LeBrief</b> <i>Read<br/>Unread<br/>Total</i>")
                    textFormat: Text.RichText
                    horizontalAlignment: Text.AlignRight

                    width: 300
                    rightPadding: 20
                }

                Label {
                    text: (stats['lebrief-read'] || 0) + '\n' +
                          (stats['lebrief-unread'] || 0) + '\n' +
                          (stats['lebrief-total'] || 0)
                    font.bold: true
                }

            }

            Row {
                anchors {
                    margins: 50
                }

                Label {
                    text: qsTr("<b>Comments</b>")
                    textFormat: Text.RichText
                    horizontalAlignment: Text.AlignRight

                    width: 300
                    rightPadding: 20
                }

                Label {
                    text: stats['comments'] || '0'
                    font.bold: true
                }

            }

            Row {
                anchors {
                    margins: 10
                }

                Label {
                    text: qsTr("Database size")
                    horizontalAlignment: Text.AlignRight

                    width: 300
                    rightPadding: 20
                }

                Label {
                    text: dbsize
                    font.bold: true
                }
            }

            SectionHeader {
                text: "Actions"
            }

            ButtonLayout {
                RemorsePopup { id: remorse }

                Button {
                    text: "Clear"
                    highlightBackgroundColor : 'red'
                    highlightColor: 'black'
                    onClicked: remorse.execute("WARNING: Clearing database", function() {
                        db.flush()
                        refresh()
                        articlesModel.update()
                    })
                }

                Button {
                    text: "Settings"
                    onClicked: pageStack.push(Qt.resolvedUrl("Settings.qml"), PageStackAction.Animated)

                }
            }
        }
    }

    // TODO: this function should be trigged on global event
    //       ie if db is clean by ApplicationWindow timer and this page is displayed
    //       we would like to autàmatically refresh the statistics
    //       (see https://doc.qt.io/qt-5/qtqml-syntax-signals.html)
    function refresh() {
        var _stats = articlesModel.stats2()
        _stats['comments'] = commentsModel.count()
        stats = _stats

        //NOTE: qt 5.10 provides formattedDataSize() for human readable size
        //      https://doc.qt.io/qt-5/qlocale.html#formattedDataSize
        var rawsize = db.size()
        var units = ['B','KB','MB','GB']
        var idx = 0
        while (rawsize >= 1024.0 && idx < units.length-1) {
            idx++
            rawsize /= 1024.0
        }

        dbsize = rawsize + " " + units[idx]
    }

    onVisibleChanged: {
        // NOTE: when coming back from settings, refresh is executed BEFORE cleanup
        //       this should be the contrary
        if (visible) {
            refresh()
        }
    }
}
