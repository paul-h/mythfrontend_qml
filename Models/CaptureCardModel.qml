import QtQuick 2.0
import QtQuick.XmlListModel 2.0

XmlListModel
{
    id: captureCardModel

    source: settings.masterBackend + "Capture/GetCaptureCardList"
    query: "/CaptureCardList/CaptureCards/CaptureCard"

    XmlRole { name: "CardId"; query: "CardId/string()" }
    XmlRole { name: "HostName"; query: "HostName/string()" }
    XmlRole { name: "StartChannel"; query: "StartChanel/number()" }
    XmlRole { name: "DisplayName"; query: "DisplayName/string()" }
    XmlRole { name: "SourceId"; query: "SourceId/string()" }

    onStatusChanged:
    {
        if (status == XmlListModel.Ready)
        {
            console.info("Status: " + "CaptureCards - Found " + count + " capture cards");
        }

        if (status === XmlListModel.Loading)
        {
            console.info("Status: " + "CaptureCards - LOADING - " + captureCardModel.source.toString());
        }

        if (status === XmlListModel.Error)
        {
            console.info("Status: " + "CaptureCards - ERROR: " + errorString + "\n" + captureCardModel.source.toString());
        }
    }
}
