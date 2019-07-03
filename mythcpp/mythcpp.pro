TEMPLATE = lib

CONFIG += plugin thread

TARGET = mythcpp

INCLUDEPATH += private private/mythdto private/os

QMAKE_CXXFLAGS += -Wall -Wextra -Wno-old-style-cast -fno-permissive
LIBS += -lz -lm -lrt

# mythcpp
HEADERS += mythcontrol.h mythdebug.h mytheventhandler.h
HEADERS += mythfileplayback.h mythintrinsic.h mythlivetvplayback.h
HEADERS += mythlocked.h mythrecordingplayback.h mythsharedptr.h
HEADERS += mythstream.h mythtypes.h mythwsapi.h mythwsstream.h

HEADERS += proto/mythprotobase.h proto/mythprotoevent.h
HEADERS += proto/mythprotomonitor.h proto/mythprotoplayback.h
HEADERS += proto/mythprotorecorder.h proto/mythprototransfer.h

HEADERS += private/atomic.h private/builtin.h private/compressor.h
HEADERS += private/cppdef.h private/debug.h private/jsonparser.h
HEADERS += private/mythjsonbinder.h private/sajson.h private/securesocket.h
HEADERS += private/socket.h private/uriparser.h private/urlencoder.h
HEADERS += private/wscontent.h private/wsrequest.h private/wsresponse.h

HEADERS += private/mythdto/artwork.h private/mythdto/capturecard.h
HEADERS += private/mythdto/channel.h private/mythdto/cutting.h private/mythdto/list.h
HEADERS += private/mythdto/mythdto.h private/mythdto/mythdto75.h private/mythdto/mythdto76.h
HEADERS += private/mythdto/mythdto82.h private/mythdto/mythdto85.h private/mythdto/program.h
HEADERS += private/mythdto/recording.h private/mythdto/recordschedule.h private/mythdto/version.h
HEADERS += private/mythdto/videosource.h


SOURCES += mythcontrol.cpp mytheventhandler.cpp
SOURCES += mythfileplayback.cpp mythintrinsic.cpp mythlivetvplayback.cpp
SOURCES += mythlocked.cpp mythrecordingplayback.cpp
SOURCES += mythtypes.cpp mythwsapi.cpp mythwsstream.cpp

SOURCES += proto/mythprotobase.cpp proto/mythprotoevent.cpp
SOURCES += proto/mythprotomonitor.cpp proto/mythprotoplayback.cpp
SOURCES += proto/mythprotorecorder.cpp proto/mythprototransfer.cpp

SOURCES += private/builtin.c private/compressor.cpp
SOURCES += private/debug.cpp private/jsonparser.cpp
SOURCES += private/mythjsonbinder.cpp private/sajson.h private/securesocket.cpp
SOURCES += private/socket.cpp private/uriparser.cpp
SOURCES += private/wscontent.cpp private/wsrequest.cpp private/wsresponse.cpp

SOURCES += private/mythdto/mythdto.cpp

inc.path   = /usr/include/mythtv/libmythcpp
inc.files  = mythcontrol.h mythdebug.h mytheventhandler.h
inc.files += mythfileplayback.h mythintrinsic.h mythlivetvplayback.h
inc.files += mythlocked.h mythrecordingplayback.h mythsharedptr.h
inc.files += mythstream.h mythtypes.h mythwsapi.h mythwsstream.h

inc2.path  = /usr/include/mythtv/libmythcpp/proto
inc2.files += proto/mythprotobase.h proto/mythprotoevent.h
inc2.files += proto/mythprotomonitor.h proto/mythprotoplayback.h
inc2.files += proto/mythprotorecorder.h proto/mythprototransfer.h

target.path = /usr/lib
INSTALLS += target inc inc2
