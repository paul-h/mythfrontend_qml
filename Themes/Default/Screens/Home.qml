import QtQuick
import Base 1.0

BaseScreen
{
    defaultFocusItem: text

    Component.onCompleted:
    {
        showTitle(false, "");
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
        text: "Home - Coming Soon!!"
        anchors.fill: parent
        horizontalAlignment: Text.AlignHCenter
    }

    Keys.onLeftPressed: previousFocusItem.focus = true;
}
