import QtQuick
import QtQml.XmlListModel

import mythqml.net 1.0

XmlListModel
{
    query: "/items/item"

    signal loaded();

    XmlListModelRole { name: "id";   elementName: "id" }
    XmlListModelRole { name: "name"; elementName: "name" }
    XmlListModelRole { name: "url";  elementName: "url" }

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
