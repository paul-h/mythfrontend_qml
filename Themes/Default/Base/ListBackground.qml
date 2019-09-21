import QtQuick 2.0

Rectangle
{
    anchors.fill: parent
    color:
    {
        if (parent.focused)
        {
            if (parent.selected)
                theme.lvRowBackgroundFocusedSelected;
            else
                theme.lvRowBackgroundFocused;
        }
        else
        {
            if (parent.selected)
                theme.lvRowBackgroundSelected;
            else
                theme.lvRowBackgroundNormal;
        }
    }

    //opacity: theme.lvBackgroundOpacity
    //border.color: theme.lvBackgroundBorderColor
    //border.width: xscale(theme.lvBackgroundBorderWidth)
    //radius: xscale(theme.lvBackgroundBorderRadius)
}

