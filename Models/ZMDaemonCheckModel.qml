import QtQuick 2.0
import QtQuick.XmlListModel 2.0

XmlListModel
{
    id: zmDaemonCheckModel

    property bool running: if (count) get(0).running; else false

    signal loaded();

    source: "http://" + settings.zmIP + "/zm/api/host/daemonCheck.xml?" + playerSources.zmAuth
    query: "/response"
    XmlRole { name: "running"; query: "xs:boolean(result)" }

    onStatusChanged:
    {
        if (status == XmlListModel.Ready)
        {
            if (count) running = get(0).running; else running = false;
            loaded();
        }

        if (status === XmlListModel.Error)
        {
            console.log("Status: " + "ZMDaemonCheckModel - ERROR: " + errorString() + "\n" + source.toString());
        }
    }
}
