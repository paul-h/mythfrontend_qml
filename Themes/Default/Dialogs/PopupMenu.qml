import QtQuick 2.0
import Base 1.0
import mythqml.net 1.0

BaseDialog
{
    id: popupMenu

    width: xscale(500)
    height: yscale(600)

    property alias model: menuList.model
    property bool restoreSelected: false

    signal itemSelected(string itemText, string itemData)

    function show(focusItem)
    {
        if (!restoreSelected)
            menuList.setFocusedNode(0);

        _show(focusItem);
    }

    function clearMenuItems()
    {
        menuList.reset();
    }

    function addMenuItem(path, title, data, checked)
    {
        menuList.addNode(path, title, data, checked);
    }

    Keys.onPressed:
    {
        event.accepted = true;

        if (event.key === Qt.Key_M)
        {
            popupMenu.state = "";
            popupMenu.cancelled();
        }
        else if (event.key >= Qt.Key_1 && event.key <= Qt.Key_9)
        {
            var num = event.key - Qt.Key_0;
            menuList.scrollToPos(num * 10);
        }
        else
        {
            // eat all key presses except these
            if (event.key === Qt.Key_Up || event.key === Qt.Key_Down || event.key === Qt.Key_PageUp || event.key === Qt.Key_PageDown || event.key === Qt.Key_Enter)
                event.accepted = false
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
                log.debug(Verbose.GUI, "PopupMenu: onNodeClicked - itemTitle: " + node.itemTitle + ", node.itemData: " + node.itemData);
                popupMenu.state = "";
                popupMenu.itemSelected(node.itemTitle, node.itemData);
            }
        }
    }
}
