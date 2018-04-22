import QtQuick 2.0
import QtQuick.XmlListModel 2.0

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
            console.log("Status: " + "VBox Channels - READY \n" + vboxChannelsModel.source.toString());
        }

        if (status === XmlListModel.Loading)
        {
            console.log("Status: " + "VBox Channels - LOADING \n" + vboxChannelsModel.source.toString());
        }

        if (status === XmlListModel.Error)
        {

            console.log("Status: " + "VBox Channels - ERROR: " + errorString + "\n \n \n " + vboxChannelsModel.source.toString());
        }
    }
}
