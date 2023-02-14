/* JSONListModel - a QML ListModel with JSON and JSONPath support
 *
 * Copyright (c) 2012 Romain Pokrzywka (KDAB) (romain@kdab.com)
 * Licensed under the MIT licence (http://opensource.org/licenses/mit-license.php)
 */

import QtQuick 2.0
import QtQuick.XmlListModel 2.0
import "jsonpath.js" as JSONPath

Item
{
    property string source: ""
    property string json: ""
    property string query: ""

    property alias workerSource: workerScript.source
    property var parser: undefined
    property var parserData: undefined

    property ListModel model : jsonModel
    property alias count: jsonModel.count

    signal loaded()

    ListModel
    {
        id: jsonModel

        signal loadingStatus(int status);
    }

    WorkerScript
    {
        id: workerScript
        source: ""

        onMessage:
        {
            if (messageObject.status === "Ready")
            {
                jsonModel.loadingStatus(XmlListModel.Ready);
                loaded();
            }
            else if (messageObject.status === "Loading")
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

    function updateJSONModel()
    {
        jsonModel.loadingStatus(XmlListModel.Loading);

        jsonModel.clear();

        if ( json === "" )
            return;

        var objectArray = parseJSONString(json, query);

        if (parser !== undefined)
        {
            parser(objectArray, jsonModel, workerScript, parserData);
        }
        else
        {
            for ( const key in objectArray )
            {
                var jo = objectArray[key];
                jsonModel.append( jo );
            }

            loaded();

            jsonModel.loadingStatus(XmlListModel.Ready);
        }
    }

    function parseJSONString(jsonString, jsonPathQuery)
    {
        var objectArray = JSON.parse(jsonString);
        if ( jsonPathQuery !== "" )
            objectArray = JSONPath.jsonPath(objectArray, jsonPathQuery);

        return objectArray;
    }

    function doLoad()
    {
        var xhr = new XMLHttpRequest;
        xhr.open("GET", source);
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
