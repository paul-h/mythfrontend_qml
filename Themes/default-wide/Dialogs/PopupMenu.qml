import QtQuick 2.0
import Base 1.0

BaseDialog
{
    id: popupMenu

    width: xscale(400)
    height: yscale(600)

    property alias model: menuList.model
    property bool restoreSelected: false

    signal itemSelected(string itemText, string itemData)

    function show()
    {
        if (!restoreSelected)
            menuList.setFocusedNode(0);
        popupMenu.state = "show";
    }

    function clearMenuItems()
    {
        menuList.model.clear()
    }

    function addMenuItem(path, data)
    {
        menuList.addNode(path, data);
    }

    Keys.onPressed:
    {
        if (event.key === Qt.Key_M)
        {
            popupMenu.state = "";
            popupMenu.cancelled();
            event.accepted = true;
        }
    }

    content: Item
    {
        anchors.fill: parent

        TreeButtonList
        {
            id: menuList

            anchors.fill: parent

            focus: true
            onNodeClicked:
            {
                console.log("node.itemTitle: " + node.itemTitle + ", node.itemData: " + node.itemData);
                popupMenu.state = "";
                popupMenu.itemSelected(node.itemTitle, node.itemData);
            }
        }
    }
}
