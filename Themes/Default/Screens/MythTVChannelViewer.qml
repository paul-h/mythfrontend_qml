import QtQuick 2.0
import QtQml 2.2
import QtQuick.XmlListModel 2.0
import Base 1.0
import Dialogs 1.0
import Models 1.0
import SortFilterProxyModel 0.2
import "../../../Util.js" as Util
import mythqml.net 1.0

BaseScreen
{
    defaultFocusItem: channelGrid

    property int filterSourceID: 6
    property bool chanNameSorterActive: true

    Component.onCompleted:
    {
        showTitle(true, "LiveTV Channel Viewer");
        showTime(true);
        showTicker(false);

        while (stack.busy) {};

        filterSourceID = dbUtils.getSetting("Qml_lastChannelSourceID", settings.hostName)

        if (filterSourceID == "<All Channels>" || filterSourceID == "")
            footer.greenText = "Show (All Channels)"
        else
        {
            var index = playerSources.videoSourceList.findById(filterSourceID);
            if (index !== -1)
                footer.greenText = "Show (" + playerSources.videoSourceList.get(index).SourceName + ")"
            else
                footer.greenText = "Show (UNKNOWN SOURCE)";
        }

        updateChannelDetails();

    }

    Component.onDestruction:
    {
        dbUtils.setSetting("Qml_lastChannelSourceID", settings.hostName, filterSourceID)
    }

    property list<QtObject> chanNameSorter:
    [
        RoleSorter { roleName: "ChanName"; ascendingOrder: true}
    ]

    property list<QtObject> chanNumSorter:
    [
        RoleSorter { roleName: "ChanNo" }
    ]

    SortFilterProxyModel
    {
        id: channelProxyModel
        sourceModel: playerSources.channelList
        filters:
        [
            AllOf
            {
                ValueFilter
                {
                    roleName: "SourceId"
                    value: filterSourceID
                }
            }
        ]
        sorters: chanNameSorter
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

    Keys.onPressed:
    {
        if (event.key === Qt.Key_M)
        {
        }
        else if (event.key === Qt.Key_F1)
        {
            // RED
            if (chanNameSorterActive)
            {
                channelProxyModel.sorters = chanNumSorter;
                footer.redText = "Sort (Channel No.)";
            }
            else
            {
                channelProxyModel.sorters = chanNameSorter;
                footer.redText = "Sort (Channel Name)";
            }

            chanNameSorterActive = !chanNameSorterActive;
        }
        else if (event.key === Qt.Key_F2)
        {
            // GREEN
            searchDialog.model = playerSources.videoSourceList
            searchDialog.show();
        }
        else if (event.key === Qt.Key_F3)
        {
            // YELLOW

        }
        else if (event.key === Qt.Key_F4)
        {
            //BLUE

        }
    }

    BaseBackground
    {
        id: listBackground
        x: xscale(10); y: yscale(45); width: parent.width - x - xscale(10); height: yscale(410)
    }

    BaseBackground { x: xscale(10); y: yscale(465); width: parent.width - xscale(20); height: yscale(210) }

    InfoText
    {
        x: xscale(900); y: yscale(0); width: xscale(120);
        text: (channelGrid.currentIndex + 1) + " of " + channelGrid.model.count;
    }

    ButtonGrid
    {
        id: channelGrid
        x: xscale(22)
        y: yscale(55)
        width: xscale(1280) - xscale(44)
        height: yscale(390)
        cellWidth: xscale(206)
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

        model: channelProxyModel
        delegate: channelDelegate
        focus: true

        Keys.onReturnPressed:
        {
            returnSound.play();
            var item = stack.push({item: Qt.resolvedUrl("InternalPlayer.qml"), properties:{defaultFeedSource:  "Live TV", defaultFilter:  filterSourceID, defaultCurrentFeed: channelGrid.currentIndex}});
            item.feedChanged.connect(feedChanged);
            event.accepted = true;
        }

        Keys.onPressed:
        {
            if (event.key === Qt.Key_M)
            {
                searchDialog.model = playerSources.videoSourceList
                searchDialog.show();
            }
            else
            {
                event.accepted = false;
            }
        }

        onCurrentIndexChanged: updateChannelDetails();
    }

    TitleText
    {
        id: title
        x: xscale(30); y: yscale(470)
        width: xscale(900); height: yscale(35)
        verticalAlignment: Text.AlignTop
        multiline: true
    }

    Image
    {
        id: channelIcon
        x: xscale(970); y: yscale(480); width: xscale(266); height: yscale(150)
        asynchronous: true
        onStatusChanged: if (status == Image.Error) source = mythUtils.findThemeFile("images/grid_noimage.png")
    }

    RichText
    {
        id: programTitle
        x: xscale(30)
        y: yscale(500)
        width: xscale(700)
        label: "Now: "
    }

    InfoText
    {
        id: programDesc
        x: xscale(30); y: yscale(545)
        width: xscale(910); height: yscale(75)
        verticalAlignment: Text.AlignTop
        multiline: true
    }

    InfoText
    {
        id: programStatus
        x: xscale(970); y: yscale(630); width: xscale(266)
        horizontalAlignment: Text.AlignHCenter
        fontColor: if (text === "Recording") "red"; else theme.infoFontColor;
    }

    InfoText
    {
        id: programCategory
        x: xscale(20); y: yscale(630); width: xscale(220)
        fontColor: "grey"
    }

    InfoText
    {
        id: programEpisode
        x: xscale(315); y: yscale(630); width: xscale(320)
        horizontalAlignment: Text.AlignHCenter
        fontColor: "grey"
    }

    InfoText
    {
        id: programFirstAired
        x: xscale(720); y: yscale(630); width: xscale(220)
        fontColor: "grey"
        horizontalAlignment: Text.AlignRight
    }

    InfoText
    {
        id: programLength
        x: xscale(850); y: yscale(500); width: xscale(90)
        fontColor: "grey"
        horizontalAlignment: Text.AlignRight
    }

    RichText
    {
        id: programNext
        x: xscale(30)
        y: yscale(606)
        width: xscale(910)
        label: "Next: "
    }

    Item
    {
        id: timeIndictor

        property int position: 0
        property int length: 100

        x: xscale(740)
        y: yscale(522)
        width: xscale(100)
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
        x: xscale(900); y: yscale(630); width: xscale(32); height: yscale(32)
        source: mythUtils.findThemeFile("images/recording.png")
        visible: guideModel.get(0).RecordingStatus === "Recording"
    }

    Footer
    {
        id: footer
        redText: "Sort (Channel Name)"
        greenText: "Show (All Channels)"
        yellowText: ""
        blueText: ""
    }

    SearchListDialog
    {
        id: searchDialog

        title: "Choose a source"
        message: ""
        displayField: "SourceName"
        dataField: "Id"

        onAccepted:
        {
            channelGrid.focus = true;

        }
        onCancelled:
        {
            channelGrid.focus = true;
        }

        onItemSelected:
        {
            if (itemText != "<All Channels>")
            {
                filterSourceID = parseInt(itemText);
                var index = playerSources.videoSourceList.findById(filterSourceID);
                if (index !== -1)
                    footer.greenText = "Show (" + playerSources.videoSourceList.get(index).SourceName + ")"
                else
                    footer.greenText = "Show (UNKNOWN SOURCE)";
            }
            else
            {
                filterSourceID = "";
                footer.greenText = "Show (All Channels)"
            }

            channelGrid.focus = true;

            updateChannelDetails()
        }
    }

    function feedChanged(filter, index)
    {
        if (filter !== filterSourceID)
        {
            if (filter === "")
            {
                filterSourceID = filter;
                footer.greenText = "Show (All Channels)"
            }
            else
            {
                filterSourceID = filter;
                footer.greenText = "Show (" + filter + ")"
            }
        }

        channelGrid.currentIndex = index;
    }

   function updateChannelDetails()
    {
       var currentItem = channelGrid.model.get(channelGrid.currentIndex);

       if (!currentItem)
           return;

        title.text = currentItem.title;

        // icon
        channelIcon.source = currentItem.IconURL ? settings.masterBackend + "Guide/GetChannelIcon?ChanId=" + currentItem.ChanId : mythUtils.findThemeFile("images/grid_noimage.png");

        getNowNext();
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
}
