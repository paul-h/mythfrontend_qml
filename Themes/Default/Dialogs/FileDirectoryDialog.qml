import QtQuick 2.0
import Models 1.0
import Base 1.0
import SortFilterProxyModel 0.2

BaseDialog
{
    id: fileDialog

    width: xscale(1000)
    height: yscale(600)

    property string folder: "/"
    property string nameFilters: "*.*"
    property string displayField: "fileName"
    property string dataField: "filePath"

    signal itemSelected(string itemText)

    Component.onCompleted: treeView.setFocusedNode("Root ~ FileBrowser");

    function reset()
    {
        fileEdit.text = "";
        treeView.currentIndex = 0;
    }

    function addSearchItem(item)
    {
        treeView.add(item);
    }

    function show(focusItem)
    {
        fileEdit.text = ""
        fileEdit.focus = true
        _show(focusItem);
    }

    function showSelected(selectedItem, focusItem)
    {
        treeView.highlightMoveDuration = 0

        fileEdit.text = ""
        fileEdit.focus = true
        treeView.currentIndex = 0;

        if (selectedItem)
        {
            for (var x = 0; x < listProxyModel.count; x++)
            {
                if (selectedItem == listProxyModel.get(x, displayField))
                {
                    treeView.currentIndex = x;
                    break;
                }
            }
        }

        _show(focusItem);

        treeView.highlightMoveDuration = 1500
    }

    Component
    {
        id: listRow
        ListItem
        {
            width: treeView.width; height: yscale(50)
            ListText
            {
                x: xscale(20); y: 0
                width: parent.width - xscale(20)
                text:
                {
                    if (displayField === "item")
                        return item;

                    if (index >= 0 && index < folderModel.count && displayField != "")
                    {
                        if (folderModel.get(index, displayField) != undefined)
                            return folderModel.get(index, displayField);
                    }

                    return "";
                }
            }
        }
    }

    SourceTreeModel
    {
        id: sourceTree

        // this wont work because the data node contains the full path not the node name
        //Component.onCompleted: setRootNode("Root ~ File Browser");
    }

    content: Item
    {
        anchors.fill: parent

        BaseEdit
        {
            id: fileEdit
            x: xscale(40); y: yscale(0); width: parent.width - xscale(80);
            text: "";
            focus: true;
            KeyNavigation.up: treeView;
            KeyNavigation.down: treeView;
            KeyNavigation.left: treeView;
            KeyNavigation.right: treeView;

            onTextChanged: if (treeView.count > 0) treeView.currentIndex = 0; else treeView.currentIndex = -1;

            onEditingFinished:
            {
                if (treeView.currentIndex != -1)
                {
                    fileDialog.state = "";
                    fileDialog.itemSelected(listProxyModel.get(treeView.currentIndex, dataField));
                }
            }
        }

        InfoText
        {
            id: breadCrumb
            x: xscale(30)
            y: yscale(45)
            width: parent.width - xscale(60)
            textFormat: Text.PlainText
        }

        InfoText
        {
            id: posText
            x: parent.width - width - xscale(30)
            y: yscale(45)
            width: xscale(120)
            horizontalAlignment: Text.AlignRight
            text: "xxx of xxx"
        }

        BaseBackground
        {
            anchors.fill: parent
            anchors.leftMargin: xscale(10)
            anchors.rightMargin: xscale(10)
            anchors.topMargin: yscale(90)
            anchors.bottomMargin: yscale(20)

            TreeButtonList
            {
                id: treeView

                focus: true
                anchors.fill: parent
                anchors.margins: xscale(10)
                columns: 3
                spacing: xscale(10)
                sourceTree: sourceTree
                model: sourceTree.model

                onNodeSelected:
                {
                    breadCrumb.text = getActiveNodePath(false, "/");
                }

                onPosChanged:
                {
                    posText.text = (index + 1) + " of " + count
                }

                onNodeClicked:
                {
                    fileEdit.text = getActiveNodePath(false, "/");
                }

                KeyNavigation.up: fileEdit;
                KeyNavigation.down: acceptButton;
                KeyNavigation.left: fileDialog;
                KeyNavigation.right: acceptButton;
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

            KeyNavigation.up: treeView;
            KeyNavigation.down: fileEdit;
            KeyNavigation.left: rejectButton;
            KeyNavigation.right: rejectButton;

            onClicked:
            {
                fileDialog.state = "";
                fileDialog.itemSelected(fileEdit.text);
            }
        },

        BaseButton
        {
            id: rejectButton
            text: "Cancel"
            visible: text != ""

            KeyNavigation.up: treeView;
            KeyNavigation.down: fileEdit;
            KeyNavigation.left: acceptButton;
            KeyNavigation.right: acceptButton;

            onClicked:
            {
                fileDialog.state = "";
                fileDialog.cancelled();
            }
        }
    ]
}
