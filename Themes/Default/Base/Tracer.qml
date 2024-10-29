import QtQuick

Item
{
    id: root
    anchors.fill: parent
    anchors.margins: 1
    visible: settings.showTextBorder
    property color color: Qt.rgba(Math.random(), Math.random(), Math.random(), 1)

    Rectangle
    {
        anchors.fill: parent
        color: 'transparent'
        border.color: root.color
        border.width: 1
        opacity: 0.8
    }
}
