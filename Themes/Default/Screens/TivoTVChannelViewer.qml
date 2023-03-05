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

    property alias category: feedSource.category
    property alias definition: feedSource.definition
    property alias sort: feedSource.sort

    property bool showPreview: false

    property var _nowScheduleJson: undefined
    property var _nextScheduleJson: undefined
    property var _nowProgJson: undefined
    property var _nextProgJson: undefined

    property bool videoPlayerFullscreen: false

    property var nextProgObj
    signal feedSelected(string feedSource, string filter, int index)

    Component.onCompleted:
    {
        showTitle(true, "Tivo Channel Viewer");
        setHelp("https://mythqml.net/help/tv_watchtv.php#top");
        showTime(true);
        showTicker(false);

        while (stack.busy) {};

//        sourceId = -1;

//        if (isPanel)
//            channelGroupId =  -1;
//        else
//            channelGroupId = dbUtils.getSetting("LastChannelGroupId", settings.hostName, -1);

//        if (channelGroupId == -1)
//            footer.greenText = "Show (All Categories)"
//        else
//        {
//            var index = playerSources.channelGroups.findById(channelGroupId);
//            if (index !== -1)
//                footer.greenText = "Show (" + playerSources.channelGroups.get(index).Name + ")"
//            else
//                footer.greenText = "Show (All Categories)";
//        }

        sort = "ChanNo";
        var filter =  category + "," + definition + "," + sort;
        feedSource.feedModelLoaded.connect(updateChannelDetails);
        feedSource.switchToFeed("Tivo TV", filter, channelGrid.currentIndex);
    }

    Component.onDestruction:
    {
//        dbUtils.setSetting("LastChannelGroupId", settings.hostName, feedSource.channelGroupId)
    }

    Timer
    {
        id: updateTimer
        interval: 1000; running: true; repeat: true
        onTriggered:
        {
            if (_nowScheduleJson === undefined)
                return;

            // update now/next program once per minute at 00 seconds
            var now = new Date(Date.now());
            var dtStart =  new Date(_nowScheduleJson.airDateTime);
            var dtEnd = Util.addSeconds(dtStart, _nowScheduleJson.duration);
            if (now >= dtEnd)
                updateChannelDetails()
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
            //if (showPreview)
            //    updatePlayer();
        }
    }

    FeedSource
    {
        id: feedSource
    }

    SDJsonModel
    {
        id: sdAPI
    }

    Keys.onPressed:
    {
        event.accepted = true;

        if (event.key === Qt.Key_M)
        {
        }
        else if (event.key === Qt.Key_P)
        {
            videoPlayer.focus = true;
        }
        else if (event.key === Qt.Key_F1)
        {
            // RED
            if (feedSource.sort == "Name")
            {
                footer.redText = "Sort (Channel Number)";
                feedSource.sort = "ChanNo";
            }
            else
            {
                footer.redText = "Sort (Channel Name)";
                feedSource.sort = "Name";
            }
        }
        else if (event.key === Qt.Key_F2)
        {
            // GREEN
            categoryMenu.show();
        }
        else if (event.key === Qt.Key_F3)
        {
            // YELLOW
            definitionMenu.show();
        }
        else if (event.key === Qt.Key_F4)
        {
            //BLUE
            var currentItem = channelGrid.model.get(channelGrid.currentIndex);

            if (!currentItem)
                return;

            var plus1 = currentItem.Plus1;

            if (plus1 !== 0)
            {
                for (var x = 0; x < channelGrid.model.count; x++)
                {
                    if (channelGrid.model.get(x).ChanNo === plus1)
                    {
                        channelGrid.currentIndex = x;
                        break;
                    }
                }
            }
        }
        else if (event.key === Qt.Key_F)
        {
            toggleFullscreenPlayer();
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
                    source: Icon !== "" ? Icon : mythUtils.findThemeFile("images/grid_noimage.png");
                    onStatusChanged: if (status == Image.Error) source = mythUtils.findThemeFile("images/grid_noimage.png");
                }
                LabelText
                {
                    x: 5;
                    y: channelGrid.cellHeight - yscale(40)
                    width: channelGrid.cellWidth - xscale(10)
                    text: Name
                    horizontalAlignment: Text.AlignHCenter;
                    fontPixelSize: xscale(14)
                }
            }
        }

        model: feedSource.feedList
        //model: tivoChannels.model
        delegate: channelDelegate
        focus: true

        Keys.onReturnPressed:
        {
            if (channelGrid.model.count === 0)
            {
                errorSound.play();
                return;
            }

//            videoPlayer.stop();
//            showPreview = false;
//            returnSound.play();

            if (root.isPanel)
            {
                var sort = feedSource.sort;
                var filter =  category + "," + definition + "," + sort;
                internalPlayer.previousFocusItem = channelGrid;
                feedSelected("Tivo TV", filter, channelGrid.currentIndex);
            }
            else
            {
                videoPlayer.changeChannel(model.get(currentIndex).ChanNo);
//                var item = stack.push({item: Qt.resolvedUrl("InternalPlayer.qml"), properties:{defaultFeedSource:  "Live TV", defaultFilter: filter, defaultCurrentFeed: channelGrid.currentIndex}});
//                item.feedChanged.connect(feedChanged);
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

            //videoPlayer.stop();
            //videoPlayer.visible = false;
            updateChannelDetails();
            //previewTimer.start();
        }

        KeyNavigation.up: videoPlayer;
        KeyNavigation.down: videoPlayer;
        KeyNavigation.left: videoPlayer;
        KeyNavigation.right: videoPlayer;
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
        x: xscale(20); y: yscale(630); width: _xscale(320)
        fontColor: "grey"
    }

    InfoText
    {
        id: programEpisode
        x: _xscale(345); y: yscale(630); width: _xscale(290)
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
        visible: false //guideModel.count > 0 ?  guideModel.get(0).RecordingStatus === "Recording" : false
    }

    Footer
    {
        id: footer
        redText: "Sort (Channel Number)"
        greenText: "Show (All Categories)"
        yellowText: "Definition (All)"
        blueText: "Watch on +1"
    }

    VideoPlayerTivo
    {
        id: videoPlayer
        x: _xscale(970); y: _yscale(480); width: _xscale(266); height: _yscale(150)
        visible: true

        KeyNavigation.up: channelGrid;
        KeyNavigation.down: channelGrid;
        KeyNavigation.left: channelGrid;
        KeyNavigation.right: channelGrid;

        Behavior on x { NumberAnimation { easing.type: Easing.InOutQuad; duration: 1000 }}
        Behavior on y { NumberAnimation { easing.type: Easing.InOutQuad; duration: 1000 }}
        Behavior on width { NumberAnimation { easing.type: Easing.InOutQuad; duration: 1000 }}
        Behavior on height { NumberAnimation { easing.type: Easing.InOutQuad; duration: 1000 }}

        onChannelChanged:
        {
            for (var x = 0; x < playerSources.tivoChannelList.count; x++)
            {
                if (playerSources.tivoChannelList.get(x).ChanNo === channel)
                {
                    programStatus.text = playerSources.tivoChannelList.get(x).ChanNo + " - " + playerSources.tivoChannelList.get(x).Name;
                    return;
                }
            }
        }
    }

    Rectangle
    {
        x: videoPlayer.x
        y: videoPlayer.y + videoPlayer.height
        height: yscale(5)
        width: videoPlayer.width
        color: "green"
        visible: videoPlayer.focus
    }

    PopupMenu
    {
        id: categoryMenu

        title: "Category"
        message: "Only show channels in the selected category"
        width: xscale(500); height: yscale(600)

        restoreSelected: true;

        onItemSelected:
        {
            channelGrid.focus = true;
            footer.greenText = "Show (" + itemText +")";
            feedSource.category = itemData;
            var filter =  feedSource.category + "," + feedSource.definition + "," + feedSource.sort;
            feedSource.switchToTivoTV(filter, channelGrid.currentIndex);
        }

        onCancelled:
        {
            channelGrid.focus = true;
        }

        Component.onCompleted:
        {
            addMenuItem("", "All Categories", "");
            for (var x = 0; x < playerSources.tivoChannelList.categoryList.count; x++)
                addMenuItem("", playerSources.tivoChannelList.categoryList.get(x).item, playerSources.tivoChannelList.categoryList.get(x).item);
        }
    }

    PopupMenu
    {
        id: definitionMenu

        title: "Definition"
        message: "Only show channels with the selected definition"
        width: xscale(500); height: yscale(600)

        restoreSelected: true;

        onItemSelected:
        {
            channelGrid.focus = true;
            footer.yellowText = "Definition (" + itemText +")";
            feedSource.definition = itemData;
        }
        onCancelled:
        {
            channelGrid.focus = true;
        }

        Component.onCompleted:
        {
            addMenuItem("", "All", "");
            for (var x = 0; x < playerSources.tivoChannelList.definitionList.count; x++)
                addMenuItem("", playerSources.tivoChannelList.definitionList.get(x).item, playerSources.tivoChannelList.definitionList.get(x).item);
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
            //programStatus.text = "N/A";
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

            title.text = currentItem.ChanNo + " - " +  currentItem.Name;

            // icon
//            channelIcon.source = currentItem.Icon ? settings.masterBackend + "Guide/GetChannelIcon?ChanId=" + currentItem.ChanId : mythUtils.findThemeFile("images/grid_noimage.png");

            getSDSchedule(currentItem.SDId);

//            if (videoPlayer.visible)
//            {
//                previewTimer.start();
//            }

            noMatches.visible = false;
        }
    }

    function getSDSchedule(stationId)
    {
        if (stationId === "")
        {
            _nowScheduleJson = undefined;
            _nextScheduleJson = undefined;
            updateNowNext(undefined);
            return;
        }

        var stations = [stationId];

        var now = new Date();
        var today = new Date(); // + (now.getTimezoneOffset() * 60 * 1000));
        var yesterday = Util.addDays(today, -1);
        var tomorrow = Util.addDays(today, 1);

        var dates = [Qt.formatDateTime(yesterday, "yyyy-MM-dd"), Qt.formatDateTime(today, "yyyy-MM-dd"), Qt.formatDateTime(tomorrow, "yyyy-MM-dd")];
        sdAPI.getSchedule(stations, dates, findNowNext);
    }

    function findNowNext(json)
    {
        var found = false;

        for (var day = 0; day < json.length; day++)
        {
            // check this data is for the selected channel
            if (channelGrid.model.get(channelGrid.currentIndex).SDId !== json[day].stationID)
                return;

            // check we have some programs
            if (json[day].code && json[0].code !== 0)
            {

                log.error(Verbose.GENERAL,"TivoTVChannelViewer: findNowNext - No programs found for: " + json[0].message);
                continue;
            }

            // find the programID for the now and next programs
            var now = new Date();
            //var now2 = new Date(Date.now() + (now.getTimezoneOffset() * 60 * 1000));

            for (var x = 0; x < json[day].programs.length; x++)
            {
                var program = json[day].programs[x];
                var dtStartTime = new Date(program.airDateTime);
                var dtEndTime = Util.addSeconds(dtStartTime, program.duration);  //new Date(dtStartTime + (program.duration * 60 * 1000));

                if (now >= dtStartTime && now < dtEndTime)
                {
                    var nowProgID = program.programID;
                    root._nowScheduleJson = program;

                    var nextProgram;
                    var nextProgID;

                    if (json[day].programs.length <= x + 1)
                    {
                        nextProgram = json[day + 1].programs[0];
                        root._nextScheduleJson = nextProgram;
                        nextProgID = nextProgram.programID;
                    }
                    else
                    {
                        nextProgram = json[day].programs[x + 1];
                        root._nextScheduleJson = nextProgram;
                        nextProgID = nextProgram.programID;
                    }

                    sdAPI.getPrograms([nowProgID, nextProgID], updateNowNext);
                    found =  true;
                    break;
                }
            }

            if (found)
                break;
        }
    }

    function updateNowNext(json)
    {
        if (json === undefined || _nowScheduleJson === undefined || _nextScheduleJson === undefined)
        {
            programTitle.info = "No guide data available for this channel"
            programDesc.text = "N/A"
            //programStatus.text = "N/A";
            programCategory.text = "Unknown"
            programEpisode.text = "";
            programFirstAired.text = ""
            programLength.text = ""
            programNext.info = ""

            timeIndictor.position = 0;
            timeIndictor.length = 100;
            return;
        }

        // update the timeIndictor
        var dtStart =  new Date(_nowScheduleJson.airDateTime);
        var dtEnd = Util.addSeconds(dtStart, _nowScheduleJson.duration); //new Date(dtStart + (_nowScheduleJson.duration * 60 * 1000));
        var dtNow = new Date();
        var position = dtNow - dtStart;
        var length = dtEnd - dtStart;

        timeIndictor.position = position;
        timeIndictor.length = length;

        var startDate = new Date(dtStart);
        var endDate = new Date(dtEnd);

        var title = ""
        if (json[0].titles[0].title120)
            title = json[0].titles[0].title120;

        var subtitle = "";
        if (json[0].episodeTitle150)
            subtitle = json[0].episodeTitle150;

        var description = ""
        if (json[0].descriptions && json[0].descriptions.description1000[0])
            description = json[0].descriptions.description1000[0].description
        else if (json[0].descriptions && json[0].descriptions.description100[0])
            description = json[0].descriptions.description100[0].description

        programTitle.info = title + " (" + startDate.toLocaleTimeString(Qt.locale(), "hh:mm") + " - " + endDate.toLocaleTimeString(Qt.locale(), "hh:mm") + ")";

        programLength.text = _nowScheduleJson.duration / 60 + " mins";

        if (subtitle)
            programDesc.text = "\"" + subtitle + "\"  " + description;
        else
            programDesc.text = description;

        // we can't get the recording status from the TIVO?
        //programStatus.text = "";
//      var state = guideModel.get(0).RecordingStatus;
//      if (state === "Unknown")
//          programStatus.text = "Not Recording";
//      else
//          programStatus.text = guideModel.get(0).RecordingStatus

        if (json[0].genres)
        {
            var categories = "";

            for (var x = 0; x < json[0].genres.length; x++)
            {
                if (categories.length)
                    categories += ", " + json[0].genres[x];
                else
                    categories = json[0].genres[x];
            }

            programCategory.text = categories;
        }
        else
            programCategory.text = "";

        if (json[0].metadata && json[0].metadata[0].Gracenote)
        {
            var season = json[0].metadata[0].Gracenote.season;
            var episode = json[0].metadata[0].Gracenote.episode ? json[0].metadata[0].Gracenote.episode : 0;
            var total = json[0].metadata[0].Gracenote.totalEpisodes ? json[0].metadata[0].Gracenote.totalEpisodes : 0;;
            var res = "";

            if (season > 0)
                res = "Season: " + season + " ";
            if (episode > 0)
            {
                res += " Episode: " + episode;

                if (total > 0)
                    res += "/" + total;
            }

            programEpisode.text = res;
        }
        else
            programEpisode.text = "";

        if (json[0].originalAirDate)
            programFirstAired.text = "First Aired: " +  json[0].originalAirDate;  //Qt.formatDateTime(guideModel.get(0).AirDate, "dd/MM/yyyy");
        else
            programFirstAired.text = ""

        // update next program
        dtStart = new Date(_nextScheduleJson.airDateTime);
        dtEnd = Util.addSeconds(dtStart, _nextScheduleJson.duration);// new Date(dtStart + (_nextScheduleJson.duration * 60 * 1000));

        if (json.length === 2)
            programNext.info = json[1].titles[0].title120 + " (" + dtStart.toLocaleTimeString(Qt.locale(), "hh:mm") + " - " + dtEnd.toLocaleTimeString(Qt.locale(), "hh:mm") + ")";
        else
        {
            // on rare occasions like on BBC3/BBC4 the same program can be repeated again
            programNext.info = json[0].titles[0].title120 + " (" + dtStart.toLocaleTimeString(Qt.locale(), "hh:mm") + " - " + dtEnd.toLocaleTimeString(Qt.locale(), "hh:mm") + ")";
        }
    }

    function updateTimeIndicator()
    {
        if (_nowScheduleJson === undefined || _nextScheduleJson === undefined)
            return;

        var dtStart =  new Date(_nowScheduleJson.airDateTime);
        var dtEnd = Util.addSeconds(dtStart, _nowScheduleJson.duration);
        var dtNow = new Date();

        var position = dtNow - dtStart;
        var length = dtEnd - dtStart;

        timeIndictor.position = position;
        timeIndictor.length = length;
    }

    function toggleFullscreenPlayer()
    {
        videoPlayerFullscreen = !videoPlayerFullscreen;

//        panel1.visible = !videoPlayerFullscreen;
//        panel2.visible = !videoPlayerFullscreen;
//        panel3.visible = !videoPlayerFullscreen;
//        detailsPanel.visible = !videoPlayerFullscreen;

        if (videoPlayerFullscreen)
        {
            videoPlayer.x = 0;
            videoPlayer.y = 0;
            videoPlayer.width = window.width;
            videoPlayer.height = window.height;
            videoPlayer.mediaPlayer1.focus = true;
        }
        else
        {
            videoPlayer.x = _xscale(970);
            videoPlayer.y = _yscale(480);
            videoPlayer.width = _xscale(266);
            videoPlayer.height = _yscale(150);

//            if (internalPlayer.previousFocusItem)
//            {
//                panelStack.focus = true;
//                internalPlayer.previousFocusItem.focus = true;
//            }
        }
    }

    function updatePlayer()
    {
        //TODO check encoder availability
        var encoderNum = 1
        var ip = settings.masterIP
        var chanNum = channelGrid.model.get(channelGrid.currentIndex).ChanNum;
        var pin = settings.securityPin;
//        videoPlayer.visible = true;
//        videoPlayer.source = "myth://type=livetv:server=" + ip + ":pin=" + pin + ":encoder=" + encoderNum + ":channum=" + chanNum
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
        if (feedSource !== "Tivo TV")
            return;

        var list = filter.split(",");
        var category = "";
        var definition = "";
        var sort = ""
        var i;
        if (list.length === 3)
        {
            category = list[0];
            definition = list[1];
            sort = list[2];
        }

        if (category !== root.category ||  definition !== root.definition || sort !== root.sort)
        {
            root.category = category;
            root.definition = definition;
            root.sort = sort;

            footer.redText = "Sort (" + sort + ")";
            footer.greenText = "Show (" + category + ")";
            footer.yellowText = "Show (" + definition + ")";
        }
        channelGrid.currentIndex = index;
    }
}
