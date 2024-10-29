import QtQuick
import QtQml.XmlListModel

import mythqml.net 1.0

XmlListModel
{
    id: whatsNewModel

    signal loaded();

    source: "https://mythqml.net/download.php?f=whatsnew.xml&v=" + version + "&s=" + systemid

    query: "/items/item"
    XmlListModelRole { name: "id"; elementName: "id" } // number
    XmlListModelRole { name: "minversion"; elementName: "minversion" }
    XmlListModelRole { name: "title"; elementName: "title" }
    XmlListModelRole { name: "date"; elementName: "date" }
    XmlListModelRole { name: "url"; elementName: "url" }

    onStatusChanged:
    {
        if (status == XmlListModel.Ready)
        {
            log.debug(Verbose.MODEL, "WhatsNewModel: READY - Found " + count + " whats's new items");
            loaded();
        }

        if (status === XmlListModel.Loading)
        {
            log.debug(Verbose.MODEL, "WhatsNewModel: LOADING - " + source);
        }

        if (status === XmlListModel.Error)
        {
            log.error(Verbose.MODEL, "WhatsNewModel: ERROR: " + errorString() + " - " + source);
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
