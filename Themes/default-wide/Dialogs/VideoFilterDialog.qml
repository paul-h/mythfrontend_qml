import QtQuick 2.0
import Base 1.0

BaseDialog
{
    id: root

    width: xscale(500)
    height: yscale(500)

    property var videosModel

    property alias filterTitle: titleEdit.text
    property alias filterType: typeEdit.text
    property alias filterGenres: genreEdit.text

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
            KeyNavigation.down: typeEdit;
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
            KeyNavigation.right: typeEdit;
            KeyNavigation.down: typeButton;

            onClicked:
            {
                _searchField = "title"
                searchDialog.model = root.videosModel.titleList
                searchDialog.show();
            }
        }

        InfoText
        {
            x: 20; y: 110
            width: xscale(300); height: yscale(30)
            text: "Type"
        }

        BaseEdit
        {
            id: typeEdit
            x: xscale(20); y: yscale(150); width: xscale(400);
            text: "";
            KeyNavigation.up: titleEdit;
            KeyNavigation.left: titleButton;
            KeyNavigation.right: typeButton;
            KeyNavigation.down: genreEdit;
            onEditingFinished: console.log("Type is now: " + text);
        }

        BaseButton
        {
            id: typeButton
            x: xscale(430); y: yscale(150); width: xscale(50); height: yscale(50)
            text: "*"

            KeyNavigation.up: titleButton;
            KeyNavigation.left: typeEdit;
            KeyNavigation.right: genreEdit;
            KeyNavigation.down: genreButton;

            onClicked:
            {
                _searchField = "type"
                searchDialog.model = root.videosModel.typeList
                searchDialog.show();
            }
        }

        InfoText
        {
            x: 20; y: 210
            width: xscale(250); height: yscale(30)
            text: "Genres"
        }

        BaseEdit
        {
            id: genreEdit
            x: xscale(20); y: yscale(250); width: xscale(400);
            text: "";
            KeyNavigation.up: typeEdit;
            KeyNavigation.down: acceptButton;
            KeyNavigation.left: typeButton;
            KeyNavigation.right: genreButton;
        }

        BaseButton
        {
            id: genreButton
            x: xscale(430); y: yscale(250); width: xscale(50); height: yscale(50)
            text: "*"

            KeyNavigation.up: typeButton;
            KeyNavigation.left: genreEdit;
            KeyNavigation.right: acceptButton;
            KeyNavigation.down: rejectButton;

            onClicked:
            {
                _searchField = "genre"
                searchDialog.model = root.videosModel.genreList
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

            KeyNavigation.up: genreEdit;
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

            KeyNavigation.up: genreEdit;
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

        width: 600; height: 500

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
            else if (_searchField == "type")
            {
                typeEdit.text = itemText;
                typeButton.focus = true;
            }
            else if (_searchField == "genre")
            {
                genreEdit.text = itemText;
                genreButton.focus = true;
            }
            else
            {
                console.log("Unknow search field: " + _searchField);
                titleButton.focus = true;
            }
        }
    }
}
