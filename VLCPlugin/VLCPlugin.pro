TEMPLATE = lib

CONFIG += plugin thread

TARGET = access_myth_plugin

INCLUDEPATH +=  ../mythcpp

QMAKE_CXXFLAGS += $$system(pkg-config --cflags vlc-plugin) -Wall -Wextra -Wno-old-style-cast -fno-permissive
LIBS += $$system(pkg-config --libs vlc-plugin)  -L../mythcpp -lmythcpp #-lz -lm -lrt

#DEFINES += MODULE_STRING="myth"

# Input
SOURCES += myth.cpp

target.path = $$system(pkg-config --variable pluginsdir vlc-plugin)/access
INSTALLS += target
