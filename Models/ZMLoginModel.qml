import QtQuick

import mythqml.net 1.0

Item
{
    id: root

    signal loaded();

    property string ip: settings.zmIP
    property string user: settings.zmUserName
    property string password: settings.zmPassword
    property string token: ""

    property var json: undefined

    Component.onCompleted:
    {
        getToken();
    }

    function getToken()
    {
        var http = new XMLHttpRequest();
        var url = "http://" + ip + "/zm/api/host/login.json";
        var params = "user=" + user + "&pass=" + password;

        http.withCredentials = true;
        http.open("POST", url, true);
        http.setRequestHeader("Content-type", "application/x-www-form-urlencoded");

        http.onerror = function ()
        {
            log.error(Verbose.MODEL,"ZMJsonModel: An error occurred during the transaction '" + http.statusText + "'");
        };

        http.onreadystatechange = function()
        {
            log.debug(Verbose.MODEL, "ZMLoginModel ready state is: " + http.readyState + ", http.status is: " + http.status)
            if (http.readyState == 4)
            {
                if (http.status == 200)
                {
                    var json = JSON.parse(http.responseText)
                    root.json = json
                    root.token = json.access_token
                    log.debug(Verbose.MODEL, "ZMJsonModel getToken: token is: " + json.access_token)

                    loaded();
                }
                else
                {
                    log.error(Verbose.MODEL, "ZMJsonModel.getToken: ERROR: got status '" + http.statusText + "' - " + http.responseText)
                    log.error(Verbose.MODEL, "Headers '" + http.getAllResponseHeaders())
                }
            }
        }

        http.send(params);
    }
}
