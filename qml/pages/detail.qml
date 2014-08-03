
import QtQuick 2.0
import Sailfish.Silica 1.0
//import QtWebKit 3.0

Page {
    id: detail

    onStatusChanged: {
        if (status == PageStatus.Active) {
            pageStack.pushAttached(Qt.resolvedUrl("comments.qml"), {})
        }
    }


    SilicaWebView {
        id: detailview

        header: PageHeader {

        }


        url: "http://m.nextinpact.com/news/88991-freebox-player-free-lance-sdk-applicatif-base-sur-qml.htm" //http://linuxfr.org"
        //forwardNavigation: false

        //html: "<html><body><title>Yeah!!!</title></body></html>"
        anchors {
            top: parent.top
            left: parent.left
            right: parent.right
            bottom: parent.bottom

        }
    }


    Component.onCompleted: {
        detailview.loadHtml("<html><body><h1>Yeah!!!</h1></body></html> <b>ploploplop</b>")

        // context is persistent between pages
        console.log("context state=" + appwin.context2.state['key1']);
    }

}
