/*
    Copyright 2019 Guillaume Bour.
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
import "../lib/utils.js" as Utils

Page {
    id: articles

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
                text: qsTr("Refresh")
                onClicked: articleScraper.load(true)
            }

        }
        // Tell SilicaFlickable the height of its content.
        //contentHeight: column.height

        spacing: Theme.paddingMedium

        header: PageHeader {
            //title: ""
        }

        //model: ArticleItem {}
        model: articlesListModel
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

        Component.onCompleted: {
            // initialize JS context
            appwin.context.init();
            articleScraper.load(true)
        }
    }

    property int _scrapCounter: 0;

    WorkerScript {
        id: articleScraper
        source: Qt.resolvedUrl("../logic/scrapers/articles.js")
        onMessage: function(m) {
            //console.log('articles::worker reply', Utils.dump(m));
            if (m.reply === 'counter') {
                _scrapCounter += m.count;
                return;
            }

            if (m.article.link.indexOf("-lebrief-") > 0) {
                m.article.type = 99;
                _scrapCounter += 1
                briefScraper.sendMessage({action: 'scrape', uri: m.article.link, parent: m.article});
            }

            db.articleAdd(m.article);
            _scrapCounter -= 1;
            //console.log('cnt=', _scrapCounter)
            if (_scrapCounter <= 0) {
                articlesListModel.updateModel()
                // hide loader
                loader.visible = false; loader_bi.running = false;
            }
        }

        function load(showLoader) {
            console.log("refreshing articles list...");

            loader.visible = showLoader; loader_bi.running = showLoader;
            this.sendMessage({action: 'scrap', page: 1})
        }
    }
    WorkerScript {
        id: briefScraper
        source: Qt.resolvedUrl("../logic/scrapers/brief.js")
        onMessage: function(m) {
            //console.log('briefs::worker reply', Utils.dump(m));
            if (m.reply === 'counter') {
                _scrapCounter += m.count - 1;
                return;
            }

            db.articleAdd(m.brief);
            _scrapCounter -= 1;
            //console.log('cnt=', _scrapCounter)
            if (_scrapCounter <= 0) {
                articlesListModel.updateModel()
                // hide loader
                loader.visible = false; loader_bi.running = false;
            }
        }
    }
}

