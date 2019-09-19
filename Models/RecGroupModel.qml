import QtQuick 2.0
import QtQuick.XmlListModel 2.0
import mythqml.net 1.0

XmlListModel
{
    source: settings.masterBackend + "Dvr/GetRecGroupList"
    query: "/StringList/String"

    XmlRole { name: "item"; query: "string()" }

    onStatusChanged:
    {
        if (status == XmlListModel.Ready)
        {
            log.debug(Verbose.MODEL, "RecGroupModel: READY - Found " + count + " rec groups");
        }

        if (status === XmlListModel.Loading)
        {
            log.debug(Verbose.MODEL, "RecGroupModel: LOADING - " + source.toString());
        }

        if (status === XmlListModel.Error)
        {
            log.debug(Verbose.MODEL, "RecGroupModel: ERROR: " + errorString() + " - " + source.toString());
        }
    }
}
