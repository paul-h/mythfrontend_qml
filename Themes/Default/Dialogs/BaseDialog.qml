import QtQuick 2.0
import Base 1.0

FocusScope
{
    id: modalDialog

    property string title: ""
    property string message: ""
    property bool showCancelButton: false
    property alias content: contentItem.children
    property alias buttons: buttonsRow.children

    signal accepted
    signal cancelled

    width: xscale(500)
    height: yscale(500)
    anchors.horizontalCenter: parent.horizontalCenter
    anchors.verticalCenter: parent.verticalCenter
    visible: false

    property var _activeFocusItem: null

    onVisibleChanged: updateButtons()

    function show(focusItem)
    {
        _show(focusItem);
    }

    function _show(focusItem)
    {
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
        id: dialog

        opacity: 0
        anchors.fill: parent

        BaseDialogBackground
        {
            id: background
            anchors.fill: parent
        }

        Column
        {
            id: column
            y: yscale(10)
            width: parent.width
            spacing: 0

            TitleText
            {
                id: titleText
                x: xscale(20); y: yscale(5)
                visible: text != ""
                width: parent.width - xscale(40)
                text: title
                horizontalAlignment: Text.AlignHCenter
            }

            InfoText
            {
                id: messageText
                x: xscale(20); y: yscale(5)
                width: parent.width - xscale(40)
                height: yscale(150)
                visible: text != ""
                text: message
                multiline: true
                horizontalAlignment: Text.AlignHCenter
            }
        }

        Item
        {
            id: contentItem
            x: xscale(10)
            y: column.height + yscale(10)
            width: parent.width - xscale(20)
            height: parent.height - column.height - buttonsRow.height - yscale(25)
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

        Row
        {
            id: buttonsRow

            x: 0; y: parent.height - height - yscale(15)
            visible: false
            spacing: xscale(10)
            anchors.horizontalCenter: parent.horizontalCenter

            function __update()
            {
                var i = 0;

                while ((!visible) && (i < children.length))
                {
                    visible = (children[i].text !== "");
                    i++;
                }
            }
        }

        Rectangle
        {
            x: buttonsRow.x
            y: buttonsRow.y
            width: buttonsRow.width
            height: buttonsRow.height
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
                target: dialog
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
                script: modalDialog._activeFocusItem.forceActiveFocus()
            }
        },
        State
        {
            name: "show"
            PropertyChanges
            {
                target: dialog
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

    function updateButtons()
    {
        buttonsRow.__update();
    }
}
