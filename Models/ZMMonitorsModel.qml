import QtQuick 2.0
import QtQuick.XmlListModel 2.0
import "../Util.js" as Util
import mythqml.net 1.0

Item
{
    id: root

    property string token
    property XmlListModel model: zmMonitorsModel
    property alias source: zmMonitorsModel.source
    property alias count: zmMonitorsModel.count

    property ListModel monitorsStatus: ListModel {}

    signal loaded();
    signal loadingStatus(int status);
    signal monitorStatus(int monitorId, string status);

    XmlListModel
    {
        id: zmMonitorsModel

        source: if (root.token !== "") "http://" + settings.zmIP + "/zm/api/monitors.xml?token=" + root.token; else ""

        signal loadingStatus(int status)

        property bool _updating: false

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
                log.debug(Verbose.MODEL, "ZMMonitorsModel: READY - Found " + count + " monitors");

                _updating = true;

                // create the monitor status list
                root.monitorsStatus.clear();

                for (var x = 0; x < count; x++)
                {
                    root.monitorsStatus.append({"monitorId": get(x).id, "name": get(x).name,  "status": "Idle"});
                }

                root.loaded();

                _updating = false;
            }

            if (status === XmlListModel.Loading)
            {
                log.debug(Verbose.MODEL, "ZMMonitorsModel: LOADING - " + source);
            }

            if (status === XmlListModel.Error)
            {
                log.error(Verbose.MODEL, "ZMMonitorsModel: ERROR: " + errorString() + " - " + source);
            }

            if (status === XmlListModel.Null)
            {
                log.debug(Verbose.MODEL, "ZMMonitorsModel: NULL - " + source);
            }

            loadingStatus(status);
        }
    }

    Timer
    {
        id: updateStatusTimer
        interval: 1000; running: (zmMonitorsModel.status === XmlListModel.Ready); repeat: true
        onTriggered:
        {
            if (zmMonitorsModel._updating)
                return;

            for (var x = 0; x < root.monitorsStatus.count; x++)
            {
                getAlarmStatus(root.monitorsStatus.get(x).monitorId,
                    function (monitorId, monStatus)
                    {
                        if (zmMonitorsModel._updating)
                            return;

                        var index = lookupMonitorIndex(monitorId);
                        if (index === -1)
                        {
                            log.error(Verbose.GENERAL, "ZMMonitorsModel: monitor failed to find index for: " + monitorId);
                            return;

                        }

                        if (monStatus !== root.monitorsStatus.get(index).status)
                        {
                            log.info(Verbose.MODEL, "ZMMonitorsModel: monitor " + root.monitorsStatus.get(index).monitorId + " status changed " + root.monitorsStatus.get(index).status + " -> " + monStatus);
                            root.monitorsStatus.get(index).status = monStatus;

                            if (monStatus === "Alarm")
                                showNotification("ZoneMinder: " + root.monitorsStatus.get(index).name + " camera<br><font  color=\"red\"><b>ALARM</b></font>");

                            // emit the monitorStatus signal
                            root.monitorStatus(monitorId, monStatus);
                        }
                    }
                );
            }
        }
    }

    function get(index)
    {
        return zmMonitorsModel.get(x);
    }

    function lookupMonitorIndex(id)
    {
        for (var x = 0; x < root.monitorsStatus.count; x++)
        {
            if (id == root.monitorsStatus.get(x).monitorId)
                return x;
        }

        return -1;
    }

    function lookupMonitorName(id)
    {
        for (var x = 0; x < zmMonitorsModel.count; x++)
        {
            if (id === zmMonitorsModel.get(x).id)
                return zmMonitorsModel.get(x).name;
        }

        return "NOT FOUND!!";
    }

    function forceAlarm(monitorID)
    {
        var http = new XMLHttpRequest();
        var url = "http://" + settings.zmIP + "/zm/api/monitors/alarm/id:" + monitorID + "/command:on.json?token=" + zmToken;
        var params = ""; //"token=" + playerSources.zmToken;

        http.withCredentials = true;
        http.open("GET", url, true);
        http.setRequestHeader("Content-type", "application/x-www-form-urlencoded");

        http.onreadystatechange = function()
        {
            if (http.readyState == 4)
            {
                if (http.status == 200)
                {
                    log.info(Verbose.GENERAL, "ZMMonitorsModel: Force Alarm OK - " + monitorID + " (" + http.responseText + ")")
                }
                else
                {
                    log.error(Verbose.GENERAL, "ZMMonitorsModel: Failed to force alarm. Got status - " + http.status)
                }
            }
        }
        http.send(params);
    }

    function cancelAlarm(monitorID)
    {
        var http = new XMLHttpRequest();
        var url = "http://" + settings.zmIP + "/zm/api/monitors/alarm/id:" + monitorID + "/command:off.json?token=" + zmToken;
        var params = ""; //"token=" + playerSources.zmToken;

        http.withCredentials = true;
        http.open("GET", url, true);
        http.setRequestHeader("Content-type", "application/x-www-form-urlencoded");

        http.onreadystatechange = function()
        {
            if (http.readyState == 4)
            {
                if (http.status == 200)
                {
                    log.info(Verbose.GENERAL, "ZMMonitorsModel: Cancel Forced Alarm OK - " + monitorID + " (" + http.responseText + ")")
                }
                else
                {
                    log.error(Verbose.GENERAL, "ZMMonitorsModel: Failed to cancel forced alarm. Got status - " + http.status)
                }
            }
        }
        http.send(params);
    }

    function getAlarmStatus(monitorId, callback)
    {
        var http = new XMLHttpRequest();
        var url = "http://" + settings.zmIP + "/zm/api/monitors/alarm/id:" + monitorId + "/command:status.json?token=" + zmToken;
        var params = "";

        http.withCredentials = true;
        http.open("GET", url, true);
        http.setRequestHeader("Content-type", "application/x-www-form-urlencoded");

        http.onreadystatechange = function()
        {
            if (http.readyState == 4)
            {
                if (http.status == 200)
                {
                    var response = http.responseText;
                    var json = JSON.parse(response);
                    var statusCode = parseInt(json.status);
                    var result;

                    switch (statusCode)
                    {
                        case -1:
                            result = "Unknown";
                            break;
                        case 0:
                            result = "Idle";
                            break;
                        case 1:
                            result = "Pre Alarm";
                            break;
                        case 2:
                            result = "Alarm";
                            break;
                        case 3:
                            result = "Alert";
                            break;
                        case 4:
                            result = "Tape";
                            break;
                        default:
                            result = "Unknown";
                            break;
                    }

                    log.debug(Verbose.GENERAL, "ZMMonitorsModel: Got alarm status OK - " + monitorId + " (" + result + ")");

                    if (typeof callback === "function")
                    {
                        callback.call(root, monitorId, result);
                    }
                }
                else
                {
                    log.error(Verbose.GENERAL, "ZMMonitorsModel: Failed to get alarm status. Got status - " + http.status)
                }
            }
        }
        http.send(params);
    }
}
