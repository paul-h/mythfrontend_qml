import QtQuick
import QtQml.XmlListModel

import mythqml.net 1.0

XmlListModel
{
    id: feedModel

    signal loaded();

    source: ""
    query: "/rss/channel/item"
    //namespaceDeclarations: "declare namespace media = 'http://search.yahoo.com/mrss/'; " +
    //                       "declare namespace content = 'http://purl.org/rss/1.0/modules/content/';" +
    //                       "declare namespace slash = 'http://purl.org/rss/1.0/modules/slash/';" +
    //                       "declare namespace wfw = 'http://wellformedweb.org/CommentAPI/';" +
    //                       "declare namespace dc = 'http://purl.org/dc/elements/1.1/';";
    XmlListModelRole { name: "title"; elementName: "title" }
    XmlListModelRole { name: "description"; elementName: "description" }
    XmlListModelRole { name: "encodedContent"; elementName: "content:encoded"}
    // fixme these don't work in Qt6??
    //XmlListModelRole { name: "mediaContentUrl"; elementName: "media:group/media:content[1]/@url/string()" }
    //XmlListModelRole { name: "mediaContentUrl2"; elementName: "media:content[1]/@url/string()" }
    XmlListModelRole { name: "image"; elementName: "media:thumbnail"; attributeName: "url" }
    XmlListModelRole { name: "enclosureUrl"; elementName: "enclosure"; attributeName: "url" }
    XmlListModelRole { name: "enclosureType"; elementName: "enclosure"; attributeName: "type" }
    XmlListModelRole { name: "link"; elementName: "link" }
    XmlListModelRole { name: "pubDate"; elementName: "pubDate" }

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

    function get(i)
    {
        var o = {}
        for (var j = 0; j < roles.length; ++j)
        {
            o[roles[j].name] = data(index(i,0), Qt.UserRole + j)
        }
        return o
    }
}
