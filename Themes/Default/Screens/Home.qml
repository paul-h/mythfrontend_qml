import QtQuick 2.0
import Base 1.0

BasePanel
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
