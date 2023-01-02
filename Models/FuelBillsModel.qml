import QtQuick 2.0
import QtQuick.XmlListModel 2.0
import mythqml.net 1.0

XmlListModel
{
    query: "/items/item"

    signal loaded();

    XmlRole { name: "id";   query: "id/number()" }
    XmlRole { name: "name"; query: "name/string()" }
    XmlRole { name: "url";  query: "url/string()" }

    onStatusChanged:
    {
        if (status == XmlListModel.Ready)
        {
            log.debug(Verbose.MODEL, "FuelBillsModel: READY - Found " + count + " bills");
            loaded();
        }

        if (status === XmlListModel.Loading)
        {
            log.debug(Verbose.MODEL, "FuelBillsModel: LOADING - " + source);
        }

        if (status === XmlListModel.Error)
        {
            log.debug(Verbose.MODEL, "FuelBillsModel: ERROR: " + errorString() + " - " + source);
        }
    }
}
