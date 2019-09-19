import QtQuick 2.0
import QtQuick.XmlListModel 2.0
import mythqml.net 1.0

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
            log.debug(Verbose.MODEL, "SDChanelsModel: READY - Found " + count + " SD channels");
        }

        if (status === XmlListModel.Loading)
        {
            log.debug(Verbose.MODEL, "SDChanelsModel: LOADING - " + source.toString());
        }

        if (status === XmlListModel.Error)
        {
            log.error(Verbose.MODEL, "SDChanelsModel: ERROR: " + errorString() + " - " + source.toString());
        }
    }
}
