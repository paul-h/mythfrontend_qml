import QtQuick
import QtQml.XmlListModel

import mythqml.net 1.0
import FileIO 1.0

Item
{
    id: root

    property string ip: settings.zmIP
    property string user: settings.zmUserName
    property string password: settings.zmPassword

    signal loaded();

    FileIO
    {
        id: loginFile
        source: settings.configPath + "zmLogin.xml"
        onError: console.log(msg)
    }

    XmlListModel
    {
        id: zmLoginModel

        query: "/response"
        XmlListModelRole { name: "credentials"; elementName: "credentials" }
        XmlListModelRole { name: "append_password"; elementName: "append_password" }
        XmlListModelRole { name: "version"; elementName: "version" }
        XmlListModelRole { name: "apiversion"; elementName: "apiversion" }
        XmlListModelRole { name: "access_token"; elementName: "access_token" }

        onStatusChanged:
        {
            if (status == XmlListModel.Ready)
            {
                log.debug(Verbose.MODEL, "ZMLoginModel: READY - Found " + count + " login responses");
                root.loaded();
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
                    loginFile.write(http.responseText);
                    zmLoginModel.source = loginFile.source;
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

    function get(i)
    {
        var o = {}
        for (var j = 0; j <  zmLoginModel.roles.length; ++j)
        {
            o[zmLoginModel.roles[j].name] = zmLoginModel.data(zmLoginModel.index(i, 0), Qt.UserRole + j)
        }
        return o
    }
}
