
import QtQuick 2.0
import Sailfish.Silica 1.0
import "pages"
import "logic/context.js" as Context

ApplicationWindow
{
    id: appwin

    initialPage: ArticleList {}
    cover: Qt.resolvedUrl("cover/CoverPage.qml")

    // static variable over all application
    property var context : Context;
}


