import QtQuick 2.0
import Sailfish.Silica 1.0

ListItem {
    x: Theme.paddingSmall
    width: parent.width - 2*Theme.paddingSmall
    //height: childrenRect.height * 1.7
    // how it is computed ?
    //height: childrenRect.height * 2
    height: Math.max(icon.height, title.height+subtitle.height) + 15
    //implicitHeight: Math.max(icon.implicitHeight, (title.implicitHeight+subtitle.implicitHeight))

    property string link;

    Image {
        id: icon
        source: model.icon
        //width: parent.width*
        anchors {
            left: parent.left
            topMargin: 10
            //right: title.left
            //rightMargin: Theme.paddingSmall
        }
    }

    Label {
        id: title
        text: model.title
        font.pixelSize: Theme.fontSizeSmall - 4 //Tiny
        wrapMode: Text.WordWrap
        horizontalAlignment: Text.AlignJustify

        anchors {
            left: icon.right
            right: parent.right
            leftMargin: 5
        }
    }

    Label {
        id: timestamp
        text: model.timestamp
        font.pixelSize: Theme.fontSizeTiny  - 2
        color: "#ea8211"

        anchors {
            top: subtitle.top
            left: icon.right
            //top: title.bottom
            //bottom: icon.bottom
            leftMargin: 5
        }
    }

    Label {
        id: dash
        text: " - "
        font.pixelSize: Theme.fontSizeTiny  - 2
        font.italic: true
        styleColor: "#8a979d"

        anchors {
            top: subtitle.top //title.bottom
            left: timestamp.right
        }
    }

    Label {
        id: subtitle
        text: model.subtitle
        font.pixelSize: Theme.fontSizeTiny  //- 2 //8 //Theme.fontSizeExtraSmall
        font.italic: true
        styleColor: "#8a979d"
        wrapMode: Text.WordWrap
        horizontalAlignment: Text.AlignJustify

        anchors {
            //bottom: icon.bottom
            bottom: title.height+subtitle.height < 130 ? icon.bottom : undefined
            top: title.height+subtitle.height > 130 ? title.bottom : undefined
            topMargin: 5


            left: dash.right
            right: comments_counter.left
            rightMargin: 10
        }
    }

    Label {
        id: comments_counter
        text: model.comments
        font.pixelSize: Theme.fontSizeTiny - 2
        styleColor: "#8a979d"

        anchors {
            //top: title.bottom
            top: comments.top
            right: comments.left
            rightMargin: 5
        }
    }

    Image {
        id: comments
        source: 'qrc:/res/comments.png'
        anchors {
            //top: title.bottom
            bottom: icon.bottom
            right: parent.right
        }
    }
}
