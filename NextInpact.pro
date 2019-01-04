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

VERSION = 0.6.1
DEFINES += APP_VERSION=\\\"$$VERSION\\\"
DEFINES += BUILD_DATE='"$(shell date '+%s')"'

DBVERSION = 2
DBNAME = 'nextinpact.db'
DEFINES += DB_VERSION=\\\"$$DBVERSION\\\"
DEFINES += DB_NAME=\\\"$$DBNAME\\\"

CONFIG += sailfishapp

SOURCES += src/NextInpact.cpp \
    src/database.cpp \
    src/ArticleListModel.cpp \
    src/CommentListModel.cpp

OTHER_FILES += \
    qml/cover/CoverPage.qml \
    rpm/NextInpact.spec \
    rpm/NextInpact.yaml \
    translations/*.ts \
    NextInpact.desktop \
    qml/models/ArticleItem.qml \
    res/comments.png \
    res/img1.jpg \
    res/img2.jpg \
    res/img3.jpg \
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
    src/database.h \
    src/ArticleListModel.h \
    src/CommentListModel.h

DISTFILES += \
    qml/NextInpact.qml \
    qml/logic/scrapers/article.js \
    qml/logic/scrapers/comments.js \
    qml/components/CommentsDelegate.qml \
    qml/components/ArticlesDelegate.qml \
    qml/pages/Comments.qml \
    qml/pages/Article.qml \
    qml/pages/Articles.qml \
    qml/pages/BriefArticle.qml
