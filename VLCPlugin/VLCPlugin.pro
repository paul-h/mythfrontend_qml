TEMPLATE = lib

CONFIG += plugin thread

TARGET = access_myth_plugin

INCLUDEPATH += /usr/include/vlc/plugins

QMAKE_CFLAGS += $$system(pkg-config --cflags vlc-plugin)
LIBS += $$system(pkg-config --libs vlc-plugin)

#DEFINES += MODULE_STRING="myth"

# Input
SOURCES += myth.c

target.path = $$system(pkg-config --variable pluginsdir vlc-plugin)
INSTALLS += target
