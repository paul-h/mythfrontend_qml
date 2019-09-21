import QtQuick 2.0
import Base 1.0

BaseScreen
{
    defaultFocusItem: text

    Component.onCompleted:
    {
        showTitle(true, "Coming Soon!");
    }

    Image
    {
        id: name
        y: yscale(100)
        source: mythUtils.findThemeFile("images/comingsoon.png")
        anchors.horizontalCenter: parent.horizontalCenter
    }

    TitleText
    {
        id: text
        text: "Coming Soon!!"
        anchors.fill: parent
        horizontalAlignment: Text.AlignHCenter
    }
}
