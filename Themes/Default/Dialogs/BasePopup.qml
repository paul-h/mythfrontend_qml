import QtQuick 2.0
import Base 1.0

FocusScope
{
    id: modalDialog

    property alias content: contentItem.children

    signal accepted
    signal cancelled

    width: xscale(500)
    height: yscale(500)
    anchors.horizontalCenter: parent.horizontalCenter
    anchors.verticalCenter: parent.verticalCenter
    visible: false

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
                opacity: 0
            }
            PropertyChanges
            {
                target: modalDialog
                focus: false
                visible: false
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
                opacity: 1
            }

            PropertyChanges
            {
                target: modalDialog
                focus: true
                visible: true
            }
        }
    ]

    transitions:
    [
        Transition
        {
            from: ""
            to: "show"
            SequentialAnimation
            {
                NumberAnimation { properties: "opacity"; easing.type: Easing.Linear; duration: 750 }
            }
        },
        Transition
        {
            from: "show"
            to: ""
            NumberAnimation { properties: "opacity"; easing.type: Easing.Linear; duration: 750 }
        }
    ]
}
