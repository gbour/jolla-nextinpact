
import QtQuick 2.0
import Sailfish.Silica 1.0
//import QtWebKit 3.0

Page {
    id: detail

    // url is provided when clicking list item in articles list view
    property alias url: detailview.url;

    onStatusChanged: {
        if (status == PageStatus.Active) {
            pageStack.pushAttached(Qt.resolvedUrl("comments.qml"), {})
        }
    }


    SilicaWebView {
        id: detailview

        header: PageHeader {

        }


        url: ""
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
        //detailview.loadHtml("<html><body><h1>Yeah!!!</h1></body></html> <b>ploploplop</b>")

        // context is persistent between pages
        //console.log("context state=" + appwin.context2.state['key1']);
        console.log('URL=' + detailview.url + ',' + detail.url);
    }

}
