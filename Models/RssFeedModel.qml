import QtQuick 2.0
import QtQuick.XmlListModel 2.0

XmlListModel
{
    id: feedModel

    source: ""
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
            console.info("FeedModel Status: ready")
        }
        else if (status == XmlListModel.Error)
        {
            console.info("FeedModel Status: error")
        }
        else if (status == XmlListModel.Loading)
        {
            console.info("feedModel Status: loading")
        }
    }

    onSourceChanged:
    {
        console.log("Current feed url changed: " + source)
    }
}
