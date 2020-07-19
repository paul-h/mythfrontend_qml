import QtQuick 2.0
import QtQuick.XmlListModel 2.0
import mythqml.net 1.0

XmlListModel
{
    id: zmDaemonCheckModel

    property bool running: if (count) get(0).running; else false

    signal loaded();

    source: "http://" + settings.zmIP + "/zm/api/host/daemonCheck.xml?token=" + playerSources.zmToken
    query: "/response"
    XmlRole { name: "running"; query: "xs:boolean(result)" }

    onStatusChanged:
    {
        if (status == XmlListModel.Ready)
        {
            log.debug(Verbose.MODEL, "ZMDaemonCheckModel: READY - Found " + count + " daemon check items");
            loaded();
        }

        if (status === XmlListModel.Loading)
        {
            log.debug(Verbose.MODEL, "ZMDaemonCheckModel: LOADING - " + source.toString());
        }

        if (status === XmlListModel.Error)
        {
            log.error(Verbose.MODEL, "ZMDaemonCheckModel: ERROR - " + errorString() + " - " + source.toString());
        }
    }
}
