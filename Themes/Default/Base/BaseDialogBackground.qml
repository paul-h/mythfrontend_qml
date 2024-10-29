import QtQuick

Rectangle
{
    id: root
    color: theme.bgDialogColor
    opacity: theme.bgDialogOpacity
    border.color: theme.bgDialogBorderColor
    border.width: xscale(theme.bgDialogBorderWidth)
    radius: xscale(theme.bgDialogRadius)

    SequentialAnimation
    {
        id: anim
        running: true
        loops: Animation.Infinite

        PropertyAnimation
        {
            targets: [root.border]
            property: "color"
            to: Qt.lighter(theme.bgDialogBorderColor, 1.5)
            duration: 400
        }
        PropertyAnimation
        {
            targets: [root.border]
            property: "color"
            to: theme.bgDialogBorderColor
            duration: 400
        }
        PropertyAnimation
        {
            targets: [root.border]
            property: "color"
            to: Qt.darker(theme.bgDialogBorderColor, 2.0)
            duration: 400
        }
        PropertyAnimation
        {
            targets: [root.border]
            property: "color"
            to: theme.bgDialogBorderColor
            duration: 400
        }
    }
}
