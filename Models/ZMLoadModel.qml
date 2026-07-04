import QtQuick
import mythqml.net 1.0

JSONModel
{
    id: zmLoadModel

    source: "http://" + settings.zmIP + "/zm/api/host/getLoad.json?token=" + playerSources.zmToken

    debug: false

    property string load1: "?"
    property string load5: "?"
    property string load15: "?"

    onLoaded:
    {
        load1 = jsonObj.load[0];
        load5 = jsonObj.load[1];
        load15 = jsonObj.load[2];
    }

    onStatusChanged:
    {
        if (status == JSONListModel.Ready)
        {
            log.debug(Verbose.MODEL, "ZMLoadModel: READY - " + source);
        }

        if (status === JSONListModel.Loading)
        {
            log.debug(Verbose.MODEL, "ZMLoadModel: LOADING - " + source);
        }

        if (status === JSONListModel.Error)
        {
            log.error(Verbose.MODEL, "ZMLoadModel: ERROR - " + errorString() + " - " + source);
        }
    }
}
