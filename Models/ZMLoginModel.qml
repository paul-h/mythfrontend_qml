import QtQuick 2.0
import QtQuick.XmlListModel 2.0
import mythqml.net 1.0

XmlListModel
{
    id: zmLoginModel

    property string ip: settings.zmIP
    property string user: settings.zmUserName
    property string password: settings.zmPassword

    signal loaded();

    query: "/response"
    XmlRole { name: "credentials"; query: "credentials/string()" }
    XmlRole { name: "append_password"; query: "append_password/string()" }
    XmlRole { name: "version"; query: "version/string()" }
    XmlRole { name: "apiversion"; query: "apiversion/string()" }
    XmlRole { name: "access_token"; query: "access_token/string()" }

    onStatusChanged:
    {
        if (status == XmlListModel.Ready)
        {
            log.debug(Verbose.MODEL, "ZMLoginModel: READY - Found " + count + " login responses");
            loaded();
        }

        if (status === XmlListModel.Loading)
        {
            log.debug(Verbose.MODEL, "ZMLoginModel: LOADING - " + source);
        }

        if (status === XmlListModel.Error)
        {
            log.error(Verbose.MODEL, "ZMLoginModel: ERROR: " + errorString() + " - " + source);
        }
    }

    function getLogin()
    {
        var http = new XMLHttpRequest();
        var url = "http://" + ip + "/zm/api/host/login.xml";
        var params = "user=" + user + "&pass=" + password;

        http.withCredentials = true;
        http.open("POST", url, true);
        http.setRequestHeader("Content-type", "application/x-www-form-urlencoded");

        http.onreadystatechange = function()
        {
            if (http.readyState == 4)
            {
                if (http.status == 200)
                {
                    xml = http.responseText
                }
                else
                {
                    log.error(Verbose.MODEL, "ZMLoginModel: ERROR: getLogin() got status " + http.statusText);
                    log.error(Verbose.MODEL, "ZMLoginModel: ERROR: getLogin() got response '" + http.responseText + "'")
                }
            }
        }
        http.send(params);
    }
}
