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
    id: articlesFilters
    property bool complete: false
    property var filters

    SilicaFlickable {
        anchors.fill: parent
        leftMargin: 20
        topMargin: 20

        Column {
            id: sets
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

                property string fieldName: 'type' // id not readable,

                // set filter value
                function set(value) {
                    setItemValue(this, value)
                }

                onCurrentItemChanged: {
                    save(fieldName, currentItem.value)
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

                property string fieldName: 'status' // id not readable,

                // set filter value
                function set(value) {
                    setItemValue(this, value)
                }

                onCurrentItemChanged: {
                    save(fieldName, currentItem.value)
                }
            }

            ComboBox {
                id: cb_tag

                label: qsTr("Tag")+":"
                menu: ContextMenu{
                    MenuItem {
                        property string value: "all"
                        text: qsTr("All")
                    }
                    MenuItem {
                        property string value: "culture-numerique"
                        text: Utils.capitalize(qsTranslate("Tags", value))
                    }
                    MenuItem {
                        property string value: "droit"
                        text: Utils.capitalize(qsTranslate("Tags", value))
                    }
                    MenuItem {
                        property string value: "economie"
                        text: Utils.capitalize(qsTranslate("Tags", value))
                    }
                    MenuItem {
                        property string value: "internet"
                        text: Utils.capitalize(qsTranslate("Tags", value))
                    }
                    MenuItem {
                        property string value: "logiciel"
                        text: Utils.capitalize(qsTranslate("Tags", value))
                    }
                    MenuItem {
                        property string value: "mobilite"
                        text: Utils.capitalize(qsTranslate("Tags", value))
                    }
                    MenuItem {
                        property string value: "tech"
                        text: Utils.capitalize(qsTranslate("Tags", value))
                    }
                    MenuItem {
                        property string value: "next-inpact"
                        text: Utils.capitalize(qsTranslate("Tags", value))
                    }
                }

                property string fieldName: 'tag' // id not readable,

                // set filter value
                function set(value) {
                    setItemValue(this, value)
                }

                onCurrentItemChanged: {
                    save(fieldName, currentItem.value)
                }
            }
        }

    }

    Component.onCompleted: {
        filters = db.getConfig("articles.filters")
        refresh()

        complete = true
    }

    onStatusChanged: {
        if (status === PageStatus.Deactivating) {
            articlesModel.update()
        }
    }

    // refresh QML fields according to filters map (read from db).
    function refresh() {
        for(var i in sets.children) {
            sets.children[i].set(filters[sets.children[i].fieldName])
        }
    }

    // helper function to set ComboBox active MenuItem.
    function setItemValue(obj, value) {
        for(var i in obj.menu.children) {
            if (obj.menu.children[i].value === value) {
                obj.currentIndex = i
            }
        }
    }

    // saving filter value into db.
    function save(filter, value) {
        if (!complete) {
            return
        }

        filters[filter] = value
        db.setConfig('articles.filters.'+filter, value.toLowerCase())
    }
}
