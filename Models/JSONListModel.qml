/* JSONListModel - a QML ListModel with JSON and JSONPath support
 *
 * Copyright (c) 2012 Romain Pokrzywka (KDAB) (romain@kdab.com)
 * Licensed under the MIT licence (http://opensource.org/licenses/mit-license.php)
 */

import QtQuick
import QtQml.XmlListModel

Item
{
    property string source: ""
    property string json: ""
    property string query: ""

    property alias workerSource: workerScript.source
    property var parser: undefined
    property var parserData: undefined

    property ListModel model: jsonModel
    property alias count: jsonModel.count
    property alias dynamicRoles: jsonModel.dynamicRoles

    property bool debug: false

    signal loaded()

    ListModel
    {
        id: jsonModel

        signal loadingStatus(int status);
    }

    WorkerScript
    {
        id: workerScript
        source: "JSONListModel.mjs"

        onMessage: msg =>
        {
            if (msg.status === "Ready")
            {
                jsonModel.loadingStatus(XmlListModel.Ready);
                loaded();
            }
            else if (msg.status === "Loading")
            {
                jsonModel.loadingStatus(XmlListModel.Loading);
            }
        }
    }

    onSourceChanged:
    {
        doLoad();
    }

    onJsonChanged: updateJSONModel()
    onQueryChanged: updateJSONModel()

    function defaultParser(json, query, jsonModel, workerScript, parserData, debug)
    {
        var msg = {'json': json, 'query': query, 'jsonModel': jsonModel, 'debug': debug};

        workerScript.sendMessage(msg);
    }

    function updateJSONModel()
    {
        jsonModel.loadingStatus(XmlListModel.Loading);

        jsonModel.clear();

        if ( json === "" )
            return;

        if (parser !== undefined)
        {
            parser(json, query, jsonModel, workerScript, parserData, debug);
        }
        else
        {
            defaultParser(json, query, jsonModel, workerScript, parserData, debug);
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
                if (debug)
                    console.log(str);
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
