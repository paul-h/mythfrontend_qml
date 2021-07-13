import QtQuick 2.0
import QtQml 2.2
import QtQuick.XmlListModel 2.0
import Base 1.0
import Dialogs 1.0
import Models 1.0
import "../../../Util.js" as Util
import mythqml.net 1.0

BaseScreen
{
    id: root

    defaultFocusItem: channelGrid

    property alias sourceId: feedSource.sourceId
    property alias channelGroupId: feedSource.channelGroupId
    property bool showPreview: false

    signal feedSelected(string feedSource, string filter, int index)

    Component.onCompleted:
    {
        showTitle(true, "LiveTV Channel Viewer");
        setHelp("https://mythqml.net/help/tv_watchtv.php#top");
        showTime(true);
        showTicker(false);

        while (stack.busy) {};

        sourceId = -1;

        if (isPanel)
            channelGroupId =  -1;
        else
            channelGroupId = dbUtils.getSetting("LastChannelGroupId", settings.hostName, -1);

        if (channelGroupId == -1)
            footer.greenText = "Show (All Categories)"
        else
        {
            var index = playerSources.channelGroups.findById(channelGroupId);
            if (index !== -1)
                footer.greenText = "Show (" + playerSources.channelGroups.get(index).Name + ")"
            else
                footer.greenText = "Show (All Categories)";
        }

        var filter = sourceId + "," + channelGroupId;
        feedSource.feedModelLoaded.connect(updateChannelDetails);
        feedSource.switchToFeed("Live TV", filter, channelGrid.currentIndex);
    }

    Component.onDestruction:
    {
        dbUtils.setSetting("LastChannelGroupId", settings.hostName, feedSource.channelGroupId)
    }

    Timer
    {
        id: updateTimer
        interval: 1000; running: true; repeat: true
        onTriggered:
        {
            // update now/next program once per minute at 00 seconds
            var now = new Date(Date.now());
            if (now.getSeconds() === 0)
                 getNowNext();
            else
                updateTimeIndicator();
        }
    }

    Timer
    {
        id: previewTimer
        interval: 3000; running: false; repeat: false
        onTriggered:
        {
            if (showPreview)
                updatePlayer();
        }
    }

    ProgramListModel
    {
        id: guideModel
        startTime:
        {
            var now = new Date();
            var now2 = new Date(Date.now() + (now.getTimezoneOffset() * 60 * 1000));
            return Qt.formatDateTime(now2, "yyyy-MM-ddThh:mm:ss");
        }
        endTime:
        {
            var now = new Date();
            var now2 = new Date(Date.now() + (now.getTimezoneOffset() * 60 * 1000));
            now2.setDate(now2.getDate() + 1);
            return Qt.formatDateTime(now2, "yyyy-MM-ddThh:mm:ss");
        }

        onStatusChanged: if (status == XmlListModel.Ready) updateNowNext()
    }

    FeedSource
    {
        id: feedSource
    }

    Keys.onPressed:
    {
        event.accepted = true;

        if (event.key === Qt.Key_M)
        {
        }
        else if (event.key === Qt.Key_F1)
        {
            // RED
            // FIXME
            //channelsModel.orderByName = !channelsModel.orderByName;
            //footer.redText = "Sort " + (channelsModel.orderByName ? "(Channel Name)" : "(Channel Number)")
        }
        else if (event.key === Qt.Key_F2)
        {
            // GREEN
            groupMenu.show();
        }
        else if (event.key === Qt.Key_F3)
        {
            // YELLOW
            sourceMenu.show();
        }
        else if (event.key === Qt.Key_F4)
        {
            //BLUE
            if (showPreview)
            {
                videoPlayer.stop();
                videoPlayer.visible = false;
                showPreview = false;
            }
            else
            {
                showPreview = true;
                updatePlayer();
            }
        }
        else
            event.accepted = false;
    }

    BaseBackground
    {
        id: listBackground
        x: xscale(10); y: yscale(45); width: parent.width - x - xscale(10); height: yscale(410)
    }

    BaseBackground { x: xscale(10); y: yscale(465); width: parent.width - xscale(20); height: yscale(210) }

    InfoText
    {
        x: _xscale(900); y: yscale(0); width: _xscale(120);
        text: (channelGrid.currentIndex + 1) + " of " + channelGrid.model.count;
    }

   LabelText
    {
        id: noMatches
        x: xscale(22)
        y: yscale(55)
        width: parent.width - xscale(44)
        height: yscale(390)
        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.AlignHCenter
        text: "No Matching Channels Found"
    }

    ButtonGrid
    {
        id: channelGrid
        x: xscale(22)
        y: yscale(55)
        width: parent.width - xscale(44)
        height: yscale(390)
        cellWidth: width / (root.isPanel ? 4 : 5);
        cellHeight: yscale(130)

        Component
        {
            id: channelDelegate
            Item
            {
                x: 0;
                y: 0;
                width: channelGrid.cellWidth;
                height: channelGrid.cellHeight;
                Image
                {
                    opacity: 0.80
                    asynchronous: true
                    anchors.fill: parent
                    anchors.margins: xscale(5)
                    source: IconURL ? settings.masterBackend + "Guide/GetChannelIcon?ChanId=" + ChanId : mythUtils.findThemeFile("images/grid_noimage.png");
                    onStatusChanged: if (status == Image.Error) source = mythUtils.findThemeFile("images/grid_noimage.png");
                }
            }
        }

        model: feedSource.feedList
        delegate: channelDelegate
        focus: true

        Keys.onReturnPressed:
        {
            if (channelGrid.model.count === 0)
            {
                errorSound.play();
                return;
            }

            videoPlayer.stop();
            showPreview = false;
            returnSound.play();

            var filter = sourceId + "," + channelGroupId;

            if (root.isPanel)
            {
                internalPlayer.previousFocusItem = channelGrid;
                feedSelected("Live TV", filter, channelGrid.currentIndex);
            }
            else
            {
                var item = stack.push({item: Qt.resolvedUrl("InternalPlayer.qml"), properties:{defaultFeedSource:  "Live TV", defaultFilter: filter, defaultCurrentFeed: channelGrid.currentIndex}});
                item.feedChanged.connect(feedChanged);
            }
                event.accepted = true;
        }

        Keys.onPressed:
        {
            if (event.key === Qt.Key_Left && ((currentIndex % 4) === 0 && previousFocusItem))
            {
                event.accepted = true;
                escapeSound.play();
                previousFocusItem.focus = true;
            }
            else
                event.accepted = false;
        }

        onCurrentIndexChanged:
        {

            videoPlayer.stop();
            videoPlayer.visible = false;
            updateChannelDetails();
            previewTimer.start();
        }
    }

    TitleText
    {
        id: title
        x: xscale(30); y: yscale(470)
        width: parent.width - _xscale(1280 - 900); height: yscale(35)
        verticalAlignment: Text.AlignTop
        multiline: true
    }

    Image
    {
        id: channelIcon
        x: parent.width - _xscale(1280 - 950); y: yscale(480); width: _xscale(266); height: _yscale(150)
        asynchronous: true
        visible: !videoPlayer.visible
        onStatusChanged: if (status == Image.Error) source = mythUtils.findThemeFile("images/grid_noimage.png")
    }

    VideoPlayerQmlVLC
    {
        id: videoPlayer
        x: _xscale(970); y: _yscale(480); width: _xscale(266); height: _yscale(150)
        visible: false
    }

    RichText
    {
        id: programTitle
        x: xscale(30)
        y: yscale(500)
        width: _xscale(700)
        label: "Now: "
    }

    InfoText
    {
        id: programDesc
        x: xscale(30); y: yscale(545)
        width: _xscale(910); height: yscale(75)
        verticalAlignment: Text.AlignTop
        multiline: true
    }

    InfoText
    {
        id: programStatus
        x: _xscale(970); y: yscale(630); width: _xscale(266)
        horizontalAlignment: Text.AlignHCenter
        fontColor: if (text === "Recording") "red"; else theme.infoFontColor;
    }

    InfoText
    {
        id: programCategory
        x: xscale(20); y: yscale(630); width: _xscale(220)
        fontColor: "grey"
    }

    InfoText
    {
        id: programEpisode
        x: _xscale(315); y: yscale(630); width: _xscale(320)
        horizontalAlignment: Text.AlignHCenter
        fontColor: "grey"
    }

    InfoText
    {
        id: programFirstAired
        x: _xscale(650); y: yscale(630); width: _xscale(280)
        fontColor: "grey"
        horizontalAlignment: Text.AlignRight
    }

    InfoText
    {
        id: programLength
        x: _xscale(850); y: yscale(500); width: _xscale(90)
        fontColor: "grey"
        horizontalAlignment: Text.AlignRight
    }

    RichText
    {
        id: programNext
        x: xscale(30)
        y: yscale(606)
        width: _xscale(910)
        label: "Next: "
    }

    Item
    {
        id: timeIndictor

        property int position: 0
        property int length: 100

        x: _xscale(740)
        y: yscale(522)
        width: _xscale(100)
        height: yscale(8)

        Rectangle
        {
            anchors.fill: parent
            color: "white"
        }

        Rectangle
        {
            x: 0; y: 0; height: parent.height;
            width: (parent.width / timeIndictor.length) * timeIndictor.position
            color: "red"
        }
    }

    Image
    {
        id: recordingIcon
        x: _xscale(900); y: yscale(630); width: xscale(32); height: yscale(32)
        source: mythUtils.findThemeFile("images/recording.png")
        visible: guideModel.get(0).RecordingStatus === "Recording"
    }

    Footer
    {
        id: footer
        redText: "Sort (Channel Number)"
        greenText: "Show (All Categories)"
        yellowText: "Show (All Sources)"
        blueText: "Toggle Preview"
    }

    PopupMenu
    {
        id: groupMenu

        title: "Channel Group"
        message: "Only show channels in the selected group"
        width: xscale(500); height: yscale(600)

        restoreSelected: true;

        onItemSelected:
        {
            channelGrid.focus = true;
            footer.greenText = "Show (" + itemText +")";
            feedSource.channelGroupId = itemData;
            feedSource.switchToLiveTV(channelGroupId, sourceId);
        }
        onCancelled:
        {
            channelGrid.focus = true;
        }

        Component.onCompleted:
        {
            addMenuItem("", "All Categories", -1);
            for (var x = 0; x < playerSources.channelGroups.count; x++)
                addMenuItem("", playerSources.channelGroups.get(x).Name, playerSources.channelGroups.get(x).GroupId);
        }
    }

    PopupMenu
    {
        id: sourceMenu

        title: "Channel Source"
        message: "Only show channels from the selected source"
        width: xscale(500); height: yscale(600)

        restoreSelected: true;

        onItemSelected:
        {
            channelGrid.focus = true;
            footer.yellowText = "Show (" + itemText +")";
            feedSource.sourceId = itemData;
        }
        onCancelled:
        {
            channelGrid.focus = true;
        }

        Component.onCompleted:
        {
            addMenuItem("", "All Sources", -1);
            for (var x = 0; x < playerSources.videoSourceList.count; x++)
                addMenuItem("", playerSources.videoSourceList.get(x).SourceName, playerSources.videoSourceList.get(x).Id);
        }
    }

    function updateChannelDetails()
    {
        if (channelGrid.model.count === 0)
        {
            title.text = "No guide data available for this channel";
            timeIndictor.position = 0;
            timeIndictor.length = 100;
            programTitle.info = "";
            programLength.text = "";
            programDesc.text = "N/A";
            programStatus.text = "N/A";
            programCategory.text = "";
            channelIcon.source = "";
            programFirstAired.text = ""
            programNext.info = ""
            programEpisode.text = ""
            noMatches.visible = true;
        }
        else
        {
            var currentItem = channelGrid.model.get(channelGrid.currentIndex);

            if (!currentItem)
                return;

            title.text = currentItem.title;

            // icon
            channelIcon.source = currentItem.IconURL ? settings.masterBackend + "Guide/GetChannelIcon?ChanId=" + currentItem.ChanId : mythUtils.findThemeFile("images/grid_noimage.png");

            getNowNext();

            if (videoPlayer.visible)
            {
                previewTimer.start();
            }

            noMatches.visible = false;
        }
    }

    function getNowNext()
    {
        // get now/next program
        var now = new Date();
        var now2 = new Date(Date.now() + (now.getTimezoneOffset() * 60 * 1000));

        // work around a MythTV services API bug
        if (now2.getSeconds() === 0)
            now2.setSeconds(1);

        guideModel.startTime = Qt.formatDateTime(now2, "yyyy-MM-ddThh:mm:ss");

        now2.setDate(now2.getDate() + 1);
        guideModel.endTime = Qt.formatDateTime(now2, "yyyy-MM-ddThh:mm:ss");
        guideModel.chanId = channelGrid.model.get(channelGrid.currentIndex).ChanId;
        guideModel.load();
    }

    function updateNowNext()
    {
        if (guideModel.count > 0)
        {
            // update the timeIndictor
            var dtStart = Date.parse(guideModel.get(0).StartTime);
            var dtEnd = Date.parse(guideModel.get(0).EndTime);
            var dtNow = Date.now();

            var position = dtNow - dtStart;
            var length = dtEnd - dtStart;

            timeIndictor.position = position;
            timeIndictor.length = length;

            var startDate = new Date(dtStart);
            var endDate = new Date(dtEnd);

            programTitle.info = guideModel.get(0).Title + " (" + startDate.toLocaleTimeString(Qt.locale(), "hh:mm") + " - " + endDate.toLocaleTimeString(Qt.locale(), "hh:mm") + ")";

            programLength.text = length / 60000 + " mins";

            if (guideModel.get(0).SubTitle !== "")
               programDesc.text = "\"" + guideModel.get(0).SubTitle + "\"  " + guideModel.get(0).Description
            else
               programDesc.text = guideModel.get(0).Description

            var state = guideModel.get(0).RecordingStatus;
            if (state === "Unknown")
                programStatus.text = "Not Recording";
            else
                programStatus.text = guideModel.get(0).RecordingStatus

            programCategory.text = guideModel.get(0).Category

            var season = guideModel.get(0).Season
            var episode = guideModel.get(0).Episode
            var total = guideModel.get(0).TotalEpisodes
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

            if (guideModel.get(0).AirDate !== undefined)
                programFirstAired.text = "First Aired: " + Qt.formatDateTime(guideModel.get(0).AirDate, "dd/MM/yyyy");
            else
                programFirstAired.text = ""

            // update next program
            startDate = new Date(Date.parse(guideModel.get(1).StartTime));
            endDate = new Date(Date.parse(guideModel.get(1).EndTime));
            programNext.info = guideModel.get(1).Title + " (" + startDate.toLocaleTimeString(Qt.locale(), "hh:mm") + " - " + endDate.toLocaleTimeString(Qt.locale(), "hh:mm") + ")";
        }
        else
        {
            programTitle.info = "No guide data available for this channel"
            programDesc.text = "N/A"
            programStatus.text = "N/A";
            programCategory.text = "Unknown"
            programEpisode.text = "";
            programFirstAired.text = ""
            programLength.text = ""
            programNext.info = ""

            timeIndictor.position = 0;
            timeIndictor.length = 100;

        }
    }

    function updateTimeIndicator()
    {
        if (guideModel.count > 0)
        {
            var dtStart = Date.parse(guideModel.get(0).StartTime);
            var dtEnd = Date.parse(guideModel.get(0).EndTime);
            var dtNow = Date.now();

            var position = dtNow - dtStart;
            var length = dtEnd - dtStart;

            timeIndictor.position = position;
            timeIndictor.length = length;
        }
    }

    function updatePlayer()
    {
        //TODO check encoder availability
        var encoderNum = 1
        var ip = settings.masterIP
        var chanNum = channelGrid.model.get(channelGrid.currentIndex).ChanNum;
        var pin = settings.securityPin;
        videoPlayer.visible = true;
        videoPlayer.source = "myth://type=livetv:server=" + ip + ":pin=" + pin + ":encoder=" + encoderNum + ":channum=" + chanNum
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

       feedSource.channelGroupId = groupId;
   }

   function feedChanged(feedSource, filter, index)
   {
        if (feedSource !== "Live TV")
            return;

        var list = filter.split(",");
        var channelGroupId = -1;
        var sourceId = -1;
        var i;
        if (list.length === 2)
        {
            sourceId = parseInt(list[0], 10);
            channelGroupId = parseInt(list[1], 10);
        }

        if (channelGroupId != root.channelGroupId || sourceId != root.sourceId)
        {
            root.sourceId = sourceId;
            root.channelGroupId = channelGroupId

            if (channelGroupId == -1)
                footer.greenText = "Show (All Categories)"
            else
            {
                var i = playerSources.channelGroups.findById(channelGroupId);
                if (i !== -1)
                    footer.greenText = "Show (" + playerSources.channelGroups.get(index).Name + ")"
                else
                    footer.greenText = "Show (All Categories)";
            }

            if (sourceId == -1)
                footer.Text = "Show (All Sources)"
            else
            {
                var i = playerSources.videoSourceList.findById(sourceId);
                if (i !== -1)
                    footer.yellowText = "Show (" + playerSources.videoSourceList.get(i).SourceName + ")"
                else
                    footer.yellowText = "Show (All Sources)";
            }
        }

        channelGrid.currentIndex = index;
   }
}
