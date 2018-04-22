import QtQuick 2.0
import QtQuick.XmlListModel 2.0

XmlListModel
{
    id: sdChannelsModel
    source: settings.sdChannels
    query: "/tv/channel"
    XmlRole { name: "xmltvid"; query: "@id/string()" }
    XmlRole { name: "name"; query: "display-name[1]/string()" }
    XmlRole { name: "callsign"; query: "display-name[2]/string()" }
    XmlRole { name: "channo"; query: "display-name[3]/string()" }
    XmlRole { name: "icon"; query: "icon/@src/string()" }
    onStatusChanged:
    {
        if (status == XmlListModel.Ready)
        {
            console.log("Status: " + "SD Channels - READY \n" + sdChannelsModel.source.toString());
        }

        if (status === XmlListModel.Loading)
        {
            console.log("Status: " + "SD Channels - LOADING \n" + sdChannelsModel.source.toString());
        }

        if (status === XmlListModel.Error)
        {

            console.log("Status: " + "SD Channels - ERROR: " + errorString + "\n \n \n " + sdChannelsModel.source.toString());
        }
    }
}
