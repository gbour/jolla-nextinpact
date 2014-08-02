
import QtQuick 2.0
import Sailfish.Silica 1.0

CoverBackground {
    Image {
        source: 'qrc:/res/img3.jpg'

        anchors {
            horizontalCenter: parent.horizontalCenter
            top: parent.top
            topMargin: 10
        }
    }

    Label {
        id: label
        anchors.centerIn: parent
        text: 42 + " " + qsTr("Unread")
    }


    CoverActionList {
        id: coverAction

        CoverAction {
            iconSource: "image://theme/icon-cover-refresh"
        }
    }
}


