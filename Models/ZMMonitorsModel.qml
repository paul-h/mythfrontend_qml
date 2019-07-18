import QtQuick 2.0
import QtQuick.XmlListModel 2.0
import "../Util.js" as Util

XmlListModel
{
    id: zmMonitorsModel

    property string auth

    signal loaded();

    source: if (auth !== "") "http://" + settings.zmIP + "/zm/api/monitors.xml?" + auth; else ""

    query: "/response/monitors"
    XmlRole { name: "id"; query: "Monitor/Id/number()"; isKey: true }
    XmlRole { name: "name"; query: "Monitor/Name/string()" }
    XmlRole { name: "monfunction"; query: "Monitor/Function/string()"; isKey: true }
    XmlRole { name: "monenabled"; query: "xs:boolean(Monitor/Enabled)"; isKey: true }
    XmlRole { name: "device"; query: "Monitor/Device/string()" }
    XmlRole { name: "channel"; query: "Monitor/Channel/string()" }
    XmlRole { name: "host"; query: "Monitor/Host/string()" }
    XmlRole { name: "totalevents"; query: "Monitor/TotalEvents/number()"; isKey: true }
    XmlRole { name: "totaleventsdiskspace"; query: "Monitor/TotalEventDiskSpace/number()"; isKey: true }


    XmlRole { name: "title"; query: "Monitor/Name/string()" }
    XmlRole { name: "player"; query: "xs:string('WebBrowser')" }
    XmlRole { name: "url"; query: "concat(xs:string('http://" + settings.zmIP + "'),
                                          xs:string('/zm/cgi-bin/nph-zms?scale=300&amp;mode=jpeg&amp;maxfps=5&amp;buffer=1000&amp;monitor='),
                                          Monitor/Id/string(),
                                          xs:string('&amp;user=" + settings.zmUserName + "&amp;pass=" + settings.zmPassword + "'))" }

    onStatusChanged:
    {
        if (status == XmlListModel.Ready)
        {
            loaded();
        }

        if (status === XmlListModel.Error)
        {
            console.log("Status: " + "Zoneminder Monitors - ERROR: " + errorString() + "\n" + source.toString());
        }
    }

    function lookupMonitorName(id)
    {
        for (var x = 0; x < count; x++)
        {
            if (id === get(x).id)
                return get(x).name;
        }

        return "NOT FOUND!!";
    }
}
