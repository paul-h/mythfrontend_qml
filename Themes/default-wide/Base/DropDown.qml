import QtQuick 2.5
import SortFilterProxyModel 0.2

FocusScope
{
    id: root
    property alias labelText: label.text
    property alias editText: edit.text
    property int closedHeight: 80
    property int expandedHeight: 240
    property alias model: listProxyModel.sourceModel

    signal itemChanged();

    onActiveFocusChanged: edit.focus = root.activeFocus

    states:
    [
        State
        {
            name: ""
            PropertyChanges { target: root; height: closedHeight }
        },
        State
        {
            name: "expanded"
            PropertyChanges { target: root; height: expandedHeight }
        }
    ]

    SortFilterProxyModel
    {
        id: listProxyModel
        filterRoleName: "item"
        filterPattern: edit.text
        filterCaseSensitivity: Qt.CaseInsensitive
        sortRoleName: "item"
    }

    InfoText
    {
        id: label
        x: 0; y: 0
        width: parent.width; height: yscale(30)
    }

    BaseEdit
    {
        id: edit
        x: 0; y: yscale(35); width: parent.width;
        text: "";
        //focus: root.activeFocus
        KeyNavigation.up: root.KeyNavigation.up;
        KeyNavigation.down: if (root.state == "expanded") list; else root.KeyNavigation.down
        //KeyNavigation.left: recordingList;
        //KeyNavigation.right: recordingList;
        onEditingFinished: { root.state = ""; itemChanged();}
        onTextChanged: if (root.state != "expanded") root.state = "expanded";
    }

    Item
    {
        id: listContainer
        x: 0; y: yscale(95)
        visible: (height > 0)
        width: parent.width
        height: Math.max(0, parent.height - y)

        Behavior on height {NumberAnimation {duration: 500; easing.type: Easing.InOutQuad}}

        Rectangle
        {
            id: listBackground
            anchors.fill: parent
            color: theme.bgColor
            opacity: theme.bgOpacity
            border.color: theme.bgBorderColor
            border.width: theme.bgBorderWidth
            radius: theme.bgRadius
        }

        ButtonList
        {
            id: list
            visible: (height > 0)
            delegate:
                Component
                {
                    ListItem
                    {
                        width: parent.width; height: yscale(40)
                        ListText
                        {
                            x: xscale(5); y: 0
                            width: parent.width - xscale(10)
                            height: parent.height
                            text: item
                        }
                    }
                }

            x: xscale(5); y: xscale(5);
            width: parent.width - xscale(10);
            height: parent.height - xscale(10);

            model: listProxyModel
            KeyNavigation.up: edit;
            KeyNavigation.down: edit;
            KeyNavigation.left: edit;
            KeyNavigation.right: edit;

            onItemClicked:
            {
                edit.text = model.get(list.currentIndex).item;
                root.state = ""
                edit.focus = true;
                //itemChanged();
            }
        }
    }
}
