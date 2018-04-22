import QtQuick 2.0

Item
{
    id: button
    width: 480
    height: 60
    Rectangle
    {
        anchors.fill: parent
        border.color: "white"
        border.width: 2
        color: "#00000000"
    }

    //     focus: true
    property alias buttonText: innerText.text;
    property color color: "white"
    property color hoverColor: "#aaaaaa"
    property color pressColor: "slategray"
    property int fontSize: 30
    property int borderWidth: 1
    property int borderRadius: 2
    scale: state === "Pressed" ? 0.96 : 1.0
    onEnabledChanged: state = ""
    onFocusChanged: state = activeFocus ? "Selected" : ""
    signal clicked

    Keys.onReturnPressed:
    {
        state = "Pressed"
        clicked();
        console.log("button return pressed on: " + buttonText)
    }
    //define a scale animation
    Behavior on scale
    {
        NumberAnimation
        {
            duration: 100
            easing.type: Easing.InOutQuad
        }
    }

    // background image
    Image
    {
        id: background
        anchors.fill: parent
        source: ""

        Text
        {
            id: innerText
            font.pointSize: fontSize
            font.bold: true
            color: "white"
            x: 10; width: parent.width - 20;
            anchors.verticalCenter: parent.verticalCenter
        }
    }

    //change the color of the button in differen button states
    states:
    [
        State
        {
            name: "Selected"
            PropertyChanges
            {
                target: background
                source: "images/button_on.png"
            }
        },
        State
        {
            name: "Pressed"
            PropertyChanges {
                target: background
                scale: 0.98
            }
        }
    ]

    //define transmission for the states
    //     transitions: [
    //         Transition {
    //             from: ""; to: "Hovering"
    //             ColorAnimation { duration: 200 }
    //         },
    //         Transition {
    //             from: "*"; to: "Pressed"
    //             ColorAnimation { duration: 10 }
    //         }
    //     ]

    //Mouse area to react on click events
    MouseArea
    {
        hoverEnabled: true
        anchors.fill: button
        onEntered: { button.state='Hovering'}
        onExited: { button.state=''}
        onClicked: { button.clicked();}
        onPressed: { button.state="Pressed" }
        onReleased:
        {
            if (containsMouse)
                button.state="Hovering";
            else
                button.state="";
        }
    }
}
