import QtQuick 2.0
import QtQuick.XmlListModel 2.0

XmlListModel
{
    source: settings.masterBackend + "Dvr/GetProgramCategories?OnlyRecorded=true"
    query: "/StringList/String"

    XmlRole { name: "item"; query: "string()" }

    onStatusChanged:
    {
        if (status == XmlListModel.Ready)
        {
            console.info("Status: " + "GetCategories - Found " + count + " categories");
        }

        if (status === XmlListModel.Loading)
        {
            console.info("Status: " + "GetCategories - LOADING - " + source.toString());
        }

        if (status === XmlListModel.Error)
        {
            console.info("Status: " + "GetCategories - ERROR: " + errorString + "\n" + source.toString());
        }
    }
}
