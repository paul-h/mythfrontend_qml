import QtQuick 2.0
import Base 1.0
import SortFilterProxyModel 0.2

BaseDialog
{
    id: searchDialog

    width: xscale(500)
    height: yscale(600)

    property alias model: listProxyModel.sourceModel

    signal itemSelected(string itemText)

    function show()
    {
        searchDialog.state = "show";
    }

    function addSearchItem(item)
    {
        itemList.add(item);
    }

    SortFilterProxyModel
    {
        id: listProxyModel
        filterRoleName: "item"
        filterPattern: searchEdit.text
        filterCaseSensitivity: Qt.CaseInsensitive
        sortRoleName: "item"
    }

    Component
    {
        id: listRow
        ListItem
        {
            width: parent.width; height: yscale(50)
            ListText
            {
                x: xscale(20); y: 0
                width: parent.width - xscale(20)
                text: item
            }
        }
    }

    content: Item
    {
        anchors.fill: parent

        BaseEdit
        {
            id: searchEdit
            x: xscale(40); y: yscale(0); width: parent.width - xscale(80);
            text: "";
            focus: true;
            KeyNavigation.up: itemList;
            KeyNavigation.down: itemList;
            KeyNavigation.left: itemList;
            KeyNavigation.right: itemList;
        }

        ButtonList
        {
            id: itemList
            delegate: listRow
            model: listProxyModel

            x: xscale(20); y: yscale(60)
            width: parent.width - xscale(40);
            height: parent.height - yscale(70);

            KeyNavigation.up: searchEdit;
            KeyNavigation.down: acceptButton;
            KeyNavigation.left: searchEdit;
            KeyNavigation.right: acceptButton;

            onItemClicked:
            {
                searchDialog.state = "";
                searchDialog.itemSelected(listProxyModel.get(itemList.currentIndex).item);
            }
        }
    }

    buttons:
    [
        BaseButton
        {
            id: acceptButton
            text: "OK"
            visible: text != ""

            KeyNavigation.up: itemList;
            KeyNavigation.down: searchEdit;
            KeyNavigation.left: rejectButton;
            KeyNavigation.right: rejectButton;

            onClicked:
            {
                searchDialog.state = "";
                searchDialog.itemSelected(listProxyModel.get(itemList.currentIndex).item);
            }
        },

        BaseButton
        {
            id: rejectButton
            text: "Cancel"
            visible: text != ""

            KeyNavigation.up: itemList;
            KeyNavigation.down: searchEdit;
            KeyNavigation.left: acceptButton;
            KeyNavigation.right: acceptButton;

            onClicked:
            {
                searchDialog.state = "";
                searchDialog.cancelled();
            }
        }
    ]
}
