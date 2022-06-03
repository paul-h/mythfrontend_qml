import QtQuick 2.0
import Base 1.0
import SortFilterProxyModel 0.2

BaseDialog
{
    id: searchDialog

    width: xscale(500)
    height: yscale(600)

    property alias model: listProxyModel.sourceModel
    property string displayField: "item"
    property string dataField: "item"

    signal itemSelected(string itemText)

    function reset()
    {
        searchEdit.text = "";
        itemList.currentIndex = 0;
    }

    function addSearchItem(item)
    {
        itemList.add(item);
    }

    SortFilterProxyModel
    {
        id: listProxyModel
        filterRoleName: displayField
        filterPattern: searchEdit.text
        filterCaseSensitivity: Qt.CaseInsensitive
        sortRoleName: displayField
    }

    Component
    {
        id: listRow
        ListItem
        {
            width: itemList.width; height: yscale(50)
            ListText
            {
                x: xscale(20); y: 0
                width: parent.width - xscale(20)
                text:
                {
                    if (displayField === "item")
                        return item;

                    if (index >= 0 && index < listProxyModel. count && displayField != "")
                    {
                        if (listProxyModel.get(index, displayField) != undefined)
                            return listProxyModel.get(index, displayField);
                    }

                    return "";
                }
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

            onTextChanged: if (itemList.count > 0) itemList.currentIndex = 0; else itemList.currentIndex = -1;
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
                searchDialog.itemSelected(listProxyModel.get(itemList.currentIndex, dataField));
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
                searchDialog.itemSelected(listProxyModel.get(itemList.currentIndex, dataField));
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
