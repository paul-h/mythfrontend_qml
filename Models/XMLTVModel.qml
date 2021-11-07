import QtQuick 2.0
import QtQuick.XmlListModel 2.0
import mythqml.net 1.0

XmlListModel
{
    id: feedModel

    signal loaded();

    source: ""
    query: "/tv/programme"
    XmlRole { name: "title"; query: "title/string()" }
    XmlRole { name: "description"; query: "desc/string()" }
    XmlRole { name: "channel"; query: "@channel/string()"}
    XmlRole { name: "progStart"; query: "@start/string()" }
    XmlRole { name: "progEnd"; query: "@stop/string()" }
    XmlRole { name: "category"; query: "category/string()" }

    onStatusChanged:
    {
        if (status == XmlListModel.Ready)
        {
            log.debug(Verbose.MODEL, "XMLTVModel: READY - Found " + count + " programmes found");
            loaded();
        }

        if (status === XmlListModel.Loading)
        {
            log.debug(Verbose.MODEL, "XMLTVModel: LOADING - " + source);
        }

        if (status === XmlListModel.Error)
        {
            log.error(Verbose.MODEL, "XMLTVModel: ERROR: " + errorString() + " - " + source);
        }
    }
}
