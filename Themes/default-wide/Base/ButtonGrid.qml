import QtQuick 2.0

GridView
{
    id: root
    x: xscale(22)
    y: yscale(60)
    width: xscale(1280) - xscale(44)
    height: yscale(390)
    cellWidth: xscale(206)
    cellHeight: yscale(130)
    clip: true

    Component
    {
        id: highlight

        Rectangle
        {
            width: GridView.view ? GridView.view.width : 0
            height: yscale(50)
            color:
            {
                if (GridView.view && GridView.view.focus)
                {
                    theme.lvRowBackgroundFocusedSelected;
                }
                else
                {
                    theme.lvRowBackgroundSelected;
                }
            }
            border.color: theme.lvBackgroundBorderColor
            border.width: xscale(theme.lvBackgroundBorderWidth)
            radius: xscale(theme.lvBackgroundBorderRadius)
        }
    }

    highlight: highlight
    model: {}
    delegate: {}
    focus: true

    Keys.onPressed:
    {
        if (event.key === Qt.Key_PageDown || event.key === Qt.Key_PageUp)
        {
            var itemCount = (height / cellHeight) * (width / cellWidth);

            if (event.key === Qt.Key_PageDown)
                currentIndex = currentIndex + itemCount >= count ? count - 1 : currentIndex + itemCount;
            else
                currentIndex = currentIndex - itemCount < 0 ? currentIndex : currentIndex - itemCount;

            event.accepted = true;
        }
        else
        {
            event.accepted = false;
        }
    }
}
