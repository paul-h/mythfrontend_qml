import QtQuick 2.0
import QtQuick.XmlListModel 2.0
import QtQuick.Controls 1.4
import Base 1.0
import "../../../Models"

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

    XmlListModel
    {
        id: feedModel

        source: root.currentFeed
        query: "/rss/channel/item"
        namespaceDeclarations: "declare namespace media = 'http://search.yahoo.com/mrss/'; " +
                               "declare namespace content = 'http://purl.org/rss/1.0/modules/content/';" +
                               "declare namespace slash = 'http://purl.org/rss/1.0/modules/slash/';" +
                               "declare namespace wfw = 'http://wellformedweb.org/CommentAPI/';" +
                               "declare namespace dc = 'http://purl.org/dc/elements/1.1/';";
        XmlRole { name: "title"; query: "title/string()" }
        // Remove any links from the description
        XmlRole { name: "description"; query: "fn:replace(description/string(), '\&lt;a href=.*\/a\&gt;', '')" }
        XmlRole { name: "encodedContent"; query: "content:encoded/string()"}
        XmlRole { name: "mediaContentUrl"; query: "media:group/media:content[1]/@url/string()" }
        XmlRole { name: "image"; query: "media:thumbnail/@url/string()" }
        XmlRole { name: "enclosureUrl"; query: "enclosure/@url/string()" }
        XmlRole { name: "enclosureType"; query: "enclosure/@type/string()" }
        XmlRole { name: "link"; query: "link/string()" }
        XmlRole { name: "pubDate"; query: "pubDate/string()" }

        onStatusChanged:
        {
            if (status == XmlListModel.Ready)
            {
                console.log("FeedModel Status: ready")
            }
            else if (status == XmlListModel.Error)
            {
                console.log("FeedModel Status: error")
            }
            else if (status == XmlListModel.Loading)
            {
                console.log("feedModel Status: loading")
            }
        }

        onSourceChanged:
        {
            console.log("Current feed url changed: " + source)
        }
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
                text: title
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
            stack.push({item: Qt.resolvedUrl("WebBrowser.qml"), properties:{url: feedModel.get(articleList.currentIndex).link}});
        }

        onCurrentIndexChanged:
        {
            console.log("Current articleList index is:" + currentIndex)
            console.log("image: " + (feedModel.get(articleList.currentIndex) ? feedModel.get(articleList.currentIndex).image : ""))
            console.log("mediaContentUrl: " + (feedModel.get(articleList.currentIndex) ? feedModel.get(articleList.currentIndex).mediaContentUrl : ""))
            console.log("enclosureURL: " + (feedModel.get(articleList.currentIndex) ? feedModel.get(articleList.currentIndex).enclosureUrl : ""))
            console.log("enclosureType: " + (feedModel.get(articleList.currentIndex) ? feedModel.get(articleList.currentIndex).enclosureType : ""))
            console.log("link: " + (feedModel.get(articleList.currentIndex) ? feedModel.get(articleList.currentIndex).link : ""))
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
    }

    Text
    {
        id: titleText
        x: xscale(230); y: yscale(510); width: xscale(900); height: yscale(50)
        font { pixelSize: 24; bold: true }
        text: feedModel.get(articleList.currentIndex) ? feedModel.get(articleList.currentIndex).title : ""
        color: "#ffffff"
    }

    Text
    {
        id: descText
        x: xscale(230); y: yscale(550); width: xscale(900); height: yscale(100)
        font { pixelSize: 18; bold: true }
        wrapMode: Text.WordWrap
        text: feedModel.get(articleList.currentIndex) ? feedModel.get(articleList.currentIndex).description: ""
        color: "#ff00ff"
    }

    function findArticleImage(index)
    {
        if (feedModel.get(index) && feedModel.get(index).image != "")
            return feedModel.get(index).image;
        else if (feedModel.get(index) && feedModel.get(index).mediaContentUrl != "")
            return feedModel.get(index).mediaContentUrl;
        else if (feedModel.get(index) && feedModel.get(index).enclosureType === "image" && feedModel.get(index).enclosureUrl != "")
            return feedModel.get(index).enclosureUrl;
        else if (rssFeedsModel.data(rssFeedsModel.index(feedList.currentIndex, 2)) != "")
            return rssFeedsModel.data(rssFeedsModel.index(feedList.currentIndex, 2))
            else
                return mythUtils.findThemeFile("images/grid_noimage.png");
    }
}
