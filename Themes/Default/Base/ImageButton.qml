import QtQuick
import Qt5Compat.GraphicalEffects

Item
{
    property alias source: iconImage.source
    property bool effectEnabled: true

    signal clicked();

    x: 0; y: 0; width: xscale(200); height: yscale(50)
    focus: false
    state: "normal"
    states:
    [
        State
        {
            name: "normal"
            PropertyChanges
            {
                target: effect;
                hue: 0.0
                saturation: 1.0
                lightness:0.0
            }
            PropertyChanges
            {
                target: background;
                visible: false
                gradient: theme.gradientNormal();
                border.color: theme.btBorderColorNormal;
            }
        },
        State
        {
            name: "focused"
            PropertyChanges
            {
                target: effect;
                enabled: true;
                hue: 0.0
                saturation: 1.1
                lightness:0.0
            }
            PropertyChanges
            {
                target: background;
                visible: true
            }
        },
        State
        {
            name: "disabled"
            PropertyChanges
            {
                target: effect;
                enabled: true;
                hue: 0.0
                saturation: 0.0
                lightness:0.0
            }
            PropertyChanges
            {
                target: background;
                visible: false
            }
        },
        State
        {
            name: "pushed"
            PropertyChanges
            {
                target: effect;
                enabled: true;
                hue: 0.0
                saturation: 0.6
                lightness:0.5
            }
            PropertyChanges
            {
                target: background;
                visible: true
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
        x: 0
        y: parent.height - yscale(theme.btBorderWidth)
        width: parent.width
        height: yscale(theme.btBorderWidth)
        border.width: theme.btBorderWidth
        border.color: "green"; //theme.btBorderColorNormal
    }

    Image
    {
        id: iconImage
        anchors
        {
            fill: parent;
            bottomMargin: yscale(theme.btBorderWidth + 2)
        }
    }

    Colorize
    {
        id: effect
        anchors.fill: effectEnabled ? iconImage : undefined
        source: effectEnabled ? iconImage : undefined
        hue: 0.0
        saturation: 0.0
        lightness:0.0
    }
}
