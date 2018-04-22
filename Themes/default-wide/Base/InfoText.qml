import QtQuick 2.0

Item
{
    id: root
    property string text: ""
    property string fontFamily: theme.infoFontFamily
    property int    fontPixelSize: xscale(theme.infoFontPixelSize)
    property bool   fontBold: theme.infoFontBold
    property color  fontColor: theme.infoFontColor
    property int    horizontalAlignment: Text.AlignLeft
    property int    verticalAlignment: Text.AlignVCenter
    property double shadowAlpha: theme.infoShadowAlpha
    property color  shadowColor: theme.infoShadowColor
    property int    shadowXOffset: theme.infoShadowXOffset
    property int    shadowYOffset: theme.infoShadowYOffset
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
        clip: true
        elide: Text.ElideRight
        wrapMode: root.multiline ? Text.WordWrap : Text.NoWrap
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
        clip: true
        elide: Text.ElideRight
        wrapMode: root.multiline ? Text.WordWrap : Text.NoWrap
    }
}

