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

CONFIG += sailfishapp

SOURCES += src/NextInpact.cpp

OTHER_FILES += qml/NextInpact.qml \
    qml/cover/CoverPage.qml \
    rpm/NextInpact.changes.in \
    rpm/NextInpact.spec \
    rpm/NextInpact.yaml \
    translations/*.ts \
    NextInpact.desktop \
    qml/pages/about.qml \
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
    qml/logic/scraper.js

# to disable building translations every time, comment out the
# following CONFIG line
CONFIG += sailfishapp_i18n
TRANSLATIONS += translations/NextInpact-de.ts

RESOURCES += \
    resources.qrc

