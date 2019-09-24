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
TARGET = harbour-nextinpact

VERSION = 0.6.6-pre1
DEFINES += APP_VERSION=\\\"$$VERSION\\\"
DEFINES += BUILD_DATE='"$(shell date '+%s')"'

DBVERSION = 3
DBNAME = 'nextinpact.db'
#DBNAME = 'nextinpact-pre.db'
#DBNAME = 'nextinpact-dev.db'
DEFINES += DB_VERSION=$$DBVERSION
DEFINES += DB_NAME=\\\"$$DBNAME\\\"

CONFIG += sailfishapp c++14

HEADERS += \
    src/database.h \
    src/ArticleListModel.h \
    src/CommentListModel.h \
    src/DbUpdater.h

SOURCES += src/NextInpact.cpp \
    src/database.cpp \
    src/ArticleListModel.cpp \
    src/CommentListModel.cpp \
    src/DbUpdater.cpp

OTHER_FILES += qml/NextInpact.qml \
    qml/cover/CoverPage.qml \
    qml/pages/About.qml \
    qml/pages/detail.qml \
    qml/pages/comments.qml \
    qml/pages/ArticleList.qml \
    qml/pages/ArticleDelegate.qml \
    qml/pages/Settings.qml \
    qml/pages/Stats.qml \
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
    LICENSE \
    icons

# to disable building translations every time, comment out the
# following CONFIG line
CONFIG += sailfishapp_i18n
TRANSLATIONS += \
    translations/harbour-nextinpact.ts \
    translations/harbour-nextinpact-fr.ts

RESOURCES += \
    resources.qrc

QT += sql dbus
PKGCONFIG += nemonotifications-qt5

SAILFISHAPP_ICONS += 86x86 108x108 128x128 172x172 256x256
DISTFILES += \
    harbour-nextinpact.desktop \
    icons/86x86/harbour-nextinpact.png \
    icons/256x256/harbour-nextinpact.png \
    icons/172x172/harbour-nextinpact.png \
    icons/128x128/harbour-nextinpact.png \
    icons/108x108/harbour-nextinpact.png \
    rpm/harbour-nextinpact.yaml \
    rpm/harbour-nextinpact.changes


