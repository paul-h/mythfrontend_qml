import QtQuick 2.0
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
        title.source = mythUtils.findThemeFile(model.logo)
    }

    BaseThemedMenu
    {
        id: themedMenu

    }
}

