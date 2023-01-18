import QtQuick 2.0
import QtQuick.XmlListModel 2.0
import mythqml.net 1.0

XmlListModel
{
    id: feedModel

    signal loaded();

    source: ""
    query: "/rss/channel/item"
    namespaceDeclarations: "declare namespace media = 'http://search.yahoo.com/mrss/'; " +
                           "declare namespace content = 'http://purl.org/rss/1.0/modules/content/';" +
                           "declare namespace slash = 'http://purl.org/rss/1.0/modules/slash/';" +
                           "declare namespace wfw = 'http://wellformedweb.org/CommentAPI/';" +
                           "declare namespace dc = 'http://purl.org/dc/elements/1.1/';";
    XmlRole { name: "title"; query: "title/string()" }
    XmlRole { name: "description"; query: "description/string()" }
    XmlRole { name: "encodedContent"; query: "content:encoded/string()"}
    XmlRole { name: "mediaContentUrl"; query: "media:group/media:content[1]/@url/string()" }
    XmlRole { name: "mediaContentUrl2"; query: "media:content[1]/@url/string()" }
    XmlRole { name: "image"; query: "media:thumbnail/@url/string()" }
    XmlRole { name: "enclosureUrl"; query: "enclosure/@url/string()" }
    XmlRole { name: "enclosureType"; query: "enclosure/@type/string()" }
    XmlRole { name: "link"; query: "link/string()" }
    XmlRole { name: "pubDate"; query: "pubDate/string()" }

    onStatusChanged:
    {
        if (status == XmlListModel.Ready)
        {
            log.debug(Verbose.MODEL, "RssFeedModel: READY - Found " + count + " RSS feeds");
            loaded();
        }

        if (status === XmlListModel.Loading)
        {
            log.debug(Verbose.MODEL, "RssFeedModel: LOADING - " + source);
        }

        if (status === XmlListModel.Error)
        {
            log.error(Verbose.MODEL, "RssFeedModel: ERROR: " + errorString() + " - " + source);
        }
    }
}
