import QtQuick 2.0
import QtQuick.XmlListModel 2.0

XmlListModel
{
    id: zmMonitorsModel

    property string auth

    source: "http://" + settings.zmIP + "/zm/api/monitors.xml?" + auth

    query: "/response/monitors"
    XmlRole { name: "id"; query: "Monitor/Id/string()" }
    XmlRole { name: "name"; query: "Monitor/Name/string()" }
    XmlRole { name: "monfunction"; query: "Monitor/Function/string()" }
    XmlRole { name: "enabled"; query: "Monitor/Enabled/string()" }
    XmlRole { name: "device"; query: "Monitor/Device/string()" }
    XmlRole { name: "channel"; query: "Monitor/Channel/string()" }
    XmlRole { name: "host"; query: "Monitor/Host/string()" }
    XmlRole { name: "totalevents"; query: "Monitor/TotalEvents/string()" }
    XmlRole { name: "totaleventsdiskspace"; query: "Monitor/TotalEventDiskSpace/string()" }
    onStatusChanged:
    {
        if (status === XmlListModel.Error)
        {
            console.log("Status: " + "Zoneminder Monitors - ERROR: " + errorString() + "\n" + source.toString());
        }
    }
}
