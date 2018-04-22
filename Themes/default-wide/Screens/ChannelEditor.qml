import QtQuick 2.0
import Base 1.0
import "../../../Models"

BaseScreen
{
    defaultFocusItem: sdChannelList

    Component.onCompleted:
    {
        showTitle(false, "");
        showTime(false);
        showTicker(false);
    }

    BaseBackground { anchors.fill: parent; anchors.margins: 10 }

    Keys.onPressed:
    {
        if (event.key === Qt.Key_F1)
        {
            chanNoEdit.text = sdChannelList.model.get(sdChannelList.currentIndex).channo;
        }
        else if (event.key === Qt.Key_F2)
        {
            chanNameEdit.text = sdChannelList.model.get(sdChannelList.currentIndex).name;
        }
        else if (event.key === Qt.Key_F3)
        {
            callsignEdit.text = sdChannelList.model.get(sdChannelList.currentIndex).callsign;
        }
        else if (event.key === Qt.Key_F4)
        {
            xmltvidEdit.text = sdChannelList.model.get(sdChannelList.currentIndex).xmltvid;
        }
        else if (event.key === Qt.Key_F5)
        {
            var chanid = dbChannelList.model.data(dbChannelList.model.index(dbChannelList.currentIndex, 0))
            console.log("save button - chanid is: " + chanid);
            dbUtils.updateChannel(chanid,
                                  chanNameEdit.text,
                                  chanNoEdit.text,
                                  xmltvidEdit.text,
                                  callsignEdit.text);
        }
    }

    Component
    {
        id: listRow

        ListItem
        {
            Image
            {
               id: channelImage
               x: 3; y:3; height: parent.height - 6; width: height
               source: if (icon) icon; else mythUtils.findThemeFile("images/grid_noimage.png");
            }
            ListText
            {
                width:sdChannelList.width; height: 50
                x: channelImage.width + 5
                text: name + " ~ " + callsign + " ~ " + channo + " ~ " + xmltvid
            }
        }
    }

    ButtonList
    {
        id: sdChannelList
        x: 50; y: 30; width: 500; height: 500

        model: SDChannelsModel {}
        delegate: listRow

        Keys.onReturnPressed:
        {
            returnSound.play();
        }

        KeyNavigation.left:  chanNoEdit;
        KeyNavigation.right: dbChannelList;
    }

    Component
    {
        id: streamRow

        ListItem
        {
            Image
            {
                id: radioIcon
                x: 3; y:3; height: parent.height - 6; width: height
                source: if (icon)
                    settings.masterBackend + "Guide/GetChannelIcon?ChanId=" + chanid
                else
                    mythUtils.findThemeFile("images/grid_noimage.png")
            }

            ListText
            {
                width: dbChannelList.width; height: 50
                x: radioIcon.width + 5
                text: name + " ~ " + callsign + " ~ " + channum + " ~ " + xmltvid
            }
        }
    }


    ButtonList
    {
        id: dbChannelList
        x: 600; y: 30; width: 500; height: 500

        model: dbChannelsModel
        delegate: streamRow

        Keys.onEscapePressed: if (stack.depth > 1) {stack.pop()} else Qt.quit();
        Keys.onReturnPressed:
        {
            returnSound.play();
            var url = model.data(model.index(currentIndex, 4));
            event.accepted = true;
        }

        KeyNavigation.left: sdChannelList;
        KeyNavigation.right: chanNoEdit;
    }

    BaseEdit
    {
        id: chanNoEdit
        x: 30; y: 600
        width: 240
        text: dbChannelList.model.data(dbChannelList.model.index(dbChannelList.currentIndex, 1))
        KeyNavigation.up: sdChannelList
        KeyNavigation.down: chanNameEdit
        KeyNavigation.left: saveButton
        KeyNavigation.right: chanNoButton
    }

    BaseButton
    {
        id: chanNoButton;
        x: 280; y: 600;
        width: 50; height: 50
        text: "F1";
        KeyNavigation.up: sdChannelList
        KeyNavigation.down: chanNameButton
        KeyNavigation.right: callsignEdit
        KeyNavigation.left: chanNoEdit

        onClicked:
        {
            chanNoEdit.text = sdChannelList.model.get(sdChannelList.currentIndex).channo;
            //dbChannelList.model.data(dbChannelList.model.index(dbChannelList.currentIndex, 1)) = sdChannelList.model.get(sdChannelList.currentIndex).channo;
        }
    }

   BaseEdit
    {
        id: chanNameEdit
        x: 30; y: 650
        width: 240
        text: dbChannelList.model.data(dbChannelList.model.index(dbChannelList.currentIndex, 3))
        KeyNavigation.up: chanNoEdit;
        KeyNavigation.down: callsignEdit;
        KeyNavigation.left: xmltvidEdit
        KeyNavigation.right: chanNameButton
    }

    BaseButton
    {
        id: chanNameButton;
        x: 280; y: 650;
        width: 50; height: 50
        text: "F2";
        KeyNavigation.up: chanNoButton;
        KeyNavigation.down: callsignEdit;
        KeyNavigation.left: chanNameEdit
        KeyNavigation.right: chanNameButton
        onClicked:
        {
            //chanNameEdit.text = sdChannelList.model.get(sdChannelList.currentIndex).name;
            //dbChannelList.model.data(dbChannelList.model.index(dbChannelList.currentIndex, 3)) = sdChannelList.model.get(sdChannelList.currentIndex).name
        }
    }

    BaseEdit
    {
        id: callsignEdit
        x: 400; y: 600
        width: 390
        text: dbChannelList.model.data(dbChannelList.model.index(dbChannelList.currentIndex, 2))
        KeyNavigation.up: chanNameEdit;
        KeyNavigation.down: xmltvidEdit;
        KeyNavigation.left: chanNoButton
        KeyNavigation.right: callsignButton
    }

    BaseButton
    {
        id: callsignButton;
        x: 800; y: 600;
        width: 50; height: 50
        text: "F3";
        KeyNavigation.up: dbChannelList
        KeyNavigation.down: xmltvButton
        KeyNavigation.left: callsignEdit
        KeyNavigation.right: saveButton
        onClicked:
        {
            callsignEdit.text = sdChannelList.model.get(sdChannelList.currentIndex).callsign;
            //dbChannelList.model.data(dbChannelList.model.index(dbChannelList.currentIndex, 3)) = sdChannelList.model.get(sdChannelList.currentIndex).callsign;
        }
    }

    BaseEdit
    {
        id: xmltvidEdit
        x: 400; y: 650
        width: 390
        text: dbChannelList.model.data(dbChannelList.model.index(dbChannelList.currentIndex, 5))
        KeyNavigation.up: callsignEdit;
        KeyNavigation.down: saveButton;
        KeyNavigation.left: chanNameButton
        KeyNavigation.right: xmltvButton
    }

    BaseButton
    {
        id: xmltvButton;
        x: 800; y: 650;
        width: 50; height: 50
        text: "F4";
        KeyNavigation.up: callsignButton
        KeyNavigation.down: dbChannelList
        KeyNavigation.left: xmltvidEdit
        KeyNavigation.right: saveButton
        onClicked:
        {
            xmltvidEdit.text = sdChannelList.model.get(sdChannelList.currentIndex).xmltvid;
            //dbChannelList.model.data(dbChannelList.model.index(dbChannelList.currentIndex, 5)) = sdChannelList.model.get(sdChannelList.currentIndex).xmltvid;
        }
    }

    BaseButton
    {
        id: saveButton;
        x: xscale(1050); y: yscale(630);
        text: "Save";
        KeyNavigation.up: dbChannelList
        KeyNavigation.down: dbChannelList
        KeyNavigation.left: xmltvButton
        KeyNavigation.right: chanNameEdit
        onClicked:
        {
            var chanid = dbChannelList.model.data(dbChannelList.model.index(dbChannelList.currentIndex, 0))
            console.log("save button - chanid is: " + chanid);
            dbUtils.updateChannel(chanid,
                          chanNameEdit.text,
                          chanNoEdit.text,
                          xmltvidEdit.text,
                          callsignEdit.text);
        }
    }
}
