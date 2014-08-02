
import QtQuick 2.0
import Sailfish.Silica 1.0
import "../models"

Page {
    id: articles

    // To enable PullDownMenu, place our content in a SilicaFlickable
    SilicaListView {
        anchors.fill: parent

        // PullDownMenu and PushUpMenu must be declared in SilicaFlickable, SilicaListView or SilicaGridView
        PullDownMenu {
            MenuItem {
                text: qsTr("about")
                onClicked: pageStack.push(Qt.resolvedUrl("about.qml"))
            }
            MenuItem {
                text: qsTr("settings")
                onClicked: pageStack.push(Qt.resolvedUrl("settings.qml"))
            }
            MenuItem {
                text: qsTr("refresh")
                onClicked: pageStack.push(Qt.resolvedUrl("about.qml"))
            }

        }
        // Tell SilicaFlickable the height of its content.
        //contentHeight: column.height

        spacing: Theme.paddingMedium

        header: PageHeader {
            //title: ""
        }

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
            menu: contextMenu

            onClicked: {
                pageStack.push(Qt.resolvedUrl("detail.qml"), {}, PageStackAction.Animated)
            }

            Component {
                id: contextMenu
                ContextMenu {
                    MenuItem {
                        text: 'I like it'
                    }
                    MenuItem {
                        text: 'Mark as read'
                    }
                    MenuItem {
                        text: 'Share'
                    }
                    MenuItem {
                        text: 'Download all comments'
                    }


                }
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
        }

    }
}

