#app version
VERSION = 0.0.10.alpha
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
MDK_SDK = $$PWD/../mdk-sdk
INCLUDEPATH += $$MDK_SDK/include
contains(QT_ARCH, x.*64) {
  android: MDK_ARCH = x86_64
  else:linux: MDK_ARCH = amd64
  else: MDK_ARCH = x64
} else:contains(QT_ARCH, .*86) {
  MDK_ARCH = x86
} else:contains(QT_ARCH, a.*64.*) { # arm64-v8a
  android: MDK_ARCH = arm64-v8a
  else: MDK_ARCH = arm64
} else:contains(QT_ARCH, arm.*) {
  android: MDK_ARCH = armeabi-v7a
  else:linux: MDK_ARCH = armhf
  else: MDK_ARCH = arm
}

mdk.path = $${PREFIX}/lib/mythqml
mdk.files += ../mdk-sdk/lib/$$MDK_ARCH/*

macx {
  LIBS += -F$$MDK_SDK/lib -F/usr/local/lib -framework mdk
} else {
  LIBS += -L$$MDK_SDK/lib/$$MDK_ARCH -lmdk
  win32: LIBS += -L$$PWD/../../mdk-sdk/bin/$$MDK_ARCH # qtcreator will prepend $$LIBS to PATH to run targets
}

linux: LIBS += -Wl,-rpath-link,$$MDK_SDK/lib/$$MDK_ARCH # for libc++ symbols
linux: LIBS += -Wl,-rpath,$$mdk.path/$$MDK_ARCH

QT += qml quick sql xml webengine
CONFIG += c++11

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
HEADERS += ../mythfrontend_qml/mdkplayer.h

SOURCES += main.cpp
SOURCES += ../mythfrontend_qml/databaseutils.cpp ../mythfrontend_qml/urlinterceptor.cpp ../mythfrontend_qml/settings.cpp
SOURCES += ../mythfrontend_qml/mythutils.cpp ../mythfrontend_qml/downloadmanager.cpp ../mythfrontend_qml/context.cpp
SOURCES += ../mythfrontend_qml/logger.cpp
SOURCES += ../mythfrontend_qml/mdkplayer.cpp
