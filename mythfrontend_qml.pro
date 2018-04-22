PREFIX = /usr

#check QT major version
contains(QT_MAJOR_VERSION, 4) {
        error("Must build against Qt5")
}

TEMPLATE = subdirs

SUBDIRS += mythfrontend_qml VLCPlugin
