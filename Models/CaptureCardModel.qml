import QtQuick 2.0
import QtQuick.XmlListModel 2.0
import mythqml.net 1.0

XmlListModel
{
    id: captureCardModel

    source: settings.masterBackend + "Capture/GetCaptureCardList"
    query: "/CaptureCardList/CaptureCards/CaptureCard"

    XmlRole { name: "CardId"; query: "CardId/string()" }
    XmlRole { name: "ParentId"; query: "Id/number()" }
    XmlRole { name: "HostName"; query: "HostName/string()" }
    XmlRole { name: "StartChannel"; query: "StartChanel/number()" }
    XmlRole { name: "DisplayName"; query: "DisplayName/string()" }
    XmlRole { name: "SourceId"; query: "SourceId/string()" }

    onStatusChanged:
    {
        if (status == XmlListModel.Ready)
        {
            log.debug(Verbose.MODEL, "CaptureCardModel: READY Found " + count + " capture cards");
        }

        if (status === XmlListModel.Loading)
        {
            log.debug(Verbose.MODEL, "CaptureCardModel: LOADING - " + captureCardModel.source);
        }

        if (status === XmlListModel.Error)
        {
            log.debug(Verbose.MODEL, "CaptureCardModel: ERROR: " + errorString() + " - " + captureCardModel.source);
        }
    }
}
