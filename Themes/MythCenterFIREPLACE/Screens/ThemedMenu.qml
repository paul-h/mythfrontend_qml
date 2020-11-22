import QtQuick 2.0
import Base 1.0

BaseScreen
{
    property alias model: themedMenu.model

    defaultFocusItem: themedMenu.listView

    Component.onCompleted:
    {
        showTitle(true, model ? model.title : "");
        showTime(true);
        showTicker(true);
        title.source = model ? mythUtils.findThemeFile(model.logo) : ""
    }

    BaseThemedMenu
    {
        id: themedMenu
        showWatermark: false;
    }
}
