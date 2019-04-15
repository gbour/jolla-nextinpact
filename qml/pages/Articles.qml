/*
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
//import "../lib/utils.js" as Utils
import "../logic/scrapers/articles.js" as Scraper
import "../logic/scrapers/brief.js"    as BriefScraper

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
                onClicked: mylistview.refresh(true)
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
                    artid: model.id,
                    type: model.type,
                    url: model.link
                }

                var target = "Article.qml"
                if (model.link.indexOf("-lebrief-") > 0) {
                    target = "BriefArticle.qml"
                }

                pageStack.push(Qt.resolvedUrl(target), params, PageStackAction.Animated)
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

            refresh(false);
        }

        function refresh(showLoader) {
            console.log("refreshing articles list...");

            loader.visible = showLoader; loader_bi.running = showLoader;

            var briefScraper = new BriefScraper.Brief();
            var fnLeBrief = function(root) {

                return function(briefs) {
                    //console.log('root =', root, Utils.dump(root), '= briefs');

                    briefs.forEach(function(brief) {
                        brief.type   = 1;

                        brief.parent = root.id;
                        ['date','timestamp','icon'].forEach(function(field) { brief[field] = root[field]; });
                        // we use date field milliseconds to reflect Lebrief articles correct order
                        brief.date.setMilliseconds(brief.position);

                        //console.log(Utils.dump(briefs[i]));
                        db.articleAdd(brief);
                    })

                    articlesListModel.updateModel()
                }
            }

            var scraper = new Scraper.Articles();
            context.load(scraper.url({page: 1}), scraper, function(articles) {
                // insert into db
                //for(var idx in articles) {
                articles.forEach(function(article) {
                    //console.log(article.comments, article.title)

                    if (article.link.indexOf("-lebrief-") > 0) {
                        briefScraper.fetch(article.link, fnLeBrief(article));
                        article.type = 99;
                    }

                    db.articleAdd(article)
                });

                // notify list model to reload articles after db update
                articlesListModel.updateModel()

                // hide loader
                loader.visible = false; loader_bi.running = false;
            });
        }
    }
}

