import QtQuick
import Base 1.0
import Models 1.0
import SortFilterProxyModel 0.2

BaseScreen
{
    defaultFocusItem: sdChannelList

    Component.onCompleted:
    {
        showTitle(false, "");
        showTime(false);
        showTicker(false);
        setHelp("https://mythqml.net/help/settings_channeleditor.php#top");
    }

    BaseBackground { anchors.fill: parent; anchors.margins: 10 }

    property list<QtObject> chanNameSorter:
    [
        RoleSorter { roleName: "name"; ascendingOrder: true }
    ]

    SDChannelsModel
    {
        id: sdChannelModel
    }

    Keys.onPressed: event =>
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
               x: xscale(3); y:yscale(3); height: parent.height - yscale(6); width: height
               source: if (icon) icon; else mythUtils.findThemeFile("images/grid_noimage.png");
            }
            ListText
            {
                width:sdChannelList.width - channelImage.width - xscale(10); height: yscale(50)
                x: channelImage.width + xscale(5)
                text: name + " ~ " + callsign + " ~ " + channo + " ~ " + xmltvid
            }
        }
    }

    ButtonList
    {
        id: sdChannelList
        x: xscale(20); y: yscale(20); width: (parent.width - xscale(50)) / 2; height: yscale(550)

        model: sdChannelModel.model
        delegate: listRow

        Keys.onReturnPressed:
        {
            chanNoEdit.text = sdChannelList.model.get(sdChannelList.currentIndex).channo;
            chanNameEdit.text = sdChannelList.model.get(sdChannelList.currentIndex).name;
            callsignEdit.text = sdChannelList.model.get(sdChannelList.currentIndex).callsign;
            xmltvidEdit.text = sdChannelList.model.get(sdChannelList.currentIndex).xmltvid;
            returnSound.play();
        }

        KeyNavigation.left:  saveButton;
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
                x: xscale(3); y: yscale(3); height: parent.height - yscale(6); width: height
                source: icon ? settings.masterBackend + "Guide/GetChannelIcon?ChanId=" + chanid : mythUtils.findThemeFile("images/grid_noimage.png")
            }

            ListText
            {
                width: dbChannelList.width - radioIcon.width - xscale(10); height: yscale(50)
                x: radioIcon.width + xscale(5)
                text: name + " ~ " + callsign + " ~ " + channum + " ~ " + xmltvid
            }
        }
    }


    ButtonList
    {
        id: dbChannelList
        x: ((parent.width - xscale(50)) / 2) + 30; y: yscale(20); width: (parent.width - xscale(50)) / 2; height: yscale(550)

        model: dbChannelsModel
        delegate: streamRow

        Keys.onReturnPressed:
        {
            returnSound.play();
            var channum = model.data(model.index(currentIndex, 1));
            console.log("channum: " + channum);
            for (var x = 0; x < sdChannelsProxyModel.count; x++)
            {
                if (sdChannelsProxyModel.get(x).channo == channum)
                {
                    sdChannelList.currentIndex = x;
                    break;
                }
            }

            event.accepted = true;
        }

        KeyNavigation.left: sdChannelList;
        KeyNavigation.right: saveButton;
    }

    BaseEdit
    {
        id: chanNoEdit
        x: _xscale(30); y: yscale(600)
        width: _xscale(240)
        text: dbChannelList.model.data(dbChannelList.model.index(dbChannelList.currentIndex, 1))
        KeyNavigation.up: sdChannelList
        KeyNavigation.down: chanNameEdit
        KeyNavigation.left: saveButton
        KeyNavigation.right: chanNoButton
    }

    BaseButton
    {
        id: chanNoButton;
        x: _xscale(280); y: yscale(600);
        width: xscale(50); height: yscale(50)
        text: "F1";
        KeyNavigation.up: sdChannelList
        KeyNavigation.down: chanNameButton
        KeyNavigation.right: callsignEdit
        KeyNavigation.left: chanNoEdit

        onClicked:
        {
            chanNoEdit.text = sdChannelList.model.get(sdChannelList.currentIndex).channo;
        }
    }

   BaseEdit
    {
        id: chanNameEdit
        x: _xscale(30); y: yscale(650)
        width: _xscale(240)
        text: dbChannelList.model.data(dbChannelList.model.index(dbChannelList.currentIndex, 3))
        KeyNavigation.up: chanNoEdit;
        KeyNavigation.down: callsignEdit;
        KeyNavigation.left: xmltvidEdit
        KeyNavigation.right: chanNameButton
    }

    BaseButton
    {
        id: chanNameButton;
        x: _xscale(280); y: yscale(650);
        width: xscale(50); height: yscale(50)
        text: "F2";
        KeyNavigation.up: chanNoButton;
        KeyNavigation.down: callsignEdit;
        KeyNavigation.left: chanNameEdit
        KeyNavigation.right: xmltvidEdit
        onClicked:
        {
            //chanNameEdit.text = sdChannelList.model.get(sdChannelList.currentIndex).name;
            //dbChannelList.model.data(dbChannelList.model.index(dbChannelList.currentIndex, 3)) = sdChannelList.model.get(sdChannelList.currentIndex).name
        }
    }

    BaseEdit
    {
        id: callsignEdit
        x: _xscale(400); y: yscale(600)
        width: _xscale(390)
        text: dbChannelList.model.data(dbChannelList.model.index(dbChannelList.currentIndex, 2))
        KeyNavigation.up: chanNameEdit;
        KeyNavigation.down: xmltvidEdit;
        KeyNavigation.left: chanNoButton
        KeyNavigation.right: callsignButton
    }

    BaseButton
    {
        id: callsignButton;
        x: _xscale(800); y: yscale(600);
        width: xscale(50); height: yscale(50)
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
        x: _xscale(400); y: yscale(650)
        width: _xscale(390)
        text: dbChannelList.model.data(dbChannelList.model.index(dbChannelList.currentIndex, 5))
        KeyNavigation.up: callsignEdit;
        KeyNavigation.down: saveButton;
        KeyNavigation.left: chanNameButton
        KeyNavigation.right: xmltvButton
    }

    BaseButton
    {
        id: xmltvButton;
        x: _xscale(800); y: yscale(650);
        width: xscale(50); height: yscale(50)
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
        x: _xscale(1050); y: yscale(630);
        width: _xscale(180)
        text: "Save (F5)";
        KeyNavigation.up: dbChannelList
        KeyNavigation.down: dbChannelList
        KeyNavigation.left: xmltvButton
        KeyNavigation.right: chanNameEdit
        onClicked:
        {
            var chanid = dbChannelList.model.data(dbChannelList.model.index(dbChannelList.currentIndex, 0))
            dbUtils.updateChannel(chanid,
                          chanNameEdit.text,
                          chanNoEdit.text,
                          xmltvidEdit.text,
                          callsignEdit.text);
        }
    }
}
