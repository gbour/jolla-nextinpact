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
import "../models"

Page {
    id: articles

    // To enable PullDownMenu, place our content in a SilicaFlickable
    SilicaListView {
        id: mylistview
        anchors.fill: parent

        // PullDownMenu and PushUpMenu must be declared in SilicaFlickable, SilicaListView or SilicaGridView
        PullDownMenu {
            MenuItem {
                text: qsTr("about")
                onClicked: pageStack.push(Qt.resolvedUrl("about.qml"))
            }
            MenuItem {
                text: qsTr("refresh")
                //onClicked: pageStack.push(Qt.resolvedUrl("about.qml"))
                onClicked: {
                    console.log("refreshing articles list...");
                    mylistview.model.init();
                }
            }

        }
        // Tell SilicaFlickable the height of its content.
        //contentHeight: column.height

        spacing: Theme.paddingMedium

        header: PageHeader {
            //title: ""
        }

/*
        Row {
            spacing: Theme.paddingLarge

            anchors.horizontalCenter: parent.horizontalCenter

            BusyIndicator {
                running: true
                size: BusyIndicatorSize.Medium
                anchors.verticalCenter: parent.verticalCenter
            }

            anchors.topMargin: 5
            anchors.bottomMargin: 5
        }
*/
        /*
        model: ListModel {
            ListElement {
                title: "foo"
            }

            ListElement {
                title: "Homer"
            }
        }
        */
        model: ArticleItem {}
        delegate: ArticleDelegate {
            onClicked: {
                console.log("clicked on " + model.link);
                var params = {
                    url: model.link
                }

                pageStack.push(Qt.resolvedUrl("detail.qml"), params, PageStackAction.Animated)
            }

        }

        section {
            property: 'section'
            delegate: SectionHeader {
                text: section
                height: Theme.itemSizeExtraSmall
            }
        }

        VerticalScrollDecorator {}



        Component.onCompleted: {
            /*
            model.append({})
            model.append({})
            model.append({'section': '2d section'})
            */
            console.log("ArticleList load complete");

            // initialize JS context
            appwin.context.init();
            console.log("context state=" + appwin.context.state['key1']);

            //appwin.context.refresh();
            model.init();
        }

    }
}

