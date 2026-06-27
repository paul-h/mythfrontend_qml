/* JSONModel - loads a json file or url and makes the raw json objects available
*  Useful to load simple config or metadata json files
*/

import QtQuick 2.0
import QtQuick.XmlListModel 2.0

Item
{
    id: root

    property string source: ""
    property string json: ""

    property var jsonObj: undefined

    property int status:  XmlListModel.Null

    signal loaded()
    signal loadingStatus(int status);

    onSourceChanged:
    {
        doLoad();
    }

     function doLoad()
    {
        status = XmlListModel.Loading
        loadingStatus(XmlListModel.Loading);

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
                console.log(json);
                jsonObj = JSON.parse(str);

                status = XmlListModel.Ready
                loadingStatus(XmlListModel.Ready);
                loaded();
            }
        }
        xhr.send();
    }

    function reload()
    {
        doLoad();
    }
}
