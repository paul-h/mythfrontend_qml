import QtQuick
import Base 1.0

FocusScope
{
    id: modalDialog

    property alias content: contentItem.children

    signal accepted
    signal cancelled

    property int actualX: (window.width / 2) - (width / 2)
    property int actualY: (window.height / 2) - (height / 2)
    property int hiddenX: window.width
    property int hiddenY: y

    y: (window.height / 2) - (height / 2)
    x: (window.width / 2) - (width / 2)
    width: xscale(500)
    height: yscale(500)

    visible: true

    property var _activeFocusItem: null

    function show(focusItem)
    {
        _show(focusItem);
    }

    function _show(focusItem)
    {
        if (state === "show")
            return;

        if (!focusItem)
            focusItem = window.activeFocusItem

        _activeFocusItem = focusItem;
        modalDialog.state = "show";
    }

    function hide()
    {
        modalDialog.state = "";
    }

    Keys.onEscapePressed:
    {
        modalDialog.state = "";
        modalDialog.cancelled();
        focus = false;
    }

    Item
    {
        id: contentItem
        anchors.fill: parent

        clip: true

        Rectangle
        {
            anchors.fill: parent
            color: "transparent"
            border.color: Qt.rgba(Math.random(), Math.random(), Math.random(), 1)
            border.width: 1
            visible: settings.showTextBorder
        }
    }

    states:
    [
        State
        {
            name: ""

            PropertyChanges
            {
                target: modalDialog
                focus: false
                visible: true
                x: hiddenX
                y: hiddenY
            }
            StateChangeScript
            {
                name: "changefocus"
                script: if (modalDialog._activeFocusItem) modalDialog._activeFocusItem.forceActiveFocus(); else stack.currentItem.defaultFocusItem.forceActiveFocus();
            }
        },
        State
        {
            name: "show"

            PropertyChanges
            {
                target: modalDialog
                focus: true
                visible: true
                x: actualX
                y: actualY
            }
        }
    ]

    transitions:
    [
        Transition
        {
            from: "*"
            to: "*"
            SequentialAnimation
            {
                NumberAnimation { properties: "x,y,opacity"; easing.type: Easing.Linear; duration: 450 }
            }
        }
    ]
}
