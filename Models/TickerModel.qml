import QtQuick 2.0
import QtQuick.XmlListModel 2.0

XmlListModel
{
    id: tickerModel

    source: settings.configPath + "/MythNews/ticker.xml"

    query: "/items/item"
    XmlRole { name: "id"; query: "id/number()" }
    XmlRole { name: "category"; query: "category/string()" }
    XmlRole { name: "text"; query: "text/string()" }

    onStatusChanged:
    {
        if (status === XmlListModel.Error)
            console.info("Status: " + "TickerModel - ERROR: " + errorString + "\n" + tickerModel.source.toString());
    }
}
