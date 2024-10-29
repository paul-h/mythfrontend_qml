import QtQuick
import QtQml.XmlListModel

import mythqml.net 1.0

XmlListModel
{
    source: settings.masterBackend + "Dvr/GetRecGroupList"
    query: "/StringList/String"

    XmlListModelRole { name: "item"; elementName: "string()" } //FIXME??

    onStatusChanged:
    {
        if (status == XmlListModel.Ready)
        {
            log.debug(Verbose.MODEL, "RecGroupModel: READY - Found " + count + " rec groups");
        }

        if (status === XmlListModel.Loading)
        {
            log.debug(Verbose.MODEL, "RecGroupModel: LOADING - " + source);
        }

        if (status === XmlListModel.Error)
        {
            log.debug(Verbose.MODEL, "RecGroupModel: ERROR: " + errorString() + " - " + source);
        }
    }
}
