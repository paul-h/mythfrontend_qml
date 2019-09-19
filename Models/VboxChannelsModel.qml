import QtQuick 2.0
import QtQuick.XmlListModel 2.0
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
    XmlRole { name: "id"; query: "@id/string()" }
    XmlRole { name: "name"; query: "display-name[1]/string()" }
    XmlRole { name: "type"; query: "display-name[2]/string()" }
    XmlRole { name: "flags"; query: "display-name[3]/string()" }
    XmlRole { name: "lcn"; query: "display-name[5]/string()" }
    XmlRole { name: "icon"; query: "icon/@src/string()" }
    XmlRole { name: "url"; query: "url/@src/string()" }
    onStatusChanged:
    {
        if (status == XmlListModel.Ready)
        {
            log.debug(Verbose.MODEL, "VboxChannelsModel: READY - Found " + count + " vbox channels");
        }

        if (status === XmlListModel.Loading)
        {
            log.debug(Verbose.MODEL, "VboxChannelsModel: LOADING - " + source.toString());
        }

        if (status === XmlListModel.Error)
        {
            log.error(Verbose.MODEL, "VboxChannelsModel: ERROR: " + errorString() + " - " + source.toString());
        }
    }
}
