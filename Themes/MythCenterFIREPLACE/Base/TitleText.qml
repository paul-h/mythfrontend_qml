import QtQuick 2.0

Item
{
    id: root
    property string text: ""
    property string fontFamily: theme.titleFontFamily
    property int    fontPixelSize: xscale(theme.titleFontPixelSize)
    property bool   fontBold: theme.titleFontBold
    property color  fontColor: theme.titleFontColor
    property int    horizontalAlignment: Text.AlignLeft
    property int    verticalAlignment: Text.AlignVCenter
    property double shadowAlpha: theme.titleShadowAlpha
    property color  shadowColor: theme.titleShadowColor
    property int    shadowXOffset: theme.titleShadowXOffset
    property int    shadowYOffset: theme.titleShadowYOffset
    property bool   multiline: false
    property int    elide: Text.ElideRight

    x: xscale(50); y : 0; width: xscale(300); height: yscale(50)

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
        id: shadow
        text: root.text
        //anchors.fill: parent
        font.family: root.fontFamily
        font.pixelSize: root.fontPixelSize
        font.bold: root.fontBold
        color: root.shadowColor
        opacity: root.shadowAlpha
        x: xscale(shadowXOffset); y: yscale(shadowYOffset); width: parent.width; height: parent.height
        horizontalAlignment: root.horizontalAlignment
        verticalAlignment: root.verticalAlignment
        visible: shadowXOffset != 0 || shadowYOffset != 0 ? true : false
        wrapMode: root.multiline ? Text.WordWrap : Text.NoWrap
        elide: root.elide
        clip: true
    }

    Text
    {
        id: text
        text: root.text
        anchors.fill: parent
        font.family: root.fontFamily
        font.pixelSize: root.fontPixelSize
        font.bold: root.fontBold
        color: root.fontColor
        x: 0; y: 0;  width: parent.width; height: parent.height
        horizontalAlignment: root.horizontalAlignment
        verticalAlignment: root.verticalAlignment
        wrapMode: root.multiline ? Text.WordWrap : Text.NoWrap
        elide: root.elide
        clip: true
    }
}
