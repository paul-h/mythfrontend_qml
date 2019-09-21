import QtQuick 2.0

Item
{
    property bool checked: true

    signal changed();

    x: 0; y: 0; width: 40; height: 40
    focus: false
    state: "normal"
    states:
    [
        State
        {
            name: "normal"
            PropertyChanges
            {
                target: background;
                gradient: theme.gradientNormal();
                border.color: theme.btBorderColorNormal;
            }        },
        State
        {
            name: "focused"
            PropertyChanges
            {
                target: background;
                gradient: theme.gradientSelected();
                border.color: theme.btBorderColorSelected;
            }
        },
        State
        {
            name: "disabled"
            PropertyChanges
            {
                target: background;
                gradient: theme.gradientDisabled();
                border.color: theme.btBorderColorDisabled;
            }
        },
        State
        {
            name: "pushed"
            PropertyChanges
            {
                target: background;
                gradient: theme.gradientFocusedSelected();
                border.color: theme.btBorderColorFocusedSelected;
            }
        }
    ]

    function updateState()
    {
        if (!enabled)
            state = "disabled";
        else if (focus)
            state = "focused";
        else
            state = "normal";
    }

    onFocusChanged: updateState()
    onEnabledChanged: updateState()

    Timer
    {
        id: pushTimer
        interval: 250; running: false;
        onTriggered: updateState();
    }

    Keys.onReturnPressed:
    {
        state = "pushed"
        pushTimer.start();
        checked = !checked
        changed();
    }

    Rectangle
    {
        id: background
        anchors.fill: parent
        gradient: theme.gradientNormal();
        border.width: theme.btBorderWidth
        border.color: theme.btBorderColorNormal
        radius: theme.btBorderRadius
    }

    Image
    {
        id: checkIcon
        anchors {fill: parent; margins: 3}
        source: mythUtils.findThemeFile(parent.checked ? "images/check.png" : "images/unchecked.png")
    }
}

