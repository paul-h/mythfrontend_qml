import QtQuick 2.0
import Base 1.0
import "../../../Models"

BaseDialog
{
    id: root

    width: xscale(500)
    height: yscale(500)

    property var model

    property alias filterTitle: titleEdit.text
    property alias filterCategory: categoryEdit.text
    property alias filterRecGroup: recGroupEdit.text

    property string _searchField: ""

    content: Item
    {
        anchors.fill: parent

         InfoText
        {
            x: 20; y: 10
            width: xscale(300); height: yscale(30)
            text: "Title"
        }

        BaseEdit
        {
            id: titleEdit
            x: xscale(20); y: yscale(50); width: xscale(400);
            text: "";
            focus: true
            KeyNavigation.up: acceptButton;
            KeyNavigation.down: categoryEdit;
            KeyNavigation.left: titleButton;
            KeyNavigation.right: titleButton;
        }

        BaseButton
        {
            id: titleButton
            x: xscale(430); y: yscale(50); width: xscale(50); height: yscale(50)
            text: "*"

            KeyNavigation.up: rejectButton;
            KeyNavigation.left: titleEdit;
            KeyNavigation.right: categoryEdit;
            KeyNavigation.down: categoryButton;

            onClicked:
            {
                _searchField = "title"
                searchDialog.model = root.model.titleList
                searchDialog.show();
            }
        }

        InfoText
        {
            x: xscale(20); y: yscale(110)
            width: xscale(300); height: yscale(30)
            text: "Category"
        }

        BaseEdit
        {
            id: categoryEdit
            x: xscale(20); y: yscale(150); width: xscale(400);
            text: "";
            KeyNavigation.up: titleEdit;
            KeyNavigation.left: titleButton;
            KeyNavigation.right: categoryButton;
            KeyNavigation.down: recGroupEdit;
        }

        ProgCategoryModel {id: progCategoryModel}

        BaseButton
        {
            id: categoryButton
            x: xscale(430); y: yscale(150); width: xscale(50); height: yscale(50)
            text: "*"

            KeyNavigation.up: titleButton;
            KeyNavigation.left: categoryEdit;
            KeyNavigation.right: recGroupEdit;
            KeyNavigation.down: recGroupButton;

            onClicked:
            {
                _searchField = "category"
                searchDialog.model = progCategoryModel;
                searchDialog.show();
            }
        }

        InfoText
        {
            x: xscale(20); y: yscale(210)
            width: xscale(250); height: yscale(30)
            text: "Recording Group"
        }

        BaseEdit
        {
            id: recGroupEdit
            x: xscale(20); y: yscale(250); width: xscale(400);
            text: "";
            KeyNavigation.up: categoryEdit;
            KeyNavigation.down: acceptButton;
            KeyNavigation.left: categoryButton;
            KeyNavigation.right: recGroupButton;
        }

        RecGroupModel {id: recGroupModel}

        BaseButton
        {
            id: recGroupButton
            x: xscale(430); y: yscale(250); width: xscale(50); height: yscale(50)
            text: "*"

            KeyNavigation.up: categoryButton;
            KeyNavigation.left: recGroupEdit;
            KeyNavigation.right: acceptButton;
            KeyNavigation.down: rejectButton;

            onClicked:
            {
                _searchField = "recgroup";
                searchDialog.model = recGroupModel;
                searchDialog.show();
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

            KeyNavigation.up: recGroupEdit;
            KeyNavigation.left: rejectButton;
            KeyNavigation.right: rejectButton;
            KeyNavigation.down: titleEdit;

            onClicked:
            {
                root.state = "";
                root.accepted();
            }
        },

        BaseButton
        {
            id: rejectButton
            text: "Cancel"
            visible: text != ""

            KeyNavigation.up: recGroupEdit;
            KeyNavigation.left: acceptButton;
            KeyNavigation.right: acceptButton;
            KeyNavigation.down: titleEdit;

            onClicked:
            {
                root.state = "";
                root.cancelled();
            }
        }
    ]

    SearchListDialog
    {
        id: searchDialog

        title: "Search"
        message: ""

        onAccepted:
        {
            titleButton.focus = true;

        }
        onCancelled:
        {
            titleButton.focus = true;
        }

        onItemSelected:
        {
            if (_searchField == "title")
            {
                titleEdit.text = itemText;
                titleButton.focus = true;
            }
            else if (_searchField == "category")
            {
                categoryEdit.text = itemText;
                categoryButton.focus = true;
            }
            else if (_searchField == "recgroup")
            {
                recGroupEdit.text = itemText;
                recGroupButton.focus = true;
            }
            else
            {
                console.log("Unknow search field: " + _searchField);
                titleButton.focus = true;
            }
        }
    }
}
