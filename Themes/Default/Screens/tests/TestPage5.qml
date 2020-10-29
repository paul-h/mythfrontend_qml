import QtQuick 2.7
import Base 1.0
import Dialogs 1.0
import Models 1.0

BaseScreen
{
    defaultFocusItem: buttonLists

    Component.onCompleted:
    {
        showTitle(true, "Nested List Test");
        showTime(true);
        showTicker(false);
        muteAudio(true);
    }

    ChannelsModel
    {
        id: channelsModel
        groupByCallsign: false
    }

    VideosModel
    {
        id: videosModel
    }

    WebCamModel
    {
        id: webcamsModel
    }

    ListModel
    {
        id: model1

        ListElement
        {
            title: "TV Channels"
            feedSource: "Live TV"
            feedFilter: "-1"
        }
        ListElement
        {
            title: "Videos"
            feedSource: "Videos"
            feedFilter: ""
        }
        ListElement
        {
            title: "Webcams"
            feedSource: "Webcams"
            feedFilter: ""
        }

        ListElement
        {
            title: "title 4"
            feedSource: ""
            feedFilter: ""
        }
        ListElement
        {
            title: "title 5"
            feedSource: ""
            feedFilter: ""
        }
        ListElement
        {
            title: "title 6"
            feedSource: ""
            feedFilter: ""
        }
        ListElement
        {
            title: "title 7"
            feedSource: ""
            feedFilter: ""
        }
        ListElement
        {
            title: "title 8"
            feedSource: ""
            feedFilter: ""
        }
        ListElement
        {
            title: "title 9"
            feedSource: ""
            feedFilter: ""
        }
    }
    ListModel
    {
        id: model2
        ListElement
        {
            title: "A - inside 1"
            icon: "images/rss.png"
        }
        ListElement
        {
            title: "A - inside 2"
            icon: ""
        }
        ListElement
        {
            title: "A - inside 3"
            icon: "images/rss.png"

        }
        ListElement
        {
            title: "A - inside 4"
            icon: "images/grid_noimage.png"
        }
        ListElement
        {
            title: "A - inside 5"
            icon: ""
        }
        ListElement
        {
            title: "A - inside 6"
            icon: ""
        }
        ListElement
        {
            title: "A - inside 7"
            icon: ""
        }
        ListElement
        {
            title: "A - inside 8"
            icon: ""
        }
        ListElement
        {
            title: "A - inside 9"
            icon: ""
        }
    }

    ListModel
    {
        id: model3
        ListElement
        {
            title: "B - inside 1"
            icon: ""
        }
        ListElement
        {
            title: "B - inside 2"
            icon: ""
        }
        ListElement
        {
            title: "B - inside 3"
            icon: ""

        }
        ListElement
        {
            title: "B - inside 4"
            icon: ""
        }
        ListElement
        {
            title: "B - inside 5"
            icon: ""
        }
        ListElement
        {
            title: "B - nside 6"
            icon: ""
        }
        ListElement
        {
            title: "B - inside 7"
            icon: ""
        }
        ListElement
        {
            title: "B - inside 8"
            icon: ""
        }
        ListElement
        {
            title: "B - inside 9"
            icon: ""
        }
    }

    MultiHorizButtonList
    {
        id: buttonLists
        x: 20
        y: 60
        width: parent.width - xscale(40)
        height: parent.height - yscale(80)
        rows: 2
        columns: 4

        model: model1
        rowModels: [channelsModel, videosModel, webcamsModel.model, model3, model3, model2, model2, model2, model2]

        onItemClicked:
        {
            console.log("SIGNAL item clicked: " + rowModels[row].get(col).title);

            if (!root.isPanel)
            {
                var feedSource = model1.get(row).feedSource;
                var feedFilter = model1.get(row).feedFilter;
                var feedIndex = col;
                console.log("feedSource: " + feedSource + ", feedFilter" + feedFilter, ", feedIndex: " + feedIndex);
                var item = stack.push({item: mythUtils.findThemeFile("Screens/InternalPlayer.qml"), properties:{defaultFeedSource:  feedSource, defaultFilter:  feedFilter, defaultCurrentFeed: feedIndex}});
                //item.feedChanged.connect(feedChanged);

            }
            else
            {
                feedSelected(feedSource, feedFilter, feedIndex);
            }
        }

        onItemSelected: console.log("SIGNAL item selected: " + rowModels[row].get(col).title);
    }
}
