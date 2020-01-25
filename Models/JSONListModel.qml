/* JSONListModel - a QML ListModel with JSON and JSONPath support
 *
 * Copyright (c) 2012 Romain Pokrzywka (KDAB) (romain@kdab.com)
 * Licensed under the MIT licence (http://opensource.org/licenses/mit-license.php)
 */

import QtQuick 2.0
import "jsonpath.js" as JSONPath

Item
{
    property string source: ""
    property string json: ""
    property string query: ""

    property ListModel model : ListModel { id: jsonModel }
    property alias count: jsonModel.count

    signal loaded()

    onSourceChanged:
    {
        doLoad();
    }

    onJsonChanged: updateJSONModel()
    onQueryChanged: updateJSONModel()

    function updateJSONModel()
    {
        jsonModel.clear();

        if ( json === "" )
            return;

        var objectArray = parseJSONString(json, query);
        for ( var key in objectArray )
        {
            var jo = objectArray[key];
            jsonModel.append( jo );
        }

        console.log("sending loaded signal");
        loaded();
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
                if (str.startsWith("("))
                    str = str.substring(1);
                if (str.endsWith(");"))
                    str = str.substring(0, str.length - 2);

                //console.log(str);

                json = str;
            }
        }
        xhr.send();
    }

    function reload()
    {
        //json = "";
        console.log("reload");
        doLoad();
    }
}