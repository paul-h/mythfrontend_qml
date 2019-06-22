import QtQuick 2.0
import QtQuick.XmlListModel 2.0

XmlListModel
{
    id: zmLoadModel

    property string load1: if (count) get(0).load1; else "?"
    property string load5: if (count) get(0).load5; else "?"
    property string load15: if (count) get(0).load15; else "?"

    signal loaded();

    source: "http://" + settings.zmIP + "/zm/api/host/getLoad.xml?" + playerSources.zmAuth
    query: "/response"
    XmlRole { name: "load1"; query: "load[1]/string()" }
    XmlRole { name: "load5"; query: "load[2]/string()" }
    XmlRole { name: "load15"; query: "load[3]/string()" }

    onStatusChanged:
    {
        if (status == XmlListModel.Ready)
        {
            loaded();
        }

        if (status === XmlListModel.Error)
        {
            console.log("Status: " + "ZMLoadModel - ERROR: " + errorString() + "\n" + source.toString());
        }
    }
}
