import QtQuick
import QtQml.XmlListModel

import mythqml.net 1.0

XmlListModel
{
    id: captureCardModel

    source: settings.masterBackend + "Capture/GetCaptureCardList"
    query: "/CaptureCardList/CaptureCards/CaptureCard"

    XmlListModelRole { name: "CardId"; elementName: "CardId" }
    XmlListModelRole { name: "ParentId"; elementName: "Id" }
    XmlListModelRole { name: "HostName"; elementName: "HostName" }
    XmlListModelRole { name: "StartChannel"; elementName: "StartChannel" }
    XmlListModelRole { name: "DisplayName"; elementName: "DisplayName" }
    XmlListModelRole { name: "SourceId"; elementName: "SourceId" }

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
