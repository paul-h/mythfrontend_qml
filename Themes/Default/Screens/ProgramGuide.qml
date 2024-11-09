import QtQuick
import QtQml.XmlListModel

import Base 1.0
import Dialogs 1.0
import Models 1.0
import mythqml.net 1.0

BaseScreen
{
    defaultFocusItem: channelList

    Component.onCompleted:
    {
        showTitle(false, "");
        setHelp("https://mythqml.net/help/tv_epg.php#top");
        showTime(false);
        showTicker(false);
    }

    Connections
    {
        target: webSocket
        onTextMessageReceived:
        {
            if (message === "SCHEDULE_CHANGE")
            {
                log.debug(Verbose.WEBSOCKET, "ProgramGuide: Scheduled changed - reloading program model");
                guideModel.reload();
            }
        }
    }

    BaseBackground { x: xscale(10); y: yscale(10); width: parent.width - xscale(20); height: yscale(200) }

    TitleText
    {
        id: programTitle
        x: xscale(20); y: yscale(20); width: parent.width - xscale(40)
    }

    InfoText
    {
        id: programDesc
        x: xscale(20); y: yscale(60); width: parent.width - xscale(40)
        height: yscale(120)
        multiline: true
    }

    InfoText
    {
        id: programStatus
        x: xscale(1000); y: yscale(17); width: xscale(220)
        horizontalAlignment: Text.AlignRight
        fontColor: if (text === "Recording") "red"; else theme.infoFontColor;
    }

    InfoText
    {
        id: programCategory
        x: xscale(20); y: yscale(160); width: xscale(220)
        fontColor: "grey"
    }

    InfoText
    {
        id: programEpisode
        x: xscale(500); y: yscale(160); width: xscale(320)
        fontColor: "grey"
    }

    InfoText
    {
        id: programFirstAired
        x: xscale(1030); y: yscale(160); width: xscale(220)
        fontColor: "grey"
        horizontalAlignment: Text.AlignRight
    }

    BaseBackground { x: xscale(10); y: yscale(220); width: parent.width - xscale(20); height: yscale(460) }

    Keys.onPressed: event =>
    {
        event.accepted = true;

        if (event.key === Qt.Key_Less)
        {
            if (channelList.focus)
            {
                timeSelector.selectPrevious();
                var now = timeSelector.model.get(timeSelector.currentIndex).itemData;
                guideModel.startTime = Qt.formatDateTime(now, "yyyy-MM-ddThh:mm:ss");
                now.setDate(now.getDate() + 1);
                guideModel.endTime = Qt.formatDateTime(now, "yyyy-MM-ddThh:mm:ss");
                guideModel.load();
            }
            else
            {
                channelSelector.selectPrevious();
                channelList.currentIndex = channelSelector.currentIndex;
            }
        }
        else if (event.key === Qt.Key_Greater)
        {
            if (channelList.focus)
            {
                timeSelector.selectNext();
                var now2 = timeSelector.model.get(timeSelector.currentIndex).itemData;
                guideModel.startTime = Qt.formatDateTime(now2, "yyyy-MM-ddThh:mm:ss");
                now2.setDate(now2.getDate() + 1);
                guideModel.endTime = Qt.formatDateTime(now, "yyyy-MM-ddThh:mm:ss");
                guideModel.load();
            }
            else
            {
                channelSelector.selectNext();
                channelList.currentIndex = channelSelector.currentIndex;
            }
        }
        else if (event.key === Qt.Key_F1)
        {
            // RED
        }
        else if (event.key === Qt.Key_F2)
        {
            // GREEN
            groupMenu.show();
        }
        else if (event.key === Qt.Key_F3)
        {
            // YELLOW
            channelsModel.orderByName = !channelsModel.orderByName;
            footer.yellowText = "Sort " + (channelsModel.orderByName ? "(Channel Name)" : "(Channel Number)")
        }
        else if (event.key === Qt.Key_F4)
        {
            //BLUE
            if (videoPlayer.visible)
            {
                videoPlayer.stop();
                videoPlayer.visible = false;
            }
            else
            {
                //TODO check encoder availability
                var encoderNum = captureCardModel.get(0).CardId
                var hostname = captureCardModel.get(0).HostName
                var chanNum = channelList.model.get(channelList.currentIndex).ChanNum;
                videoPlayer.visible = true;
                videoPlayer.source = "myth://type=livetv:server=" + hostname + ":sgroup=default:encoder=" + encoderNum + ":channum=" + chanNum
            }
        }
        else if (event.key === Qt.Key_A)
        {
            playerSources.channelGroups.addChannelToGroup(channelList.model.get(channelList.currentIndex).ChanId, 1)
        }
        else if (event.key === Qt.Key_R)
        {
            playerSources.channelGroups.removeChannelFromGroup(channelList.model.get(channelList.currentIndex).ChanId, 1)
        }
        else
            event.accepted = false;
    }

    ListModel { id: timeModel }

    BaseSelector
    {
        id: timeSelector
        x: channelList.x + xscale(10); y: yscale(224); width: channelList.width - xscale(20)
        showBackground: false

        model: timeModel
        Component.onCompleted:
        {
            var now = new Date(Date.now());

            // round to nearest 30mins
            if (now.getMinutes() < 30)
                now.setMinutes(0);
            else
                now.setMinutes(30)

            for (var x = 0; x < 2 * 24 * 14; x++)
            {
                if (x > 0)
                {
                    now = mythUtils.addMinutes(now, 30);
                }

                timeModel.append({"itemText": Qt.formatDateTime(now, "ddd dd/MM  hh:mm"), itemData: now})
            }
        }
    }

    Component
    {
        id: channelRow

        ListItem
        {
            ListText
            {
                width: xscale(80)
                x: xscale(5)
                text: ChanNum
            }

            Image
            {
                id: chanIcon
                x: xscale(90); y: yscale(3); height: parent.height - yscale(6); width: height
                asynchronous: true
                source: settings.masterBackend + "Guide/GetChannelIcon?ChanId=" + ChanId
                onStatusChanged: if (status == Image.Error) source = mythUtils.findThemeFile("images/grid_noimage.png")
            }

            ListText
            {
                width: channelList.width; height: yscale(50)
                x: chanIcon.width + xscale(95)
                text: ChannelName
            }
        }
    }

    ChannelsModel
    {
        id: channelsModel
        details: false
        channelGroupId: -1
        onStatusChanged:
        {
            if (status == XmlListModel.Ready)
            {
                channelModel.clear();

                for (var x = 0; x < count; x++)
                {
                    var chanNum = channelList.model.get(x).ChanNum;
                    var chanName = channelList.model.get(x).ChannelName;
                    channelModel.append({"itemText": chanNum + " " + chanName})
                }
            }
        }
    }

    ButtonList
    {
        id: channelList
        x: xscale(20); y: yscale(270); width: (parent.width / 2) - xscale(50); height: yscale(400)

        model: channelsModel
        delegate: channelRow

        Keys.onReturnPressed:
        {
            if (videoPlayer.visible)
            {
                //TODO check encoder availability
                var encoderNum = captureCardModel.get(0).CardId
                var hostname = captureCardModel.get(0).HostName
                var chanNum = channelList.model.get(channelList.currentIndex).ChanNum;
                videoPlayer.source = "myth://type=livetv:server=" + hostname + ":sgroup=default:encoder=" + encoderNum + ":channum=" + chanNum
            }
        }

        KeyNavigation.left: if (isPanel)  previousFocusItem; else programList;
        KeyNavigation.right: programList;

        onItemSelected:
        {
            guideModel.chanId = model.get(currentIndex).ChanId;
            guideModel.load();
            channelSelector.selectItem(model.get(currentIndex).ChanNum + " " + model.get(currentIndex).ChannelName);
        }
    }

    CaptureCardModel { id: captureCardModel }
    ListModel { id: channelModel }

    BaseSelector
    {
        id: channelSelector
        x: programList.x + xscale(10); y: yscale(224); width: programList.width - xscale(20)
        showBackground: false

        model: channelModel
    }

    Component
    {
        id: programRow

        ListItem
        {
            ListText
            {
                width: programList.width; height: yscale(50)
                x: xscale(5)
                text: Qt.formatDateTime(StartTime, "hh:mm") + " " + Title
            }

            Image
            {
                x: xscale(600); y: yscale(10); height: parent.height - yscale(20); width: height
                source: if (RecordingStatus === "Recording") mythUtils.findThemeFile("images/record.png"); else ""
            }
        }
    }

    ProgramListModel
    {
        id: guideModel
        startTime:
        {
            var now2 = Date.now();
            return Qt.formatDateTime(now2, "yyyy-MM-ddThh:mm:ss");
        }
        endTime:
        {
            var now2 = Date.now();
            now2.setDate(now2.getDate() + 1);
            return Qt.formatDateTime(now2, "yyyy-MM-ddThh:mm:ss");
        }

        onStatusChanged: if (status == XmlListModel.Ready)  updateProgramDetails()
    }

    ButtonList
    {
        id: programList
        x: (parent.width / 2) + xscale(20); y: yscale(270); width: (parent.width / 2) - xscale(50); height: yscale(400)

        model: guideModel
        delegate: programRow

        Keys.onReturnPressed:
        {
        }

        KeyNavigation.left: channelList;
        KeyNavigation.right: channelList;

        onCurrentIndexChanged: updateProgramDetails();
    }

    Footer
    {
        id: footer
        redText: "Options"
        greenText: "Show (All Channels)"
        yellowText: "Sort (Channel Number)"
        blueText: "Record Options"
    }

    VideoPlayerQmlVLC
    {
        id: videoPlayer
        x: xscale(920); y: yscale(13); width: xscale(343); height: yscale(195)
        visible: false
    }

    function updateProgramDetails()
    {
        if (guideModel.count > 0)
        {
            programTitle.text = programList.model.get(programList.currentIndex).Title

            if (programList.model.get(programList.currentIndex).SubTitle !== "")
                programDesc.text = "\"" + programList.model.get(programList.currentIndex).SubTitle + "\"  " + programList.model.get(programList.currentIndex).Description
            else
                programDesc.text = programList.model.get(programList.currentIndex).Description

            var state = programList.model.get(programList.currentIndex).RecordingStatus;
            if (state === "Unknown")
                programStatus.text = "Not Recording";
            else
                programStatus.text = programList.model.get(programList.currentIndex).RecordingStatus

            programCategory.text = programList.model.get(programList.currentIndex).Category

            var season = programList.model.get(programList.currentIndex).Season
            var episode = programList.model.get(programList.currentIndex).Episode
            var total = programList.model.get(programList.currentIndex).TotalEpisodes
            var res = ""

            if (season > 0)
                res = "Season: " + season + " ";
            if (episode > 0)
            {
                res += " Episode: " + episode;

                if (total > 0)
                    res += "/" + total;
            }

            programEpisode.text = res;

            if (programList.model.get(programList.currentIndex).AirDate !== undefined && programList.model.get(programList.currentIndex).AirDate !== "")
                programFirstAired.text = "First Aired: " + Qt.formatDateTime(programList.model.get(programList.currentIndex).AirDate, "dd/MM/yyyy");
            else
                programFirstAired.text = ""
        }
        else
        {
            programTitle.text = "No programs Found For This Channel"
            programDesc.text = "N/A"
            programStatus.text = "N/A";
            programCategory.text = "Unknown"
            programEpisode.text = "";
            programFirstAired.text = ""
        }
    }

    PopupMenu
    {
        id: groupMenu

        title: "Channel Group"
        message: "Only show channels in the selected group"
        width: xscale(500); height: yscale(600)

        restoreSelected: true;

        onItemSelected: (itemText, itemData) =>
        {
            channelList.focus = true;
            footer.greenText = "Show (" + itemText +")";

            channelsModel.channelGroupId = itemData;
        }
        onCancelled:
        {
            channelList.focus = true;
        }

        Component.onCompleted:
        {
            addMenuItem("", "All Channels", -1);
            for (var x = 0; x < playerSources.channelGroups.count; x++)
                addMenuItem("", playerSources.channelGroups.get(x).Name, playerSources.channelGroups.get(x).GroupId);
        }
    }

    function createMenu(menu)
    {
         menu.clear();

        menu.append({"menutext": "All", "loaderSource": "MythTVChannelViewer.qml", "menuSource": "", "filter": -1});

        for (var x = 0; x < playerSources.channelGroups.count; x++)
            menu.append({"menutext": playerSources.channelGroups.get(x).Name, "loaderSource": "MythTVChannelViewer.qml", "menuSource": "", "filter": playerSources.channelGroups.get(x).GroupId});
    }

   function setFilter(groupName, groupId)
   {
       footer.greenText = "Show (" + groupName +")";

       channelsModel.channelGroupId = groupId;
   }
}
