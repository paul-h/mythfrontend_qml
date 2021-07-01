import QtQuick 2.0
import QtQuick.XmlListModel 2.0
import Base 1.0
import Models 1.0
import SortFilterProxyModel 0.2

BaseScreen
{
    defaultFocusItem: channelList

    property string sortField: "ChanNum"
    property int filterSourceIndex: -1

    Component.onCompleted:
    {
        showTitle(true, "MythTV Channel Editor");
        setHelp("https://mythqml.net/help/settings_mythtv_channeleditor.php");
        showTime(false);
        showTicker(false);
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

        onStatusChanged: if (status == XmlListModel.Ready)  updateNowNext()
    }

    property list<QtObject> sourceIDFilter:
    [
        AllOf
        {
            ValueFilter
            {
                id: sourceValue
                roleName: "SourceId"
            }
        }
    ]

    property list<QtObject> chanNumSorter:
    [
        RoleSorter { roleName: "ChanNum" },
        RoleSorter { roleName: "ChannelName" }
    ]

    property list<QtObject> chanNameSorter:
    [
        RoleSorter { roleName: "ChannelName" }
    ]

    property list<QtObject> videoSourceSorter:
    [
        RoleSorter { roleName: "SourceId" },
        RoleSorter { roleName: "ChannelName" }
    ]

    property list<QtObject> callSignSorter:
    [
        RoleSorter { roleName: "CallSign" }
    ]

    property list<QtObject> mplexIdSorter:
    [
        RoleSorter { roleName: "MplexId" },
        RoleSorter { roleName: "ChannelName" }
    ]

    SortFilterProxyModel
    {
        id: channelsProxyModel
        sourceModel: channelsModel
        filters: sourceIDFilter
        sorters: chanNumSorter
    }

    ChannelsModel
    {
        id: channelsModel
        sourceId: -1
        groupByCallsign: false;
        onlyVisible: true;
    }

    VideoSourceModel
    {
        id: videoSourceModel
    }

    VideoMultiplexModel
    {
        id: videoMultiplexModel

        onLoaded: updateMultiplexDetails()
    }

    ListModel
    {
        id: detailsModel

        ListElement { label: "ChanId:"; info: "" }
        ListElement { label: "ChanNum:"; info: "" }
        ListElement { label: "Channel Name:"; info: "" }
        ListElement { label: "CallSign:"; info: "" }
        ListElement { label: "IconURL:"; info: "" }
        ListElement { label: "SourceId:"; info: "" }
        ListElement { label: "MplexId:"; info: "" }
        ListElement { label: "TransportId:"; info: "" }
        ListElement { label: "NetworkId:"; info: "" }
        ListElement { label: "Frequency:"; info: "" }
        ListElement { label: "Inversion:"; info: "" }
        ListElement { label: "SymbolRate:"; info: "" }
        ListElement { label: "FEC:"; info: "" }
        ListElement { label: "Polarity:"; info: "" }
        ListElement { label: "Modulation:"; info: "" }
        ListElement { label: "Bandwidth:"; info: "" }
        ListElement { label: "LPCodeRate:"; info: "" }
        ListElement { label: "HPCodeRate:"; info: "" }
        ListElement { label: "TransmissionMode:"; info: "" }
        ListElement { label: "GuardInterval:"; info: "" }
        ListElement { label: "Visible:"; info: "" }
        ListElement { label: "Constellation:"; info: "" }
        ListElement { label: "Hierarchy:"; info: "" }
        ListElement { label: "ModulationSystem:"; info: "" }
        ListElement { label: "RollOff:"; info: "" }
        ListElement { label: "SIStandard:"; info: "" }
        ListElement { label: "ServiceVersion:"; info: "" }
        ListElement { label: "UpdateTimeStamp:"; info: "" }
        ListElement { label: "DefaultAuthority:"; info: "" }
    }

    ListModel
    {
        id: mediaModel
        ListElement
        {
            no: "1"
            title: ""
            icon: ""
            url: ""
            player: "Internal"
            duration: ""
        }
    }

    Keys.onPressed:
    {
        if (event.key === Qt.Key_F1)
        {
            // RED - sort (ChanNum, ChannelName, CallSign, VideoSource, MplexId)
            if (sortField === "ChanNum")
            {
                channelsProxyModel.sorters = chanNameSorter;
                footer.redText = "Sort (Channel Name)";
                sortField = "ChannelName";
            }
            else if (sortField === "ChannelName")
            {
                channelsProxyModel.sorters = callSignSorter;
                footer.redText = "Sort (Callsign)";
                sortField = "CallSign";
            }
            else if (sortField === "CallSign")
            {
                channelsProxyModel.sorters = videoSourceSorter;
                footer.redText = "Sort (VideoSource)";
                sortField = "VideoSource";
            }
            else if (sortField === "VideoSource")
            {
                channelsProxyModel.sorters = mplexIdSorter;
                footer.redText = "Sort (MplexId)";
                sortField = "MplexId";
            }
            else if (sortField === "MplexId")
            {
                channelsProxyModel.sorters = chanNumSorter;
                footer.redText = "Sort (Channel Number)";
                sortField = "ChanNum";
            }
        }
        else if (event.key === Qt.Key_F2)
        {
            // GREEN - filter
            var oldCurentIndex = channelList.currentIndex;

            filterSourceIndex++;

            if (filterSourceIndex >= videoSourceModel.count)
            {
                filterSourceIndex = 0;
                sourceValue.value = -1;
                channelsProxyModel.filters = [];
                footer.greenText = "Show (All Video Sources)"
            }
            else
            {
                sourceValue.value = videoSourceModel.get(filterSourceIndex).Id;
                channelsProxyModel.filters = sourceIDFilter;
                footer.greenText = "Show (" + videoSourceModel.get(filterSourceIndex).SourceName + ")"
            }

            if (oldCurentIndex === channelList.currentIndex)
            {
                // force an update just incase
                updateChannelDetails();
            }
        }
        else if (event.key === Qt.Key_F3)
        {
            // YELLOW - Test Channel
            mediaModel.get(0).title = channelList.model.get(channelList.currentIndex, "title");
            mediaModel.get(0).url = channelList.model.get(channelList.currentIndex, "url") + ":chanid=" + channelList.model.get(channelList.currentIndex, "ChanId");
            playerSources.adhocList = mediaModel;
            mediaPlayer.feed.switchToAdhoc("", 0);
            mediaPlayer.startPlayback();

        }
        else if (event.key === Qt.Key_F4)
        {
            // BLUE - Edit Channel
            // TODO
        }
    }

    BaseBackground { x: xscale(15); y: yscale(50); width: parent.width - yscale(30); height: yscale(220) }

    BaseBackground { x: xscale(15); y: yscale(285); width: parent.width - xscale(30); height: yscale(385) }

    InfoText
    {
        x: parent.width - xscale(215); y: yscale(5); width: xscale(200);
        text: (channelList.currentIndex + 1) + " of " + channelList.model.count;
        horizontalAlignment: Text.AlignRight
    }

    Component
    {
        id: listRow

        ListItem
        {
            width: channelList.width

            Image
            {
                id: channelImage
                x: xscale(3); y: yscale(3); height: parent.height - yscale(6); width: height
                source:
                {
                    if (IconURL)
                        settings.masterBackend + "Guide/GetChannelIcon?ChanId=" + ChanId
                    else
                        mythUtils.findThemeFile("images/grid_noimage.png")
                }
            }
            ListText
            {
                x: channelImage.width + xscale(10)
                width: xscale(75)
                height: yscale(50)
                text: ChanNum
            }
            ListText
            {
                x: xscale(130)
                width: xscale(300)
                height: yscale(50)
                text: ChannelName
            }
            ListText
            {
                x: xscale(435)
                width: xscale(150)
                height: yscale(50)
                text: CallSign
            }
            ListText
            {
                x: xscale(590)
                width: xscale(640)
                height: yscale(50)
                text: XMLTVID
            }
        }
    }

    ButtonList
    {
        id: channelList
        x: xscale(20); y: yscale(60); width: parent.width - xscale(40); height: yscale(200)

        model: channelsProxyModel
        delegate: listRow

        Keys.onReturnPressed:
        {
            mediaModel.get(0).title = model.get(currentIndex, "title");
            mediaModel.get(0).url = model.get(currentIndex, "url") + ":chanid=" + model.get(currentIndex, "ChanId");
            playerSources.adhocList = mediaModel;
            mediaPlayer.feed.switchToAdhoc("", 0);
            mediaPlayer.startPlayback();
        }

        onCurrentIndexChanged:
        {
           updateChannelDetails();
        }

        KeyNavigation.left: detailsList;
        KeyNavigation.right: detailsList;
    }

    Component
    {
        id: detailsRow

        ListItem
        {
            width: detailsList.width
            height: yscale(40)

            LabelText
            {
                x: 5
                width: xscale(250)
                height: yscale(40)
                horizontalAlignment: Text.AlignRight
                text: label
            }
            ListText
            {
                x: xscale(260)
                width: xscale(520)
                height: yscale(40)
                text: info
            }
        }
    }

    ButtonList
    {
        id: detailsList
        x: xscale(470); y: yscale(295); width: xscale(785); height: yscale(365)

        model: detailsModel
        delegate: detailsRow

        KeyNavigation.left: channelList;
        KeyNavigation.right: channelList;
    }

    MediaPlayer
    {
        id: mediaPlayer

        x: xscale(30); y: yscale(340); width: xscale(400); height: yscale(225)
    }

    TitleText
    {
        id: title
        x: xscale(30)
        y: yscale(290)
        width: xscale(600)
    }

    RichText
    {
        id: progNow
        x: xscale(30)
        y: yscale(565)
        width: xscale(400)
        label: "Now: "
    }

    RichText
    {
        id: progNext
        x: xscale(30)
        y: yscale(595)
        width: xscale(400)
        label: "Next: "
    }

    Footer
    {
        id: footer
        redText: "Sort (Channel Number)"
        greenText: "Show (All Sources)"
        yellowText: "Test Channel"
        blueText: ""; //"Edit"
    }

    function updateChannelDetails()
    {
        title.text = channelList.model.get(channelList.currentIndex).title

        var index = videoSourceModel.findById(channelList.model.get(channelList.currentIndex).SourceId);
        var sourceName;

        if (index >= 0 && index < videoSourceModel.count)
            sourceName = channelList.model.get(channelList.currentIndex).SourceId + " - " + videoSourceModel.get(index).SourceName;
        else
            sourceName = channelList.model.get(channelList.currentIndex).SourceId + " - UNKNOW VIDEO SOURCE!";

        // get now/next program
        guideModel.chanId = channelList.model.get(channelList.currentIndex).ChanId;
        guideModel.load();

        // get multiplex details
        videoMultiplexModel.sourceId =  channelList.model.get(channelList.currentIndex).SourceId

        // update the details model
        detailsModel.setProperty(0, "info", channelList.model.get(channelList.currentIndex).ChanId.toString());
        detailsModel.setProperty(1, "info", channelList.model.get(channelList.currentIndex).ChanNum.toString());
        detailsModel.setProperty(2, "info", channelList.model.get(channelList.currentIndex).ChannelName);
        detailsModel.setProperty(3, "info", channelList.model.get(channelList.currentIndex).CallSign);
        detailsModel.setProperty(4, "info", channelList.model.get(channelList.currentIndex).IconURL);
        detailsModel.setProperty(5, "info", sourceName);

        // add mplex details
        detailsModel.setProperty(6, "info", channelList.model.get(channelList.currentIndex).MplexId.toString());
    }

    function updateMultiplexDetails()
    {
        var index = videoMultiplexModel.findById(channelList.model.get(channelList.currentIndex).MplexId);

        if (index >= 0 && index < videoMultiplexModel.count)
        {
            detailsModel.setProperty(7, "info", videoMultiplexModel.get(index).TransportId.toString());
            detailsModel.setProperty(8, "info", videoMultiplexModel.get(index).NetworkId.toString());
            detailsModel.setProperty(9, "info", videoMultiplexModel.get(index).Frequency.toString());
            detailsModel.setProperty(10, "info", videoMultiplexModel.get(index).Inversion);
            detailsModel.setProperty(11, "info", videoMultiplexModel.get(index).SymbolRate.toString());
            detailsModel.setProperty(12, "info", videoMultiplexModel.get(index).FEC);
            detailsModel.setProperty(13, "info", videoMultiplexModel.get(index).Polarity);
            detailsModel.setProperty(14, "info", videoMultiplexModel.get(index).Modulation);
            detailsModel.setProperty(15, "info", videoMultiplexModel.get(index).Bandwidth);
            detailsModel.setProperty(16, "info", videoMultiplexModel.get(index).LPCodeRate);
            detailsModel.setProperty(17, "info", videoMultiplexModel.get(index).HPCodeRate);
            detailsModel.setProperty(18, "info", videoMultiplexModel.get(index).TransmissionMode);
            detailsModel.setProperty(19, "info", videoMultiplexModel.get(index).GuardInterval);
            detailsModel.setProperty(20, "info", videoMultiplexModel.get(index).Visible);
            detailsModel.setProperty(21, "info", videoMultiplexModel.get(index).Constellation);
            detailsModel.setProperty(22, "info", videoMultiplexModel.get(index).Hierarchy);
            detailsModel.setProperty(23, "info", videoMultiplexModel.get(index).ModulationSystem);
            detailsModel.setProperty(24, "info", videoMultiplexModel.get(index).RollOff);
            detailsModel.setProperty(25, "info", videoMultiplexModel.get(index).SIStandard);
            detailsModel.setProperty(26, "info", videoMultiplexModel.get(index).ServiceVersion);
            detailsModel.setProperty(27, "info", videoMultiplexModel.get(index).UpdateTimeStamp);
            detailsModel.setProperty(28, "info", videoMultiplexModel.get(index).DefaultAuthority);
        }
        else
        {
            detailsModel.setProperty(7, "info", "");
            detailsModel.setProperty(8, "info", "");
            detailsModel.setProperty(9, "info", "");
            detailsModel.setProperty(10, "info", "");
            detailsModel.setProperty(11, "info", "");
            detailsModel.setProperty(12, "info", "");
            detailsModel.setProperty(13, "info", "");
            detailsModel.setProperty(14, "info", "");
            detailsModel.setProperty(15, "info", "");
            detailsModel.setProperty(16, "info", "");
            detailsModel.setProperty(17, "info", "");
            detailsModel.setProperty(18, "info", "");
            detailsModel.setProperty(19, "info", "");
            detailsModel.setProperty(20, "info", "");
            detailsModel.setProperty(21, "info", "");
            detailsModel.setProperty(22, "info", "");
            detailsModel.setProperty(23, "info", "");
            detailsModel.setProperty(24, "info", "");
            detailsModel.setProperty(25, "info", "");
            detailsModel.setProperty(26, "info", "");
            detailsModel.setProperty(27, "info", "");
            detailsModel.setProperty(28, "info", "");
        }
    }

    function updateNowNext()
    {
        if (guideModel.count > 0)
        {
            progNow.info = guideModel.get(0).Title
            progNext.info = guideModel.get(1).Title
        }
        else
        {
            progNow.info = "NO GUIDE DATA FOR THIS CHANNEL!"
            progNext.info = ""
        }
    }
}
