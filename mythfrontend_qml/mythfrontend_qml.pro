#app version
VERSION = 0.0.7.alpha

PREFIX = /usr

include(../QmlVlc/QmlVlc.pri)
include(../SortFilterProxyModel/SortFilterProxyModel.pri)


DEFINES += APP_VERSION=\\\"$$VERSION\\\"

INCLUDEPATH += .. ../QmlVlc

LIBS += -lvlc

packagesExist(libVLCQtQml) {
    DEFINES += USE_VLCQT
    LIBS += -lVLCQtCore -lVLCQtQml
}


QT += qml quick sql xml webengine
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

SOURCES += main.cpp
SOURCES += sqlquerymodel.cpp databaseutils.cpp urlinterceptor.cpp settings.cpp mythutils.cpp downloadmanager.cpp
SOURCES += mythincrementalmodel.cpp recordingsmodel.cpp zmeventsmodel.cpp context.cpp logger.cpp
