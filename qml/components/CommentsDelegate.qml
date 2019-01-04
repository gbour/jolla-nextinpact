import QtQuick 2.0
import Sailfish.Silica 1.0

ListItem {
    //id: itemDelegate

    x: Theme.horizontalPageMargin
    contentHeight: column.height + Theme.paddingMedium*2

    width: parent.width - 2 * Theme.horizontalPageMargin

    Column {
        id: column
        width: parent.width

        Row {
            id: row
            spacing: Theme.paddingMedium
            width: parent.width

            Label {
                id: id
                text: '#'+model.id
                font.pixelSize: Theme.fontSizeSmall
                color: Theme.primaryColor
            }

            Label {
                id: author
                text: model.author
                color: Theme.highlightColor
                font.pixelSize: Theme.fontSizeSmall

                property int rRight: x + contentWidth
            }

            Label {
                id: date
                text: model.date
                color: Theme.primaryColor
                font.pixelSize: Theme.fontSizeExtraSmall
                font.italic: true

                width: parent.width - author.width - id.width - Theme.horizontalPageMargin
                height: parent.height
                horizontalAlignment: Qt.AlignRight
                verticalAlignment: Qt.AlignBottom

                // date is only visible if it fits w/ id & author
                // or following date field is displayed (outside of Column)
                property int rLeft: parent.x + parent.width - contentWidth
                visible: rLeft > author.rRight
            }

        }

        Label {
            text: model.date
            color: Theme.primaryColor
            font.pixelSize: Theme.fontSizeExtraSmall
            font.italic: true

            width: parent.width
            horizontalAlignment: Qt.AlignRight

            visible: date.rLeft < author.rRight
        }

        Label {
            text: model.content
            color: Theme.secondaryColor
            wrapMode: Text.WordWrap
            textFormat: "RichText"
            linkColor: "#FF000000"

            verticalAlignment: Qt.AlignJustify
            font.pixelSize: Theme.fontSizeExtraSmall

            width: parent.width

            // links opened in a browser
            onLinkActivated: Qt.openUrlExternally(link)
        }
    }

/*
    Rectangle {
        x: author.x + author.contentWidth
        y: author.y
        width: 20
        height: 20
        color: 'red'
    }

    Rectangle {
        x: date.parent.x + date.parent.width - date.contentWidth
        y: author.y
        width: 20
        height: 20
        color: 'blue'
    }

    Component.onCompleted: {
    }
*/
}
