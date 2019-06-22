import QtQuick 2.0

Item
{
    id: root
    property string label: ""
    property string info: ""
    property int    horizontalAlignment: Text.AlignLeft
    property int    verticalAlignment: Text.AlignVCenter
    property bool   multiline: false

    x: xscale(50); y: 0; width: xscale(300); height: yscale(50)

    Rectangle
    {
        anchors.fill: parent
        color: "transparent"
        border.color: Qt.rgba(Math.random(), Math.random(), Math.random(), 1)
        border.width: 1
        visible: settings.showTextBorder
    }

    Text
    {
        id: text
        text: root.label + root.info
        textFormat: Text.RichText
        anchors.fill: parent
        horizontalAlignment: root.horizontalAlignment
        verticalAlignment: root.verticalAlignment
        clip: true
        elide: Text.ElideRight
        wrapMode: root.multiline ? Text.WordWrap : Text.NoWrap
    }
}

