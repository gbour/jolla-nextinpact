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

#ifdef QT_QML_DEBUG
#include <QtQuick>
#endif

#include <QGuiApplication>
#include <QQuickView>
#include <QTranslator>
#include <sailfishapp.h>
#include <QDebug>
#include <QDateTime>
#include <QQmlContext>

#include <QSslSocket>
#include <QSslConfiguration>

#include <src/database.h>
#include <src/ArticleListModel.h>
#include <src/CommentListModel.h>

int main(int argc, char *argv[])
{
    // declaring types
    const char *uri = "harbour.nextinpact";


    // SailfishApp::main() will display "qml/template.qml", if you need more
    // control over initialization, you can use:
    //
    //   - SailfishApp::application(int, char *[]) to get the QGuiApplication *
    //   - SailfishApp::createView() to get a new QQuickView * instance
    //   - SailfishApp::pathTo(QString) to get a QUrl to a resource file
    //
    // To display the view, call "show()" (will show fullscreen on device).
    QGuiApplication *app = SailfishApp::application(argc,argv); //SailfishApp::main(argc, argv);
    app->setApplicationVersion(APP_VERSION);

    qDebug() << "locale: " << QLocale::system().name();

    // Weird bug. Appears on arm only (ok in the emulator)
    // icons loading failed with 'QML Image: SSL handshake failed), while there was no issue
    // loading articles (w/ XmlHttpRequest).
    // Maybe due to unknown CA?
    // Dirty fix: we disable peer certificate verification (while connection remains encrypted).
    QSslConfiguration conf = QSslConfiguration::defaultConfiguration();
    conf.setPeerVerifyMode(QSslSocket::VerifyNone);
    QSslConfiguration::setDefaultConfiguration(conf);

    Database *db = new Database();
    qDebug() << "db:" << db;

    ArticleListModel *listModel  = new ArticleListModel(0, db->getDatabase());
    CommentListModel *commentsModel = new CommentListModel(0, db->getDatabase());

    QTranslator translator;
    translator.load("NextInpact-"+ QLocale::system().name().split("_").first(),
                    SailfishApp::pathTo("translations").path());
    app->installTranslator(&translator);

    QQuickView *view = SailfishApp::createView();
    view->rootContext()->setContextProperty("APP_VERSION", APP_VERSION);

    QDateTime buildat = QDateTime::fromMSecsSinceEpoch(qint64(BUILD_DATE)*1000);
    view->rootContext()->setContextProperty("BUILD_DATE" , buildat.toString(Qt::DefaultLocaleShortDate));
    view->rootContext()->setContextProperty("db", db);
    view->rootContext()->setContextProperty("articlesModel", listModel);
    view->rootContext()->setContextProperty("commentsModel", commentsModel);

    // NOTE: view source MUST be set AFTER properties, or props will not be
    // visible
    view->setSource(SailfishApp::pathTo("qml/NextInpact.qml"));
    view->show();

    return app->exec();
}

