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
    id: articlesFilters
    property bool complete: false
    property var filters

    SilicaFlickable {
        anchors.fill: parent
        leftMargin: 20
        topMargin: 20

        Column {
            anchors.fill: parent

            ComboBox {
                id: cb_type
                //description: 'foobar'

                label: qsTr("Type")+ ":"
                menu: ContextMenu {
                    id: type
                    // NOTE: text is translatable
                    MenuItem {
                        property string value: "all"
                        text: qsTr("All")
                    }
                    MenuItem {
                        property string value: "articles"
                        text: qsTr("Articles")
                    }
                    MenuItem {
                        property string value: "lebrief"
                        text: qsTr("LeBrief")
                    }
                }

                onCurrentItemChanged: {
                    save('type', currentItem.value)
                }
            }

            ComboBox {
                id: cb_status

                label: qsTr("Read status")+":"
                menu: ContextMenu {
                    MenuItem {
                        property string value: "all"
                        text: qsTr("All")
                    }
                    MenuItem {
                        property string value: "unread"
                        text: qsTr("Unread")
                    }
                    MenuItem {
                        property string value: "read"
                        text: qsTr("Read")
                    }
                }

                onCurrentItemChanged: {
                    save('status', currentItem.value)
                }
            }
        }

    }

    Component.onCompleted: {
        filters = db.getConfig("articles.filters")
        refresh()
    }

    onStatusChanged: {
        if (status === PageStatus.Deactivating) {
            articlesModel.update()
        }
    }

    function refresh() {
        //TODO: automatically generates conf from QML
        // ie type.children[x].value
        var conf = {
            'type': ['all', 'articles', 'lebrief'],
            'status': ['all', 'unread', 'read']
        }
        for(var filterName in conf) {
            var value = filters[filterName] || 'all'
            var index = 0

            for(var i in conf[filterName]) {
                if (value === conf[filterName][i]) {
                    index = i; break
                }
            }

            var obj = eval('cb_'+filterName) // returns QML object, ie cb_status
            obj.currentIndex = index
        }

        complete = true
    }


    function save(filter, value) {
        if (!complete) {
            return
        }

        filters[filter] = value
        db.setConfig('articles.filters.'+filter, value.toLowerCase())
    }
}
