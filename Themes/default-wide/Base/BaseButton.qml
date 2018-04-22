import QtQuick 2.0

Item
{
    property alias text: buttonText.text

    signal clicked();

    x: 0; y: 0; width: 200; height: 50
    focus: false
    state: "normal"
    states:
    [
        State
        {
            name: "normal"
            PropertyChanges
            {
                target: buttonText;
                fontColor: theme.btTextColorNormal;
            }
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
                target: buttonText;
                fontColor: theme.btTextColorSelected;
            }
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
                target: buttonText;
                fontColor: theme.btTextColorDisabled;
            }
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
                target: buttonText;
                fontColor: theme.btTextColorFocusedSelected;
            }
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
        clicked();
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

    LabelText
    {
        id: buttonText
        anchors {fill: parent; margins: 3}
        horizontalAlignment: Text.AlignHCenter
        fontColor: theme.btTextColorNormal
    }
}

