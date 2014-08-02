import QtQuick 2.0
import Sailfish.Silica 1.0

ListModel {

    ListElement {
        icon: 'qrc:/res/img1.jpg'
        title: "foo"
        subtitle: "bar"
        timestamp: "13:37"
        comments: 42
    }

    ListElement {
        icon: 'qrc:/res/img2.jpg'
        title: "Homer"
        subtitle: ""
        timestamp: ""
        comments: ""
    }

    ListElement {
        icon: 'qrc:/res/img3.jpg'
        section: 'Yesterday'
        title: "Very long title wrapped on multilines"
        subtitle: "and the subtitle is very long too, sooooo long long long"
        timestamp: "00:00"
        comments: 0
    }
}
