import QtQuick 2.0
import Base 1.0
import Dialogs 1.0
import "../../../Models"

BaseScreen
{
    defaultFocusItem: filterBackground

    Component.onCompleted:
    {
        showTitle(true, "Test Page");
        showTime(false);
        showTicker(false);
        screenBackground.muteAudio(true);
    }

    Component.onDestruction:
    {
        screenBackground.muteAudio(false);
    }

    FocusScope
    {
        id: filterBackground
        x: xscale(100); y: yscale(50); width: xscale(280); height: yscale(400)
        visible: true

        states:
        [
            State
            {
                name: ""
                PropertyChanges { target: flickable; contentY: 0 }
            },
            State
            {
                name: "title"
                PropertyChanges { target: flickable; contentY: 0 }
            },
            State
            {
                name: "category"
                PropertyChanges { target: flickable; contentY: titleLabel.height + titleEdit.height + yscale(15)}
            },
            State
            {
                name: "recgroup"
                PropertyChanges { target: flickable; contentY: titleLabel.height + titleEdit.height + categoryDropDown.height + yscale(20)}
            }
        ]

        BaseBackground
        {
            anchors.fill: parent
        }

        LabelText
        {
            x: xscale(5); y: yscale(5); width: parent.width - xscale(10);
            horizontalAlignment: Text.AlignHCenter
            text: "Recordings Filter"
        }

        Flickable
        {
            id: flickable
            x: xscale(5); y: yscale(50); width: parent.width - xscale(10); height: parent.height - yscale(50)
            clip: true

            Behavior on contentY {NumberAnimation {duration: 500; easing.type: Easing.InOutQuad}}

            Column
            {
                spacing: yscale(5)
                anchors.fill: parent

                move: Transition
                {
                    NumberAnimation { properties: "x,y,height"; duration: 500; easing.type: Easing.InOutQuad }
                }

                add: Transition
                {
                    NumberAnimation { properties: "x,y,height"; duration: 500; easing.type: Easing.InOutQuad }
                }

                InfoText
                {
                    id: titleLabel
                    x: 0; //y: yscale(35)
                    width: parent.width; height: yscale(30)
                    text: "Title"
                }

                BaseEdit
                {
                    id: titleEdit
                    x: 0; //y: yscale(70);
                    width: parent.width;
                    height: 50
                    text: "";
                    focus: true
                    KeyNavigation.up: recGroupDropDown;
                    KeyNavigation.down: categoryDropDown;
                    //KeyNavigation.left: recordingList;
                    //KeyNavigation.right: recordingList;
                    onEditingFinished:  { filterBackground.state = ""; }
                    onTextChanged: if (filterBackground.state != "title") filterBackground.state = "title"; //else filterBackground.state = "";
                    //onStateChanged: if (state != "expanded") filterBackground.state = "title"; else filterBackground.state = ""
                }
 
                DropDown
                {
                    id: categoryDropDown
                    x: 0;
                    width: parent.width
                    height: 80
                    expandedHeight: 350
                    labelText: "Category"
                    //editText: "Test"
                    model: ProgCategoryModel {}
                    onItemChanged: console.info("New category is: " +  editText)
                    onStateChanged: if (state == "expanded") filterBackground.state = "category"; else filterBackground.state = ""
                    KeyNavigation.down: recGroupDropDown;
                    KeyNavigation.up: titleEdit;
                }

                DropDown
                {
                    id: recGroupDropDown
                    x: 0;
                    width: parent.width
                    height: 50
                    expandedHeight: 350
                    labelText: "Recording Group"
                    //editText: "Test"
                    model: RecGroupModel {}
                    onItemChanged: console.info("New recording group is: " +  editText)
                    onStateChanged: if (state == "expanded") filterBackground.state = "recgroup"; else filterBackground.state = ""
                    KeyNavigation.up: categoryDropDown
                    KeyNavigation.down: titleEdit
                }
            }
        }
    }
}
