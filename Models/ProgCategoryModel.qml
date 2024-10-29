import QtQuick
import QtQml.XmlListModel

import mythqml.net 1.0

XmlListModel
{
    source: settings.masterBackend + "Dvr/GetProgramCategories?OnlyRecorded=true"
    query: "/StringList/String"

    XmlListModelRole { name: "item"; elementName: "string()" } //FIXME??

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
