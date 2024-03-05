import QtQuick 2.0
import Base 1.0

BaseScreen
{
    property alias model: themedMenu.model

    defaultFocusItem: themedMenu.listView

    Component.onCompleted:
    {
        showTitle(true, model.title);
        showTime(true);
        showTicker(true);
        title.source = mythUtils.findThemeFile(model.logo);
        setHelp("https://mythqml.net/help/mainmenu.php#top");
    }

    BaseThemedMenu
    {
        id: themedMenu
        showWatermark: false;
    }
}
