import QtQuick

Item
{
    id: listHighlight

    width: ListView.view ? ListView.view.width : 500
    y: ListView.view.currentItem.y

    Behavior on y
    {
        SpringAnimation
        {
            spring: 5
            damping: 0.2
            duration: 150
        }
    }
    height: ListView.view ? ListView.view.currentItem.height : 50
    Rectangle
    {
        width: parent.width
        height: parent.height

        color:
        {
            if (parent.ListView.view && parent.ListView.view.focus)
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

