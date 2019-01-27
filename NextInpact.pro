# NOTICE:
#
# Application name defined in TARGET has a corresponding QML filename.
# If name defined in TARGET is changed, the following needs to be done
# to match new name:
#   - corresponding QML filename must be changed
#   - desktop icon filename must be changed
#   - desktop filename must be changed
#   - icon definition filename in desktop file must be changed
#   - translation filenames have to be changed

# The name of your application
TARGET = NextInpact

VERSION = 0.6.2-pre1
DEFINES += APP_VERSION=\\\"$$VERSION\\\"
DEFINES += BUILD_DATE='"$(shell date '+%s')"'

DBVERSION = 2
DBNAME = 'nextinpact-pre.db'
DEFINES += DB_VERSION=\\\"$$DBVERSION\\\"
DEFINES += DB_NAME=\\\"$$DBNAME\\\"

CONFIG += sailfishapp

HEADERS += \
    src/database.h \
    src/ArticleListModel.h \
    src/CommentListModel.h

SOURCES += src/NextInpact.cpp \
    src/database.cpp \
    src/ArticleListModel.cpp \
    src/CommentListModel.cpp

OTHER_FILES += qml/NextInpact.qml \
    qml/cover/CoverPage.qml \
    rpm/NextInpact.spec \
    rpm/NextInpact.yaml \
    translations/*.ts \
    NextInpact.desktop \
    qml/pages/detail.qml \
    qml/pages/comments.qml \
    qml/models/ArticleItem.qml \
    qml/pages/ArticleDelegate.qml \
    res/comments.png \
    res/img1.jpg \
    res/img2.jpg \
    res/img3.jpg \
    qml/pages/ArticleList.qml \
    qml/logic/context.js \
    qml/lib/htmlparser2.js \
    qml/logic/scraper.js \
    qml/lib/iso8859-15.js \
    res/logo-big.png \
    LICENSE \
    rpm/NextInpact.changes \
    qml/pages/About.qml \
    qml/lib/utils.js

# to disable building translations every time, comment out the
# following CONFIG line
CONFIG += sailfishapp_i18n
TRANSLATIONS += translations/NextInpact-fr.ts

RESOURCES += \
    resources.qrc

QT += sql


