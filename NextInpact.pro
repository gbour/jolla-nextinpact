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

VERSION = 0.6.2
DEFINES += APP_VERSION=\\\"$$VERSION\\\"
DEFINES += BUILD_DATE='"$(shell date '+%s')"'

DBVERSION = 2
DBNAME = 'nextinpact.db'
#DBNAME = 'nextinpact-pre.db'
#DBNAME = 'nextinpact-dev.db'
DEFINES += DB_VERSION=$$DBVERSION
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
    qml/pages/About.qml \
    qml/pages/detail.qml \
    qml/pages/comments.qml \
    qml/pages/ArticleList.qml \
    qml/pages/ArticleDelegate.qml \
    qml/models/ArticleItem.qml \
    qml/logic/context.js \
    qml/logic/scraper.js \
    qml/lib/utils.js \
    qml/lib/iso8859-15.js \
    qml/lib/htmlparser2.js \
    res/comments.png \
    res/img1.jpg \
    res/img2.jpg \
    res/img3.jpg \
    res/logo-big.png \
    translations/*.ts \
    rpm/NextInpact.spec \
    rpm/NextInpact.yaml \
    rpm/NextInpact.changes \
    LICENSE \
    NextInpact.desktop

# to disable building translations every time, comment out the
# following CONFIG line
CONFIG += sailfishapp_i18n
TRANSLATIONS += translations/NextInpact-fr.ts

RESOURCES += \
    resources.qrc

QT += sql


