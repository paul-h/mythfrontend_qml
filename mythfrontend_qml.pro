PREFIX = /usr

#check QT major version
contains(QT_MAJOR_VERSION, 5) {
        error("Must build against Qt6")
}


# Additional import path used to resolve QML modules in Qt Creator's code model
QML_IMPORT_PATH = Themes/Default Models MenuThemes mythfrontend_qml

TEMPLATE = subdirs

SUBDIRS += mythcpp VLCPlugin mythfrontend_qml mythlauncher_qml

VLCPlugin.depends = mythcpp
