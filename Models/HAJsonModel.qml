import QtQuick

import Process 1.0
import mythqml.net 1.0

// SEE: https://developers.home-assistant.io/docs/api/rest/ for docs

Item
{
    id: root

    enabled: true

    signal loaded();

    property string apiBaseURL: settings.haURL
    property string token: settings.haAPIToken

    Component.onCompleted:
    {
        getAPIStatus(statusCallback);
        // getConfig(debugCallback);
        // getCalendars("", "", debugCallback);
        // callService("switch", "turn_on", '{"entity_id": "switch.fan_socket_1"}', debugCallback());
    }

    function apiRequest(method, url, params, needsToken, callback)
    {
        if (!enabled)
            return;

        var http = new XMLHttpRequest();

        http.open(method, url, true);

        if (needsToken)
            http.setRequestHeader("Authorization", "Bearer " + root.token);

        http.setRequestHeader("content-type", "application/json");

        http.onerror = function ()
        {
          log.error(Verbose.MODEL,"HAJsonModel: An error occurred during the transaction - '" + http.statusText + "'");
        };

        http.onreadystatechange = function()
        {
            if (http.readyState == 4)
            {
                if (http.status == 200)
                {
                    var json = JSON.parse(http.responseText)
                    if (typeof(callback === 'function'))
                        callback(json)
                    else
                        log.info(Verbose.MODEL, "HAJsonModel: reply - \n" + JSON.stringify(json, null, 4));
                }
                else
                {
                    log.error(Verbose.MODEL, "HAJsonModel: apiRequest ERROR: got status '" + http.statusText + "' - " + http.responseText)
                    log.error(Verbose.MODEL, "Headers '" + http.getAllResponseHeaders())
                }
            }
        }

        http.send(params);
    }

    function debugCallback(json)
    {
        log.debug(Verbose.MODEL,"haJsonModel: reply - \n" + JSON.stringify(json, null, 4));
    }

    function statusCallback(json)
    {
        if (json === undefined || json.message !== "API running.")
        {
            log.debug(Verbose.MODEL,"getStatus: reply - \n" + JSON.stringify(json, null, 4));

            enabled = false;
            log.debug(Verbose.MODEL,"HAJsonModel: API is not available");
        }
        else
        {
            enabled = true;
            log.debug(Verbose.MODEL,"HAJsonModel: API is available");
        }
    }

    function getAPIStatus(callback)
    {
        apiRequest("GET", apiBaseURL + "api/", "", true, callback);
    }

    function getConfig(callback)
    {
        apiRequest("GET", apiBaseURL + "api/config", "", true, callback);
    }

    function getEvents(callback)
    {
        apiRequest("GET", apiBaseURL + "api/events", "", true, callback);
    }

    function getServices(callback)
    {
        apiRequest("GET", apiBaseURL + "api/services", "", true, callback);
    }

    // Returns an array of state changes in the past. Each object contains further details for the entities.

    // The <timestamp> (YYYY-MM-DDThh:mm:ssTZD) is optional and defaults to 1 day before the time of the request. It determines the beginning of the period.

    // The following parameters are required:

    //    filter_entity_id=<entity_ids> to filter on one or more entities - comma separated.

    //You can pass the following optional GET parameters:

    //    end_time=<timestamp> to choose the end of the period in URL encoded format (defaults to 1 day).
    //    minimal_response to only return last_changed and state for states other than the first and last state (much faster).
    //    no_attributes to skip returning attributes from the database (much faster).
    //    significant_changes_only to only return significant state changes.
    function getHistory(timestamp, params, callback)
    {
        var url = apiBaseURL + "api/history/period";

        if (timestamp !== undefined && timestamp != "")
            url = url + "/" + timestamp;

        apiRequest("GET", url, params, true, callback);
    }

    // Returns an array of logbook entries.

    // The <timestamp> (YYYY-MM-DDThh:mm:ssTZD) is optional and defaults to 1 day before the time of the request. It determines the beginning of the period.

    // You can pass the following optional GET parameters:

    //    entity=<entity_id> to filter on one entity.
    //    end_time=<timestamp> to choose the end of period starting from the <timestamp> in URL encoded format.
    function getLogbook(timestamp, params, callback)
    {
        var url = apiBaseURL + "api/logbook";

        if (timestamp !== undefined && timestamp != "")
            url = url + "/" + timestamp;

        apiRequest("GET", url, params, true, callback);
    }

    function getStates(entityId, callback)
    {
        var url = apiBaseURL + "api/states";

        if (entityId !== undefined && entityId != "")
            url = url + entityId;

        apiRequest("GET", url, "", true, callback);
    }

    function getErrorLog(callback)
    {
        apiRequest("GET", apiBaseURL + "api/error_log", "", true, callback);
    }

    // FIXME: this returns raw image data so wont work as intended
    function getCameraImage(entityId, callback)
    {
        var url = apiBaseURL + "api/camera_proxy";

        if (entityId !== undefined && entityId != "")
            url = url + entityId;

        apiRequest("GET", url, "", true, callback);
    }

    function getCalendars(entityId, params, callback)
    {
        var url = apiBaseURL + "api/calendars";

        if (entityId !== undefined && entityId != "")
            url = url + entityId;

        apiRequest("GET", url, params, true, callback);
    }

    // POST API calls

    // /api/states/<entity_id>
    function setStates(entityId, params, callback)
    {
        var url = apiBaseURL + "api/states";

        if (entityId !== undefined && entityId != "")
            url = url + entityId;

        apiRequest("POST", url, params, true, callback);
    }

    // /api/events/<event_type>
    function setEvents(eventType, callback)
    {
        var url = apiBaseURL + "api/events/";

        if (eventType !== undefined && eventType != "")
            url = url + eventType;

        apiRequest("POST", url, "", true, callback);
    }

    // /api/services/<domain>/<service>
    function callService(domain, service, serviceData, callback)
    {
        var url = apiBaseURL + "api/services/" + domain + "/" + service;

        apiRequest("POST", url, serviceData, true, callback);
    }

    // /api/template
    function getTemplate(params, callback)
    {
        apiRequest("POST", apiBaseURL + "api/template", params, true, callback);
    }

    // /api/config/core/check_config
    function checkConfig(callback)
    {
        apiRequest("POST", apiBaseURL + "api/config/core/check_config", "", true, callback);
    }

    // /api/intent/handle
    function setIntent(params, callback)
    {
        apiRequest("POST", apiBaseURL + "api/intent/handle", params, true, callback);
    }
}
