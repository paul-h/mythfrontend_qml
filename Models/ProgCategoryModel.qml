import QtQuick 2.0
import QtQuick.XmlListModel 2.0
import mythqml.net 1.0

XmlListModel
{
    source: settings.masterBackend + "Dvr/GetProgramCategories?OnlyRecorded=true"
    query: "/StringList/String"

    XmlRole { name: "item"; query: "string()" }

    onStatusChanged:
    {
        if (status == XmlListModel.Ready)
        {
            log.debug(Verbose.MODEL, "ProgCategoryModel: READY - Found " + count + " categories");
        }

        if (status === XmlListModel.Loading)
        {
            log.debug(Verbose.MODEL, "ProgCategoryModel: LOADING - " + source);
        }

        if (status === XmlListModel.Error)
        {
            log.error(Verbose.MODEL, "ProgCategoryModel: ERROR - " + errorString() + " - " + source);
        }
    }
}
