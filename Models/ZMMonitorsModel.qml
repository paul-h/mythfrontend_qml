import QtQuick

import "../Util.js" as Util
import mythqml.net 1.0

Item
{
    id: root

    property string token
    property ListModel model: zmMonitorsModel
    property alias count: zmMonitorsModel.count 
    property bool showAlertDialog: true

    signal loaded();
    signal loadingStatus(int status);
    signal monitorStatus(int monitorId, string status);

    ListModel
    {
        id: zmMonitorsModel

        signal loadingStatus(int status);
    }

    JSONListModel
    {
        id: jsonModel
        source: ""
        query: "$.monitors[*]"
        debug: false

        onLoadingStatus:
        {
            if (status == JSONListModel.Ready)
            {
                root.loadingStatus(JSONListModel.Loading);
                zmMonitorsModel.loadingStatus(JSONListModel.Loading);
                root.doLoad();
            }
        }
    }

    function load()
    {
        if (playerSources.zmToken === "")
        {
            log.error(Verbose.MODEL, "ZMMonitorsModel: dont have an API token - Aborting.")
            return
        }

        jsonModel.source = "http://" + settings.zmIP + "/zm/api/monitors.json?token=" + playerSources.zmToken
    }

    function doLoad()
    {
        // copy the monitors list to our ListModel
        for (var x = 0; x < jsonModel.count; x++)
        {
            var monitor = jsonModel.get(x).Monitor;
            var id = monitor.Id;
            var name = monitor.Name;
            var monfunction = monitor.Function;
            var monenabled = monitor.Enabled;
            var path = monitor.Path;
            var device = monitor.Device;
            var channel = monitor.Channel;
            var host = monitor.Host;

            var eventSummary = jsonModel.get(x).Event_Summary;
            var totalevents = eventSummary.TotalEvents == "" ? 0 : eventSummary.TotalEvents;
            var totaleventdiskspace = eventSummary.TotalEventDiskSpace == "" ? 0 : eventSummary.TotalEventDiskSpace;

            var title = monitor.Name;
            var player = "WebBrowser"
            var url = "http://" + settings.zmIP + "/zm/cgi-bin/nph-zms?scale=300&mode=jpeg&maxfps=5&buffer=1000&monitor="
                       + id + "&user=" + settings.zmUserName + "&pass=" + settings.zmPassword;
            var status = "Idle";

            zmMonitorsModel.append({"id": id, "name": name, "monfunction": monfunction, "monenabled": monenabled, "path": path, "device": device,
                                    "channel": channel, "host": host, "totalevents": totalevents, "totaleventdiskspace": totaleventdiskspace,
                                    "title": title, "player": player, "url": url, "status": status})
        }

        updateStatusTimer.running = true;

        root.loaded()
        root.loadingStatus(JSONListModel.Ready)
        zmMonitorsModel.loadingStatus(JSONListModel.Ready)
    }

    Timer
    {
        id: updateStatusTimer
        interval: 1000; running: false;  repeat: true
        onTriggered:
        {
            for (var x = 0; x < zmMonitorsModel.count; x++)
            {
                getAlarmStatus(zmMonitorsModel.get(x).id,
                    function (monitorId, monStatus)
                    {
                        var index = lookupMonitorIndex(monitorId);
                        if (index === -1)
                        {
                            log.error(Verbose.GENERAL, "ZMMonitorsModel: monitor failed to find index for: " + monitorId);
                            return;
                        }

                        if (monStatus !== zmMonitorsModel.get(index).status)
                        {
                            log.debug(Verbose.MODEL, "ZMMonitorsModel: monitor " + zmMonitorsModel.get(index).id + " status changed " + zmMonitorsModel.get(index).status + " -> " + monStatus);
                            zmMonitorsModel.get(index).status = monStatus;

                            if (monStatus === "Alarm" && root.showAlertDialog)
                                window.showZMAlert(monitorId);

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
        return zmMonitorsModel.get(index);
    }

    function lookupMonitorIndex(id)
    {
        for (var x = 0; x < zmMonitorsModel.count; x++)
        {
            if (id == zmMonitorsModel.get(x).id)
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
        var url = "http://" + settings.zmIP + "/zm/api/monitors/alarm/id:" + monitorID + "/command:on.json?token=" + playerSources.zmToken;
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
        var url = "http://" + settings.zmIP + "/zm/api/monitors/alarm/id:" + monitorID + "/command:off.json?token=" + playerSources.zmToken;
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
        var url = "http://" + settings.zmIP + "/zm/api/monitors/alarm/id:" + monitorId + "/command:status.json?token=" + playerSources.zmToken;
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
                        case 0 :
                            result = "Unknown";
                            break;
                        case 1:
                            result = "Idle";
                            break;
                        case 2:
                            result = "Pre Alarm";
                            break;
                        case 3:
                            result = "Alarm";
                            break;
                        case 4:
                            result = "Alert";
                            break;
                        case 5:
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

    function reload()
    {
        load();
    }

    function expandNode(tree, path, node)
    {
        console.log("expandNode ZMCameras: " + path);

        node.expanded  = true

        for (x = 0; x < zmMonitorsModel.count; x++)
        {
            var mon = zmMonitorsModel.get(x);
            node.subNodes.append({"parent": node, "itemTitle": mon.title, "itemData": String(mon.id), "checked": false, "expanded": true, "icon": "", "subNodes": [], type: SourceTreeModel.NodeType.ZoneMinder_Camera,
                                   "url":  mon.url, "player": mon.player
                                 })
        }
    }
}
