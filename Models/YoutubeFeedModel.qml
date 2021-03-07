import QtQuick 2.0
import QtQuick.XmlListModel 2.0
import mythqml.net 1.0

XmlListModel
{
    signal loaded();

    source: ""
    query: "/feed/entry"
    namespaceDeclarations: "declare default element namespace 'http://www.w3.org/2005/Atom'; declare namespace media = 'http://search.yahoo.com/mrss/'; "
    XmlRole { name: "id"; query: "id/string()" }
    XmlRole { name: "title"; query: "media:group/media:title/string()" }
    XmlRole { name: "description"; query: "media:group/media:description/string()" }
    XmlRole { name: "image"; query: "media:group/media:thumbnail/@url/string()" }
    XmlRole { name: "published"; query: "published/string()" }
    XmlRole { name: "updated"; query: "updated/string()" }
    XmlRole { name: "link"; query: "link/@href/string()" }

    onStatusChanged:
    {
        if (status == XmlListModel.Ready)
        {
            log.debug(Verbose.MODEL, "YoutubeFeedModel: READY - Found " + count + " Youtube feeds");
            loaded();
        }

        if (status === XmlListModel.Loading)
        {
            log.debug(Verbose.MODEL, "YoutubeFeedModel: LOADING - " + source);
        }

        if (status === XmlListModel.Error)
        {
            log.error(Verbose.MODEL, "YoutubeFeedModel: ERROR: " + errorString() + " - " + source);
        }
    }
}
