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

VERSION = 0.5
DEFINES += APP_VERSION=\\\"$$VERSION\\\"
DEFINES += BUILD_DATE='"$(shell date '+%s')"'

# $$system() is executed when qmake generates Makefile
# $(shell) is executed as Makefile runtime
# Jolla qtcreator copy files in a dedicated build directory outside of git tree
#DEFINES += GIT_VERSION='\\\"$(shell git symbolic-ref --short HEAD $$_PRO_FILE_PWD_)/$(shell git describe --always $$_PRO_FILE_PWD_)\\\"'
DEFINES += GIT_VERSION='\\\"$$system(git symbolic-ref --short HEAD)/$$system(git describe --always)\\\"'

CONFIG += sailfishapp

SOURCES += src/NextInpact.cpp \
    src/database.cpp

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

HEADERS += \
    src/database.h

