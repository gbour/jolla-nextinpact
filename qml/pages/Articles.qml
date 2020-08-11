/*
    Copyright 2020 Guillaume Bour.
    This file is part of «NextINpact app».

    «NextINpact app» is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    any later version.

    «NextINpact app» is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with «NextINpact app».  If not, see <http://www.gnu.org/licenses/>.
*/

import QtQuick 2.0
import Sailfish.Silica 1.0

import "../components"
import "../lib/tags.js" as Tags
import "../lib/utils.js" as Utils

Page {
    id: articles

    property var filters
    property variant translations: [
        QT_TRANSLATE_NOOP("filters", "all-all"),
        QT_TRANSLATE_NOOP("filters", "all-articles"),
        QT_TRANSLATE_NOOP("filters", "all-lebrief"),
        QT_TRANSLATE_NOOP("filters", "read-all"),
        QT_TRANSLATE_NOOP("filters", "read-articles"),
        QT_TRANSLATE_NOOP("filters", "read-lebrief"),
        QT_TRANSLATE_NOOP("filters", "unread-all"),
        QT_TRANSLATE_NOOP("filters", "unread-articles"),
        QT_TRANSLATE_NOOP("filters", "unread-lebrief"),
    ]

    Row {
        id: loader
        visible: false

        spacing: Theme.paddingLarge
        anchors.horizontalCenter: parent.horizontalCenter
        height: 200

        BusyIndicator {
            id: loader_bi
            running: false
            size: BusyIndicatorSize.Large
            anchors.verticalCenter: parent.verticalCenter
        }
    }

    SilicaListView {
        id: mylistview
        anchors.fill: parent

        PullDownMenu {
            MenuItem {
                text: qsTr("About")
                onClicked: pageStack.push(Qt.resolvedUrl("About.qml"))
            }
            MenuItem {
                text: qsTr("Statistics")
                onClicked: pageStack.push(Qt.resolvedUrl("Stats.qml"))
            }
            MenuItem {
                text: qsTr("Settings")
                onClicked: pageStack.push(Qt.resolvedUrl("Settings.qml"))
            }
            MenuItem {
                text: qsTr("Filters")
                onClicked: pageStack.push(Qt.resolvedUrl("Filters.qml"))
            }
            MenuItem {
                text: qsTr("Refresh")
                onClicked: refresh(true)
            }

        }
        // Tell SilicaFlickable the height of its content.
        //contentHeight: column.height

        spacing: Theme.paddingMedium

        header: Column {
            id: header
            height: ph.height
            width: parent.width

            PageHeader {
                id: ph
                title: qsTranslate("filters", '%1-%2'.arg(filters['status'] || 'all').arg(filters['type'] || 'all'))
            } // PageHeader

            Tag {
                id: tag
                color: Tags.color(filters['tag'])
                text: qsTranslate("Tags", filters['tag'] || 'all')
                visible: (filters['tag'] || 'all') !== 'all'

                anchors {
                    top: ph.bottom

                    right: fav.visible ? fav.left : parent.right
                    rightMargin: 5
                }
            }

            Image {
                id: fav
                source: 'qrc:/res/heart-s.png'
                visible: filters['favorite'] === 'true'

                anchors {
                    top: ph.bottom
                    topMargin: -30
                    right: parent.right
                    rightMargin: 10
                }
            }
        } // header

        //model: ArticleItem {}
        model: articlesModel
        delegate: ArticlesDelegate {
            onClicked: {
                console.log("clicked on " + model.link + ',' + model.type);
                var params = {
                    model: model
                }

                pageStack.push(Qt.resolvedUrl("Article.qml"), params, PageStackAction.Animated)
            }
        }

        section {
            property: 'section'
            delegate: SectionHeader {
                text: new Date(section).toLocaleDateString();
                height: Theme.itemSizeExtraSmall
            }
        }

        VerticalScrollDecorator {}

        // displayed when no results
        Label {
            text: qsTr("No content")
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            visible: parent.count === 0

            anchors {
                fill: parent
            }
        }

        Component.onCompleted: {
            //refresh(true)
        }
    }

    onStatusChanged: {
        if (status === PageStatus.Activating) {
            filters = db.getConfig("articles.filters")
        }
    }

    property int _scrapCounter: 0;
    property bool loading: false

    WorkerScript {
        id: articleScraper
        source: Qt.resolvedUrl("../logic/scrapers/articles.js")

        // _onComplete is a callback function executed when articles scraping is over
        property var _onComplete

        onMessage: function(m) {
            //console.log('articles::worker reply', Utils.dump(m));
            if (m.reply === 'counter') {
                _scrapCounter += m.count;
                return;
            }
            // ignoring messages other than 'article'
            if (m.reply !== 'article') {
                return;
            }

            /*
            if (m.article.link.indexOf("-lebrief-") > 0) {
                m.article.type = 99;
                _scrapCounter += 1
                briefScraper.sendMessage({action: 'scrape', uri: m.article.link, parent: m.article});
            }
            */

            articlesModel.addArticle(m.article);
            _scrapCounter -= 1;
            //console.log('cnt=', _scrapCounter)
            if (_scrapCounter <= 0) {
                completed()
            }
        }

        function setOnComplete(onComplete) {
            _onComplete = onComplete
        }

        function completed() {
            articlesModel.update()
            // hide loader
            loader.visible = false; loader_bi.running = false;
            loading = false

            if (_onComplete !== undefined) {
                _onComplete()
            }
        }
    }
    /*
    WorkerScript {
        id: briefScraper
        source: Qt.resolvedUrl("../logic/scrapers/brief.js")
        onMessage: function(m) {
            //console.log('briefs::worker reply', Utils.dump(m));
            if (m.reply === 'counter') {
                _scrapCounter += m.count - 1;
                return;
            }

            articlesModel.addArticle(m.brief);
            _scrapCounter -= 1;
            //console.log('cnt=', _scrapCounter)
            if (_scrapCounter <= 0) {
                articleScraper.completed()
            }
        }
    }
    */

    /*
      NOTE: WorkerScript cannot be invoked from outsize (eg from CoverPage) directly
    */
    function refresh(showLoader, onComplete) {
        console.log("refreshing articles list...", loader, loader_bi);

        loader.visible = showLoader; loader_bi.running = showLoader;
        loading = true;
        articleScraper.setOnComplete(onComplete)
        articleScraper.sendMessage({action: 'scrap', page: 1})
    }
}

