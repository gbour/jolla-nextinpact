/*
  Copyright (C) 2013 Jolla Ltd.
  Contact: Thomas Perl <thomas.perl@jollamobile.com>
  All rights reserved.

  You may use this file under the terms of BSD license as follows:

  Redistribution and use in source and binary forms, with or without
  modification, are permitted provided that the following conditions are met:
    * Redistributions of source code must retain the above copyright
      notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright
      notice, this list of conditions and the following disclaimer in the
      documentation and/or other materials provided with the distribution.
    * Neither the name of the Jolla Ltd nor the
      names of its contributors may be used to endorse or promote products
      derived from this software without specific prior written permission.

  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
  ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
  WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
  DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDERS OR CONTRIBUTORS BE LIABLE FOR
  ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
  (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
  LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
  ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
  (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

import QtQuick 2.0
import Sailfish.Silica 1.0


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

        model: ListModel {
        }

        section {
            property: 'section'
            delegate: SectionHeader {
                text: section
                height: Theme.itemSizeExtraSmall
            }
        }

        VerticalScrollDecorator {}

        delegate: ListItem {

            x: Theme.paddingSmall
            width: parent.width// - 2*Theme.paddingLarge
            height: childrenRect.height * 1.7
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

            Image {
                id: icon
                source: 'qrc:/res/img1.jpg'
                //width: parent.width*
                anchors {
                    left: parent.left                    
                    //right: title.left
                    //rightMargin: Theme.paddingSmall
                }
            }

            Label {
                id: title
                text: "plop ceci est une titre super long wrappé sur la ligne suivante"
                font.pixelSize: Theme.fontSizeSmall
                wrapMode: Text.WordWrap
                //horizontalAlignment: Text.AlignLeft
                anchors {
                    left: icon.right
                    right: parent.right
                    leftMargin: 5
                }
            }

            Label {
                id: timestamp
                text: "13:37"
                font.pixelSize: Theme.fontSizeExtraSmall
                color: "#ea8211"

                anchors {
                    left: icon.right
                    top: title.bottom
                }
            }

            Label {
                id: subtitle
                text: "- subtitle"
                font.pixelSize: Theme.fontSizeExtraSmall
                font.italic: true
                styleColor: "#8a979d"

                anchors {
                    top: title.bottom
                    left: timestamp.right
                }
            }

            Label {
                id: comments_counter
                text: "42"
                font.pixelSize: Theme.fontSizeExtraSmall
                styleColor: "#8a979d"

                anchors {
                    top: title.bottom
                    right: comments.left
                }
            }

            Image {
                id: comments
                source: 'qrc:/res/comments.png'
                anchors {
                    top: title.bottom
                    right: parent.right
                }
            }



        }

        Component.onCompleted: {
            model.append({})
            model.append({})
            model.append({'section': '2d section'})

        }

    }
}

