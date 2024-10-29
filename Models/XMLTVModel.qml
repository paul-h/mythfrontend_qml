import QtQuick
import QtQml.XmlListModel

import mythqml.net 1.0

XmlListModel
{
    id: feedModel

    signal loaded();

    source: ""
    query: "/tv/programme"
    XmlListModelRole { name: "title"; elementName: "title" }
    XmlListModelRole { name: "description"; elementName: "desc" }
    XmlListModelRole { name: "channel"; elementName: ""; attributeName: "channel" }
    XmlListModelRole { name: "progStart"; elementName: ""; attributeName: "start" }
    XmlListModelRole { name: "progEnd"; elementName: ""; attributeName: "stop" }
    XmlListModelRole { name: "category"; elementName: "category" }

    onStatusChanged:
    {
        if (status == XmlListModel.Ready)
        {
            log.debug(Verbose.MODEL, "XMLTVModel: READY - Found " + count + " programmes found");
            loaded();
        }

        if (status === XmlListModel.Loading)
        {
            log.debug(Verbose.MODEL, "XMLTVModel: LOADING - " + source);
        }

        if (status === XmlListModel.Error)
        {
            log.error(Verbose.MODEL, "XMLTVModel: ERROR: " + errorString() + " - " + source);
        }
    }
}
