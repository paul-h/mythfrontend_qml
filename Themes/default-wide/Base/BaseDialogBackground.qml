import QtQuick 2.0

Rectangle
{
    id: root
    color: theme.bgDialogColor
    opacity: theme.bgDialogOpacity
    border.color: theme.bgDialogBorderColor
    border.width: xscale(theme.bgDialogBorderWidth)
    radius: xscale(theme.bgDialogRadius)
}

