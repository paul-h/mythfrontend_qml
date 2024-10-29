import QtQuick
import QtQml.XmlListModel

import mythqml.net 1.0

XmlListModel
{
    id: vboxChannelsModel

    property string broadcaster: "freeview"

    source: if (broadcaster === "freeview")
                settings.vboxFreeviewIP + "/cgi-bin/HttpControl/HttpControlApp?OPTION=1&Method=GetXmltvChannelsList&FromChIndex=FirstChannel&ToChIndex=LastChannel"
            else
                settings.vboxFreesatIP + "/cgi-bin/HttpControl/HttpControlApp?OPTION=1&Method=GetXmltvChannelsList&FromChIndex=FirstChannel&ToChIndex=LastChannel"

    query: "/tv/channel"
    XmlListModelRole { name: "id"; elementName: "" elementName: "id"}
    XmlListModelRole { name: "name"; elementName: "display-name[1]" }
    XmlListModelRole { name: "type"; elementName: "display-name[2]" }
    XmlListModelRole { name: "flags"; elementName: "display-name[3]" }
    XmlListModelRole { name: "lcn"; elementName: "display-name[5]" }
    XmlListModelRole { name: "icon"; elementName: "icon"; attributeName: "src" }
    XmlListModelRole { name: "url"; elementName: "url"; attributeName: "src" }
    onStatusChanged:
    {
        if (status == XmlListModel.Ready)
        {
            log.debug(Verbose.MODEL, "VboxChannelsModel: READY - Found " + count + " vbox channels");
        }

        if (status === XmlListModel.Loading)
        {
            log.debug(Verbose.MODEL, "VboxChannelsModel: LOADING - " + source);
        }

        if (status === XmlListModel.Error)
        {
            log.error(Verbose.MODEL, "VboxChannelsModel: ERROR: " + errorString() + " - " + source);
        }
    }
}
