#app version
VERSION = 0.0.14.alpha
BRANCH = master

PREFIX = /usr

include(../QmlVlc/QmlVlc.pri)
include(../SortFilterProxyModel/SortFilterProxyModel.pri)
include(../DownloadManager/quickdownload.pri)

DEFINES += APP_VERSION=\\\"$$VERSION\\\" GIT_BRANCH=\\\"$$BRANCH\\\"

INCLUDEPATH += .. ../QmlVlc ../mythfrontend_qml

LIBS += -lvlc

packagesExist(libVLCQtQml) {
    DEFINES += USE_VLCQT
    LIBS += -lVLCQtCore -lVLCQtQml
}

# for MDK SDK
INCLUDEPATH += ../mdk-sdk

QT += qml quick sql xml webengine
CONFIG += c++11
QMAKE_CXXFLAGS_RELEASE -= -Wdate-time

TEMPLATE = app

TARGET = mythlauncher_qml
target.path = $${PREFIX}/bin
INSTALLS = target

qml.path = $${PREFIX}/share/mythtv/qml
qml.files += launcher.qml

INSTALLS += qml

# Additional import path used to resolve QML modules in Qt Creator's code model
QML_IMPORT_PATH = Themes/Default ../ MenuThemes

QMAKE_CLEAN += $(TARGET)

# Input
HEADERS += ../mythfrontend_qml/databaseutils.h ../mythfrontend_qml/urlinterceptor.h ../mythfrontend_qml/settings.h
HEADERS += ../mythfrontend_qml/mythutils.h ../mythfrontend_qml/process.h ../mythfrontend_qml/downloadmanager.h
HEADERS += ../mythfrontend_qml/eventlistener.h ../mythfrontend_qml/context.h ../mythfrontend_qml/logger.h
HEADERS += ../mythfrontend_qml/mdkplayer.h ../mythfrontend_qml/mdkapi.h ../mythfrontend_qml/sqlquerymodel.h

SOURCES += main.cpp
SOURCES += ../mythfrontend_qml/databaseutils.cpp ../mythfrontend_qml/urlinterceptor.cpp ../mythfrontend_qml/settings.cpp
SOURCES += ../mythfrontend_qml/mythutils.cpp ../mythfrontend_qml/downloadmanager.cpp ../mythfrontend_qml/context.cpp
SOURCES += ../mythfrontend_qml/logger.cpp
SOURCES += ../mythfrontend_qml/mdkplayer.cpp ../mythfrontend_qml/mdkapi.cpp ../mythfrontend_qml/sqlquerymodel.cpp
