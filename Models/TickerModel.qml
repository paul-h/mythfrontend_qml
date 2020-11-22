import QtQuick 2.0
import QtQuick.XmlListModel 2.0
import mythqml.net 1.0

XmlListModel
{
    id: tickerModel

    source: settings.configPath + "ticker.xml"

    query: "/items/item"
    XmlRole { name: "id"; query: "id/number()" }
    XmlRole { name: "category"; query: "category/string()" }
    XmlRole { name: "text"; query: "text/string()" }

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
}
