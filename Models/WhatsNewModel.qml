import QtQuick 2.0
import QtQuick.XmlListModel 2.0
import mythqml.net 1.0

XmlListModel
{
    id: whatsNewModel

    signal loaded();

    source: "https://mythqml.net/download.php?f=whatsnew.xml"

    query: "/items/item"
    XmlRole { name: "id"; query: "id/number()" }
    XmlRole { name: "minversion"; query: "minversion/string()" }
    XmlRole { name: "title"; query: "title/string()" }
    XmlRole { name: "date"; query: "date/string()" }
    XmlRole { name: "url"; query: "url/string()" }

    onStatusChanged:
    {
        if (status == XmlListModel.Ready)
        {
            log.debug(Verbose.MODEL, "WhatsNewModel: READY - Found " + count + " whats's new items");
            loaded();
        }

        if (status === XmlListModel.Loading)
        {
            log.debug(Verbose.MODEL, "WhatsNewModel: LOADING - " + source.toString());
        }

        if (status === XmlListModel.Error)
        {
            log.error(Verbose.MODEL, "WhatsNewModel: ERROR: " + errorString() + " - " + source.toString());
        }
    }
}
