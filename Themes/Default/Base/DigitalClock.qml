import QtQuick 2.0

Item
{
    id: clock
    property string format: "ddd MMMM d yyyy , hh:mm ap"
    width: 200
    height: 40

    TitleText
    {
        id: time
        fontFamily: theme.clockFontFamily
        fontPixelSize: xscale(theme.clockFontPixelSize)
        fontBold: theme.clockFontBold
        fontColor: theme.clockFontColor
        horizontalAlignment: Text.AlignRight
        verticalAlignment: Text.AlignVCenter
        shadowAlpha: theme.clockShadowAlpha
        shadowColor: theme.clockShadowColor
        shadowXOffset: theme.clockShadowXOffset
        shadowYOffset: theme.clockShadowYOffset
        text: Qt.formatDateTime(new Date(), parent.format)

        anchors.fill: parent

        function timeChanged()
        {
            time.text = Qt.formatDateTime(new Date(), parent.format)
        }

        Timer
        {
            interval: 500; running: true; repeat: true;
            onTriggered: time.timeChanged()
        }
    }
}

