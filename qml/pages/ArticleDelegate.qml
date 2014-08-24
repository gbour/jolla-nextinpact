import QtQuick 2.0
import Sailfish.Silica 1.0

ListItem {
    x: Theme.paddingSmall
    width: parent.width - 2*Theme.paddingSmall
    height: childrenRect.height * 1.7

    property string link;

    Image {
        id: icon
        source: model.icon
        //width: parent.width*
        anchors {
            left: parent.left
            //right: title.left
            //rightMargin: Theme.paddingSmall
        }
    }

    Label {
        id: title
        text: model.title
        font.pixelSize: Theme.fontSizeSmall
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
        font.pixelSize: Theme.fontSizeExtraSmall
        color: "#ea8211"

        anchors {
            left: icon.right
            top: title.bottom
        }
    }

    Label {
        id: subtitle
        text: "- " + model.subtitle
        font.pixelSize: Theme.fontSizeExtraSmall
        font.italic: true
        styleColor: "#8a979d"
        wrapMode: Text.WordWrap
        horizontalAlignment: Text.AlignJustify

        anchors {
            top: title.bottom
            left: timestamp.right
            right: comments_counter.left
            rightMargin: 10
        }
    }

    Label {
        id: comments_counter
        text: model.comments
        font.pixelSize: Theme.fontSizeExtraSmall
        styleColor: "#8a979d"

        anchors {
            top: title.bottom
            right: comments.left
        }
    }

    Image {
        id: comments
        //source: '../../res/comments.png'
        source: 'qrc:/res/comments.png'
        anchors {
            top: title.bottom
            right: parent.right
        }
    }
}
