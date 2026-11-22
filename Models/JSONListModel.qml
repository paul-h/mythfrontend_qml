/* JSONListModel - a QML ListModel with JSON and JSONPath support
 *
 * Copyright (c) 2012 Romain Pokrzywka (KDAB) (romain@kdab.com)
 * Licensed under the MIT licence (http://opensource.org/licenses/mit-license.php)
 */

import QtQuick 2.0
import mythqml.net 1.0

Item
{
    id: root

    property string source: ""
    property string json: ""
    property string query: ""

    property alias workerSource: workerScript.source
    property var parser: undefined
    property var parserData: undefined

    property ListModel model: jsonModel
    property alias count: jsonModel.count
    property alias dynamicRoles: jsonModel.dynamicRoles

    property int status:  JSONListModel.Null

    property bool debug: false

    signal loaded()
    signal loadingStatus(int status);

    enum Status
    {
        Null,
        Ready,
        Loading,
        Error
    }

    ListModel
    {
        id: jsonModel
    }

    WorkerScript
    {
        id: workerScript
        source: "JSONListModel.mjs"

        onMessage:
        {
            if (messageObject.status === "Ready")
            {
                status = JSONListModel.Ready
                loadingStatus(JSONListModel.Ready);
                loaded();
            }
            else if (messageObject.status === "Loading")
            {
                status = JSONListModel.Loading
                loadingStatus(JSONListModel.Loading);
            }
        }
    }

    onSourceChanged:
    {
        doLoad();
    }

    onJsonChanged: updateJSONModel()
    onQueryChanged: updateJSONModel()

    function defaultParser(json, query, jsonModel, workerScript, parserData)
    {
        var msg = {'json': json, 'query': query, 'jsonModel': jsonModel};

        workerScript.sendMessage(msg);
    }

    function updateJSONModel()
    {
        status = JSONListModel.Loading
        loadingStatus(JSONListModel.Loading);

        jsonModel.clear();

        if ( json === "" )
            return;

        if (debug)
            log.info(Verbose.MODEL,  "JSONListModel: json is: " + json);

        if (parser !== undefined)
        {
            parser(json, query, jsonModel, workerScript, parserData);
        }
        else
        {
            defaultParser(json, query, jsonModel, workerScript, parserData);
        }
    }

    function doLoad()
    {
        var url = source;
        var params= "";
        var splitURL = url.split('?');

        if (splitURL.length > 1)
        {
            url = splitURL[0];
            params = splitURL[1];
        }

        var xhr = new XMLHttpRequest;
        xhr.open("GET", source);

        xhr.setRequestHeader("Accept", "application/json");
        xhr.setRequestHeader("Content-type", "application/x-www-form-urlencoded");
        xhr.setRequestHeader("Content-length", params.length);
        xhr.setRequestHeader("Connection", "close");

        xhr.onreadystatechange = function()
        {
            if (xhr.readyState == XMLHttpRequest.DONE)
            {
                var str = xhr.responseText
                str = str.replace("\n", "").replace("\r", "");
                if (str.startsWith("("))
                    str = str.substring(1);
                if (str.endsWith(");"))
                    str = str.substring(0, str.length - 2);

                // convert null to empty string to stop QT spamming the logs
                str = str.replace(/:null/g, ':""');
                str = str.replace(/: null/g, ':""');

                json = str;
            }
        }
        xhr.send();
    }

    function reload()
    {
        doLoad();
    }

    function get(index)
    {
        return jsonModel.get(index);
    }
}
