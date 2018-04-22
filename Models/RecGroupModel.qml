import QtQuick 2.0
import QtQuick.XmlListModel 2.0

XmlListModel
{
    source: settings.masterBackend + "Dvr/GetRecGroupList"
    query: "/StringList/String"

    XmlRole { name: "item"; query: "string()" }

    onStatusChanged:
    {
        if (status == XmlListModel.Ready)
        {
            console.info("Status: " + "GetRecGroupList - Found " + count + " rec groups");
        }

        if (status === XmlListModel.Loading)
        {
            console.info("Status: " + "GetRecGroupList - LOADING - " + source.toString());
        }

        if (status === XmlListModel.Error)
        {
            console.info("Status: " + "GetRecGroupList - ERROR: " + errorString + "\n" + source.toString());
        }
    }
}
