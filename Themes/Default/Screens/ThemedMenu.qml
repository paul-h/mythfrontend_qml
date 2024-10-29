import QtQuick

import Base 1.0
import Dialogs 1.0
import Process 1.0

BaseScreen
{
    property alias model: themedMenu.model

    defaultFocusItem: themedMenu.listView

    Component.onCompleted:
    {
        showTitle(true, model.title);
        showTime(true);
        showTicker(true);
        showVideo(true);
        showImage(true);
        title.source = mythUtils.findThemeFile(model.logo);
        setHelp("https://mythqml.net/help/mainmenu.php#top");
    }

    BaseThemedMenu
    {
        id: themedMenu

    }
}

