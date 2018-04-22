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

    function show()
    {
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
            height: parent.height - column.height - buttonsRow.height - yscale(20)
            clip: true
        }

        Row
        {
            id: buttonsRow

            function __update() 
            {
                var i = 0;

                while ((!visible) && (i < children.length)) 
                {
                    visible = (children[i].text !== "") && (children[i].iconSource !== "");
                    i++;
                }
            }

            visible: false
            onChildrenChanged: __update()
            Component.onCompleted: __update()

            x: 0; y: parent.height - yscale(60)
            spacing: xscale(10)
            anchors
            {
                horizontalCenter: parent.horizontalCenter
                bottomMargin: yscale(25)
            }
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
