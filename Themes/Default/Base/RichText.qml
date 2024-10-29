import QtQuick

Item
{
    id: root
    property string label: ""
    property string info: ""
    property alias  text: text.text
    property int    horizontalAlignment: Text.AlignLeft
    property int    verticalAlignment: Text.AlignVCenter
    property bool   multiline: false
    property int    labelFontPixelSize: Math.ceil(xscale(theme.labelFontPixelSize))
    property int    infoFontPixelSize: Math.ceil(xscale(theme.infoFontPixelSize))

    onLabelChanged: updateText();
    onInfoChanged: updateText();

    Connections
    {
        target: window
        function onWmultChanged() { updateText() }
    }

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

    function updateText()
    {
        text.text = '<p style="font-family: ' + theme.labelFontFamily +  '; font-size: ' + (labelFontPixelSize > 0 ? labelFontPixelSize : 16) + 'px; color: ' + theme.labelFontColor + '"> ' +
                    (theme.labelFontBold ? '<b>' : '') + label + (theme.labelFontBold ? '</b>' : '') +
                    '<span style="font-family: ' + theme.infoFontFamily +  '; font-size: ' + (infoFontPixelSize > 0 ? infoFontPixelSize : 16) + 'px; color: ' + theme.infoFontColor  +  '" >' +
                    (theme.infoFontBold ? '<b>' : '') + info + (theme.infoFontBold ? '</b>' : '') + '</span></p>';
    }
}

