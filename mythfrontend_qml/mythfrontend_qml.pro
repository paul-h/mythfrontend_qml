#app version
VERSION = 0.0.13.alpha
BRANCH = stable

PREFIX = /usr

include(../QmlVlc/QmlVlc.pri)
include(../SortFilterProxyModel/SortFilterProxyModel.pri)
include(../DownloadManager/quickdownload.pri)

DEFINES += APP_VERSION=\\\"$$VERSION\\\" GIT_BRANCH=\\\"$$BRANCH\\\"

INCLUDEPATH += .. ../QmlVlc

LIBS += -lvlc

packagesExist(libVLCQtQml) {
    DEFINES += USE_VLCQT
    LIBS += -lVLCQtCore -lVLCQtQml
}

# for MDK SDK
INCLUDEPATH += ../mdk-sdk/

QT += qml quick sql xml webengine svg
CONFIG += c++11

TEMPLATE = app

TARGET = mythfrontend_qml
target.path = $${PREFIX}/bin
INSTALLS = target

qml.path = $${PREFIX}/share/mythtv/qml
qml.files += ../Themes ../Models ../MenuThemes ../Scripts ../Streamlink main.qml Util.js

INSTALLS += qml

# Additional import path used to resolve QML modules in Qt Creator's code model
QML_IMPORT_PATH = Themes/Default ../ MenuThemes

QMAKE_CLEAN += $(TARGET)

# Input
HEADERS += sqlquerymodel.h databaseutils.h urlinterceptor.h settings.h mythutils.h process.h downloadmanager.h
HEADERS += mythincrementalmodel.h recordingsmodel.h zmeventsmodel.h eventlistener.h context.h logger.h
HEADERS += mdkapi.h mdkplayer.h svgimage.h

SOURCES += main.cpp
SOURCES += sqlquerymodel.cpp databaseutils.cpp urlinterceptor.cpp settings.cpp mythutils.cpp downloadmanager.cpp
SOURCES += mythincrementalmodel.cpp recordingsmodel.cpp zmeventsmodel.cpp context.cpp logger.cpp
SOURCES += mdkapi.cpp mdkplayer.cpp svgimage.cpp
