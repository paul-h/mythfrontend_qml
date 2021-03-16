import QtQuick 2.0
import QtQuick.XmlListModel 2.0
import QtQuick.Controls 1.4
import Base 1.0
import Dialogs 1.0
import Models 1.0
import mythqml.net 1.0
import "../../../Util.js" as Util

BaseScreen
{
    id: root

    defaultFocusItem: feedList
    property string currentFeed: ""
    property bool loading: youtubeFeedModel.status == XmlListModel.Loading

    Component.onCompleted:
    {
        showTitle(true, "YouTube Subscriptions");
        showTime(true);
        showTicker(false);

        updateVideoDetails();
    }

    Keys.onPressed:
    {
        if (event.key === Qt.Key_F1)
        {
        }
        else if (event.key === Qt.Key_F2)
        {
        }
        else if (event.key === Qt.Key_F3)
        {
            play(false);
        }
        else if (event.key === Qt.Key_F4)
        {
            play(true);
        }
        else if (event.key === Qt.Key_F5)
        {
        }
        else if (event.key === Qt.Key_I)
        {
            infoDialog.infoText = youtubeFeedModel.get(videoList.currentIndex) ? youtubeFeedModel.get(videoList.currentIndex).description : "N/A";
            infoDialog.show(videoList.focus ? videoList : feedList);
        }
    }

    BaseBackground
    {
        x: xscale(20); y: yscale(50); width: parent.width - xscale(40); height: yscale(440)
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
            player: "YouTubeTV"
            duration: ""
        }
    }

    YoutubeSubListModel
    {
        id: feedsModel
    }

    YoutubeFeedModel
    {
        id: youtubeFeedModel
        source: root.currentFeed
        onLoaded: updateVideoDetails();
    }

    Component
    {
        id: listRow

        Item
        {
            width: feedList.width; height: yscale(50)
            z: 99

            property bool selected: ListView.isCurrentItem
            property bool focused: feedList.focus

            Image
            {
               id: iconImage
               x: xscale(3); y: yscale(3); height: parent.height - yscale(6); width: height
               fillMode: Image.PreserveAspectFit
               source: if (icon) icon; else mythUtils.findThemeFile("images/grid_noimage.png")
            }

            ListText
            {
                x: iconImage.width + xscale(6)
                width: feedList.width; height: yscale(50)
                text: name
            }
        }
    }

    ButtonList
    {
        id: feedList
        x: xscale(30); y: yscale(60); width: parent.width / 2 - xscale(40); height: yscale((8 * 50) + (7 * 3))
        spacing: 3
        clip: true
        model: feedsModel
        delegate: listRow

        onCurrentIndexChanged:
        {
            root.currentFeed = model.get(feedList.currentIndex).url
            videoList.currentIndex = 0
            youtubeFeedModel.reload()
        }

        Component.onCompleted:
        {
            root.currentFeed = model.get(feedList.currentIndex).url
            videoList.currentIndex = 0
            youtubeFeedModel.reload()
        }

        KeyNavigation.left: previousFocusItem ? previousFocusItem : videoList;
        KeyNavigation.right: videoList;
    }

    Component
    {
        id: articleDelegate

        Item
        {
            width: videoList.width
            height: yscale(103)

            property bool selected: ListView.isCurrentItem
            property bool focused: videoList.focus
            property real itemSize: videoList.itemWidth

            Image
            {
                id: icon
                x: xscale(10); y: yscale(10); width: parent.height - xscale(20); height: parent.height - yscale(20)
                source: findArticleImage(index)
            }

            ListText
            {
                id: titleText

                x: icon.width + xscale(20); y: yscale(10)
                width: parent.width - icon.width - xscale(30)
                height: parent.height - yscale(20)
                text: mythUtils.replaceHtmlChar(title)
                multiline: true
            }
        }
    }

    ButtonList
    {
        id: videoList
        property int itemWidth: 190

        x: parent.width / 2 + xscale(10); y: yscale(60); width: parent.width / 2- xscale(40); height: yscale(421)
        model: youtubeFeedModel
        clip: true
        delegate: articleDelegate
        spacing: 3

        KeyNavigation.left: feedList
        KeyNavigation.right: feedList

        Keys.onReturnPressed: play(false)

        onCurrentIndexChanged: updateVideoDetails()
    }

    BaseBackground
    {
        x: xscale(20); y: yscale(495); width: parent.width - xscale(40); height: yscale(205)
    }

    Image
    {
        id: articleImage
        x: xscale(30); y: yscale(505); width: xscale(185); height: yscale(185)
        onStatusChanged:  if (status == Image.Error) source = mythUtils.findThemeFile("images/grid_noimage.png")
    }

    TitleText
    {
        id: titleText
        x: xscale(230); y: yscale(505); width: parent.width - x - xscale(30); height: yscale(70)
        verticalAlignment: Text.AlignTop
        multiline: true
    }

    InfoText
    {
        id: descText
        x: xscale(230); y: yscale(575); width: parent.width - x - xscale(30); height: yscale(100)
        verticalAlignment: Text.AlignTop
        multiline: true
    }

    InfoText
    {
        id: published
        x: xscale(230); y: yscale(665); width: _xscale(900); height: yscale(30)
        verticalAlignment: Text.AlignBottom
        fontColor: "grey"
    }

    InfoText
    {
        id: duration
        x: parent.width - xscale(40) - width; y: yscale(665); width: _xscale(200); height: yscale(30)
        horizontalAlignment: Text.AlignRight
        verticalAlignment: Text.AlignBottom
        fontColor: "grey"
    }

    function findArticleImage(index)
    {
        if (youtubeFeedModel.get(index) && youtubeFeedModel.get(index).image !== "")
            return youtubeFeedModel.get(index).image;
        else if (youtubeFeedModel.get(index) && youtubeFeedModel.get(index).mediaContentUrl !== "")
            return youtubeFeedModel.get(index).mediaContentUrl;
        else if (youtubeFeedModel.get(index) && youtubeFeedModel.get(index).mediaContentUrl2 !== "")
            return youtubeFeedModel.get(index).mediaContentUrl2;
        else if (youtubeFeedModel.get(index) && youtubeFeedModel.get(index).enclosureType === "image" && youtubeFeedModel.get(index).enclosureUrl !== "")
            return youtubeFeedModel.get(index).enclosureUrl;
        else
            return mythUtils.findThemeFile("images/grid_noimage.png");
    }

    InfoDialog
    {
        id: infoDialog
        width: xscale(800)
    }

    JSONListModel
    {
        id: youtubeResult
        query: "$.items[*]"
    }

    function play(useYouTubeTV)
    {
        defaultFocusItem = videoList;
        mediaModel.get(0).title = youtubeFeedModel.get(videoList.currentIndex).title;
        mediaModel.get(0).icon = youtubeFeedModel.get(videoList.currentIndex).image;

        if (useYouTubeTV)
        {
            var youtubeID = youtubeFeedModel.get(videoList.currentIndex).id.replace('yt:video:', '')
            var url = "https://www.youtube.com/TV#/watch/video/control?v=" + youtubeID + "&resume"
            mediaModel.get(0).url = url;
            mediaModel.get(0).player = "YouTubeTV";
        }
        else
        {
            mediaModel.get(0).url = youtubeFeedModel.get(videoList.currentIndex).link;
            mediaModel.get(0).player = "YouTube";
        }

        if (root.isPanel)
        {
            internalPlayer.previousFocusItem = videoList;
            playerSources.adhocList = mediaModel;
            feedSelected("Adhoc", "", 0);
        }
        else
        {
            playerSources.adhocList = mediaModel;
            var item = stack.push({item: Qt.resolvedUrl("InternalPlayer.qml"), properties:{defaultFeedSource:  "Adhoc", defaultFilter:  "", defaultCurrentFeed: 0}});
        }
    }

    function parseYTTime(youtube_time)
    {
        var array = youtube_time.match(/(\d+)(?=[MHS])/ig)||[];
        var formatted = array.map(function(item)
        {
            if (item.length < 2) return '0' + item;
            return item;
        }).join(':');

        return formatted;
    }

    function updateVideoDetails()
    {
        if (videoList.currentIndex === -1)
            return;

        titleText.text = youtubeFeedModel.get(videoList.currentIndex) ? mythUtils.replaceHtmlChar(youtubeFeedModel.get(videoList.currentIndex).title) : "";

        // description
        descText.text = youtubeFeedModel.get(videoList.currentIndex) ? mythUtils.replaceHtmlChar(youtubeFeedModel.get(videoList.currentIndex).description) : "";

        // published
        published.text = youtubeFeedModel.get(videoList.currentIndex) ? Qt.formatDateTime(youtubeFeedModel.get(videoList.currentIndex).published, "dddd, dd MMM yyyy (hh:mm)") : "";

        // icon
        articleImage.source = findArticleImage(videoList.currentIndex)

        // query the YouTube  API for more details
        var youtubeID = youtubeFeedModel.get(videoList.currentIndex).id.replace('yt:video:', '')

        youtubeFeedModel.getYouTubeVideos(youtubeID,
            function ()
            {
                var json = this.responseText;
                youtubeResult.json = json;

                var ytDuration = youtubeResult.model.get(0).contentDetails.duration;
                if (ytDuration === "P0D")
                    duration.text = "Live Stream";
                else
                {
                    var d = parseYTTime(ytDuration);

                    if (d.length < 4)
                        d = "00:" + d

                    duration.text = "Duration: " + d;
                }
            }
        );
    }
}
