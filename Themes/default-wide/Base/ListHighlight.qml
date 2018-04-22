import QtQuick 2.0

Component
{
    id: listHighlight

    Rectangle
    {
        width: ListView.view ? ListView.view.width : 0
        height: yscale(50)
        color:
        {
            if (ListView.view && ListView.view.focus)
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

