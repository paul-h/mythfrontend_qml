import QtQuick 2.0

import mythqml.net 1.0

JSONModel
{
    id: zmDaemonCheckModel

    source: "http://" + settings.zmIP + "/zm/api/host/daemonCheck.json?token=" + playerSources.zmToken
    debug: false

    property bool running: if (count) get(0).running; else false

    onLoaded: running = jsonObj.result

    onStatusChanged:
    {
        if (status == JSONListModel.Ready)
        {
            log.debug(Verbose.MODEL, "ZMDaemonCheckModel: READY - " + source);
        }

        if (status === JSONListModel.Loading)
        {
            log.debug(Verbose.MODEL, "ZMDaemonCheckModel: LOADING - " + source);
        }

        if (status === JSONListModel.Error)
        {
            log.error(Verbose.MODEL, "ZMDaemonCheckModel: ERROR - " + errorString() + " - " + source);
        }
    }
}
