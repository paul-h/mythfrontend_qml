import QtQuick 2.0
import QtQuick.XmlListModel 2.0
import QtQuick.Controls 1.4
import Base 1.0
import Models 1.0
import mythqml.net 1.0

BaseScreen
{
    id: root

    defaultFocusItem: feedList
    property string currentFeed: ""
    property bool loading: feedModel.status == XmlListModel.Loading

    Component.onCompleted:
    {
        showTitle(true, "RSS Feeds");
        showTime(true);
        showTicker(false);
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
        }
        else if (event.key === Qt.Key_F4)
        {
        }
        else if (event.key === Qt.Key_F5)
        {
        }
    }

    BaseBackground
    {
        x: xscale(20); y: yscale(50); width: xscale(1240); height: yscale(440)
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
               id: icon
               x: xscale(3); y: yscale(3); height: parent.height - yscale(6); width: height
               fillMode: Image.PreserveAspectFit
               source: if (ico) ico; else mythUtils.findThemeFile("images/grid_noimage.png")
            }

            ListText
            {
                x: icon.width + xscale(6)
                width: feedList.width; height: yscale(50)
                text: name
            }
        }
    }

    ButtonList
    {
        id: feedList
        x: xscale(30); y: yscale(60); width: xscale(550); height: yscale((8 * 50) + (7 * 3))
        spacing: 3
        clip: true
        model: rssFeedsModel
        delegate: listRow

        onCurrentIndexChanged:
        {
            root.currentFeed = rssFeedsModel.data(rssFeedsModel.index(feedList.currentIndex, 1))
            articleList.currentIndex = 0
            feedModel.reload()
        }

        Component.onCompleted:
        {
            root.currentFeed = rssFeedsModel.data(rssFeedsModel.index(feedList.currentIndex, 1))
            articleList.currentIndex = 0
            feedModel.reload()
        }

        KeyNavigation.left: articleList;
        KeyNavigation.right: articleList;
    }

    RssFeedModel
    {
        id: feedModel
        source: root.currentFeed
    }

    Component
    {
        id: articleDelegate

        Item
        {
            width: articleList.width
            height: yscale(103)

            property bool selected: ListView.isCurrentItem
            property bool focused: articleList.focus
            property real itemSize: articleList.itemWidth

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

            BusyIndicator
            {
                scale: 0.8
                running: true //root.loading
                visible: root.loading  //articleDelegate.ListView.isCurrentItem && root.loading
                anchors.centerIn: parent
            }

        }
    }

    ButtonList
    {
        id: articleList
        property int itemWidth: 190

        x: xscale(600); y: yscale(60); width: xscale(650); height: yscale(421)
        model: feedModel
        clip: true
        delegate: articleDelegate
        spacing: 3

        KeyNavigation.left: feedList;
        KeyNavigation.right: feedList;

        Keys.onReturnPressed:
        {
            returnSound.play();
            stack.push({item: Qt.resolvedUrl("WebBrowser.qml"), properties:{url: feedModel.get(articleList.currentIndex).link, zoomFactor: xscale(1.0)}});
        }

        onCurrentIndexChanged:
        {
            //log.debug(Verbose.GENERAL, "RSSFeeds: Current articleList index is -" + currentIndex)
            //log.debug(Verbose.GENERAL, "RSSFeeds: image - " + (feedModel.get(articleList.currentIndex) ? feedModel.get(articleList.currentIndex).image : ""))
            //log.debug(Verbose.GENERAL, "RSSFeeds: mediaContentUrl - " + (feedModel.get(articleList.currentIndex) ? feedModel.get(articleList.currentIndex).mediaContentUrl : ""))
            //log.debug(Verbose.GENERAL, "RSSFeeds: mediaContentUrl2 - " + (feedModel.get(articleList.currentIndex) ? feedModel.get(articleList.currentIndex).mediaContentUrl2 : ""))
            //log.debug(Verbose.GENERAL, "RSSFeeds: enclosureURL - " + (feedModel.get(articleList.currentIndex) ? feedModel.get(articleList.currentIndex).enclosureUrl : ""))
            //log.debug(Verbose.GENERAL, "RSSFeeds: enclosureType - " + (feedModel.get(articleList.currentIndex) ? feedModel.get(articleList.currentIndex).enclosureType : ""))
            //log.debug(Verbose.GENERAL, "RSSFeeds: link - " + (feedModel.get(articleList.currentIndex) ? feedModel.get(articleList.currentIndex).link : ""))

            articleImage.source = findArticleImage(articleList.currentIndex);
        }
    }

    BaseBackground
    {
        x: xscale(20); y: yscale(495); width: xscale(1240); height: yscale(205)
    }

    Image
    {
        id: articleImage
        x: xscale(30); y: yscale(505); width: xscale(185); height: yscale(185)
        source: findArticleImage(articleList.currentIndex)
        onStatusChanged:  if (status == Image.Error) source = mythUtils.findThemeFile("images/grid_noimage.png")
    }

    TitleText
    {
        id: titleText
        x: xscale(230); y: yscale(505); width: xscale(1020); height: yscale(70)
        verticalAlignment: Text.AlignTop
        multiline: true
        text: feedModel.get(articleList.currentIndex) ? mythUtils.replaceHtmlChar(feedModel.get(articleList.currentIndex).title) : ""
    }

    InfoText
    {
        id: descText
        x: xscale(230); y: yscale(575); width: xscale(1020); height: yscale(115)
        verticalAlignment: Text.AlignTop
        //textFormat: Text.RichText
        multiline: true
        text: feedModel.get(articleList.currentIndex) ? mythUtils.replaceHtmlChar(feedModel.get(articleList.currentIndex).description) : ""
    }

    function findArticleImage(index)
    {
        if (feedModel.get(index) && feedModel.get(index).image !== "")
            return feedModel.get(index).image;
        else if (feedModel.get(index) && feedModel.get(index).mediaContentUrl !== "")
            return feedModel.get(index).mediaContentUrl;
        else if (feedModel.get(index) && feedModel.get(index).mediaContentUrl2 !== "")
            return feedModel.get(index).mediaContentUrl2;
        else if (feedModel.get(index) && feedModel.get(index).enclosureType === "image" && feedModel.get(index).enclosureUrl !== "")
            return feedModel.get(index).enclosureUrl;
        else if (rssFeedsModel.data(rssFeedsModel.index(feedList.currentIndex, 2)) !== "")
            return rssFeedsModel.data(rssFeedsModel.index(feedList.currentIndex, 2))
        else
            return mythUtils.findThemeFile("images/grid_noimage.png");
    }
}
