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
        showVideo(false);
        //showSlideShow(true);
        title.source = mythUtils.findThemeFile(model.logo);
    }

    BaseThemedMenu
    {
        id: themedMenu
        showWatermark: false;
    }
}
