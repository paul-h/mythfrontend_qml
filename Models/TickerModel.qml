import QtQuick
import QtQml.XmlListModel

import mythqml.net 1.0

XmlListModel
{
    id: tickerModel

    source: settings.configPath + "ticker.xml"

    query: "/items/item"
    XmlListModelRole { name: "id"; elementName: "id" }
    XmlListModelRole { name: "category"; elementName: "category" }
    XmlListModelRole { name: "text"; elementName: "text" }

    onStatusChanged:
    {
        if (status == XmlListModel.Ready)
        {
            log.debug(Verbose.MODEL, "TickerModel: READY - Found " + count + " ticker items");
        }

        if (status === XmlListModel.Loading)
        {
            log.debug(Verbose.MODEL, "TickerModel: LOADING - " + source);
        }

        if (status === XmlListModel.Error)
        {
            log.error(Verbose.MODEL, "TickerModel: ERROR: " + errorString() + " - " + source);
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
