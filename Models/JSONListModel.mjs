import { jsonPath, parseJSONString } from "jsonpath.mjs"

WorkerScript.onMessage = function(msg)
{
    WorkerScript.sendMessage({model: "JSONListModel", status: "Loading"});

    var json = msg.json;
    var query = msg.query;
    var jsonModel = msg.jsonModel;
    var debug = msg.debug

    if (debug)
        console.log(json);

    var objectArray = parseJSONString(json, query);

    jsonModel.clear();

    for( const key in objectArray)
    {
        var jo = objectArray[key];
        jsonModel.append( jo );

        if (debug)
            console.log("key: " + key + ", object: " + jo);
    }

    jsonModel.sync();

    WorkerScript.sendMessage({model: "JSONListModel", status: "Ready"});
}
