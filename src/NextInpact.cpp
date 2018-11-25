/*
  Copyright (C) 2013 Jolla Ltd.
  Contact: Thomas Perl <thomas.perl@jollamobile.com>
  All rights reserved.

  You may use this file under the terms of BSD license as follows:

  Redistribution and use in source and binary forms, with or without
  modification, are permitted provided that the following conditions are met:
    * Redistributions of source code must retain the above copyright
      notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright
      notice, this list of conditions and the following disclaimer in the
      documentation and/or other materials provided with the distribution.
    * Neither the name of the Jolla Ltd nor the
      names of its contributors may be used to endorse or promote products
      derived from this software without specific prior written permission.

  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
  ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
  WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
  DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDERS OR CONTRIBUTORS BE LIABLE FOR
  ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
  (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
  LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
  ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
  (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
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

#include <src/database.h>
#include <src/ArticleListModel.h>

int main(int argc, char *argv[])
{
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

    qDebug() << "locale: " << QLocale::system().name() << ", GIT_VERSION: " << GIT_VERSION;

    Database *db = new Database();
    qDebug() << "db:" << db;

    ArticleListModel *listModel  = new ArticleListModel();

    QTranslator translator;
    translator.load("NextInpact-"+ QLocale::system().name().split("_").first(),
                    SailfishApp::pathTo("translations").path());
    app->installTranslator(&translator);

    QQuickView *view = SailfishApp::createView();
    view->rootContext()->setContextProperty("APP_VERSION", APP_VERSION);
    view->rootContext()->setContextProperty("GIT_VERSION", GIT_VERSION);

    QDateTime buildat = QDateTime::fromMSecsSinceEpoch(qint64(BUILD_DATE)*1000);
    view->rootContext()->setContextProperty("BUILD_DATE" , buildat.toString(Qt::DefaultLocaleShortDate));
    view->rootContext()->setContextProperty("db", db);
    view->rootContext()->setContextProperty("articlesListModel", listModel);

    // NOTE: view source MUST be set AFTER properties, or props will not be
    // visible
    view->setSource(SailfishApp::pathTo("qml/NextInpact.qml"));
    view->show();

    return app->exec();
}

