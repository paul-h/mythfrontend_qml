import QtQuick 2.0
import Base 1.0

BaseDialog
{
    id: root

    width: xscale(500)
    height: yscale(500)

    property var streamsModel

    property alias filterBroadcaster: broadcasterEdit.text
    property alias filterChannel: channelEdit.text
    property alias filterGenre: genreEdit.text

    property string _searchField: ""

    content: Item
    {
        anchors.fill: parent

         InfoText
        {
            x: 20; y: 10
            width: xscale(300); height: yscale(30)
            text: "Broadcaster"
        }

        BaseEdit
        {
            id: broadcasterEdit
            x: xscale(20); y: yscale(50); width: xscale(400);
            text: "";
            focus: true
            KeyNavigation.up: acceptButton;
            KeyNavigation.down: channelEdit;
            KeyNavigation.left: broadcasterButton;
            KeyNavigation.right: broadcasterButton;
        }

        BaseButton
        {
            id: broadcasterButton
            x: xscale(430); y: yscale(50); width: xscale(50); height: yscale(50)
            text: "*"

            KeyNavigation.up: rejectButton;
            KeyNavigation.left: broadcasterEdit;
            KeyNavigation.right: channelEdit;
            KeyNavigation.down: channelButton;

            onClicked:
            {
                _searchField = "broadcaster"
                searchDialog.model = root.streamsModel.broadcasterList
                searchDialog.show();
            }
        }

        InfoText
        {
            x: 20; y: 110
            width: xscale(300); height: yscale(30)
            text: "Channel"
        }

        BaseEdit
        {
            id: channelEdit
            x: xscale(20); y: yscale(150); width: xscale(400);
            text: "";
            KeyNavigation.up: broadcasterEdit;
            KeyNavigation.left: broadcasterButton;
            KeyNavigation.right: channelButton;
            KeyNavigation.down: genreEdit;
            onEditingFinished: console.log("Type is now: " + text);
        }

        BaseButton
        {
            id: channelButton
            x: xscale(430); y: yscale(150); width: xscale(50); height: yscale(50)
            text: "*"

            KeyNavigation.up: broadcasterButton;
            KeyNavigation.left: channelEdit;
            KeyNavigation.right: genreEdit;
            KeyNavigation.down: genreButton;

            onClicked:
            {
                _searchField = "channel"
                searchDialog.model = root.streamsModel.channelList
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
            KeyNavigation.up: channelEdit;
            KeyNavigation.down: acceptButton;
            KeyNavigation.left: channelButton;
            KeyNavigation.right: genreButton;
        }

        BaseButton
        {
            id: genreButton
            x: xscale(430); y: yscale(250); width: xscale(50); height: yscale(50)
            text: "*"

            KeyNavigation.up: channelButton;
            KeyNavigation.left: genreEdit;
            KeyNavigation.right: acceptButton;
            KeyNavigation.down: rejectButton;

            onClicked:
            {
                _searchField = "genre"
                searchDialog.model = root.streamsModel.genreList
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
            KeyNavigation.down: broadcasterEdit;

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
            KeyNavigation.down: broadcasterEdit;

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
            broadcasterButton.focus = true;

        }
        onCancelled:
        {
            broadcasterButton.focus = true;
        }

        onItemSelected:
        {
            if (_searchField == "broadcaster")
            {
                broadcasterEdit.text = itemText;
                broadcasterButton.focus = true;
            }
            else if (_searchField == "channel")
            {
                channelEdit.text = itemText;
                channelButton.focus = true;
            }
            else if (_searchField == "genre")
            {
                genreEdit.text = itemText;
                genreButton.focus = true;
            }
            else
            {
                console.log("Unknown search field: " + _searchField);
                titleButton.focus = true;
            }
        }
    }
}
