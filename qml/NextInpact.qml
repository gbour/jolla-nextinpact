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

import "pages"

ApplicationWindow
{
    id: appwin

    initialPage: Articles {}
    cover: Qt.resolvedUrl("cover/CoverPage.qml")


    Component.onCompleted: {
        var v7 = db.getConfig("v7")
        console.log("v7=",v7['migrated'])

        if (v7['migrated'] === undefined) {
            pageStack.push(Qt.resolvedUrl("pages/Migration.qml"), undefined, PageStackAction.Immediate)

            // we get list of 200 last articles
            scraper.sendMessage({action: 'scrap', page: 1, count: 200})
        } else if (db.cleanup()) {
            articlesModel.update()
        }
    }

    Timer {
        id: timer_dbcleanup
        interval: 60000*60*12 // 12 hours
        repeat: true
        running: true

        onTriggered: {
            if (db.cleanup()) {
                articlesModel.update()
            }
        }
    }

    WorkerScript {
        id: scraper
        source: Qt.resolvedUrl("logic/scrapers/articles.js")

        onMessage: function(m) {
            //console.log('articles::worker reply', Utils.dump(m));
            if (m.reply === 'counter') {
                return;
            } else if (m.reply === 'complete') {
                db.setConfig('v7.migrated', true)
                articlesModel.update()
                pageStack.pop()
                return;
            }

            articlesModel.v7MigrateArticle(m.article);
        }
    }
}


