import QtQuick 2.0
import QtQuick.XmlListModel 2.0
import mythqml.net 1.0

XmlListModel
{
    id: videoSourceModel

    source: settings.masterBackend + "Channel/GetVideoSourceList"
    query: "/VideoSourceList/VideoSources/VideoSource"

    XmlRole { name: "Id"; query: "Id/number()" }
    XmlRole { name: "SourceName"; query: "SourceName/string()" }
    XmlRole { name: "Grabber"; query: "Grabber/string()" }
    XmlRole { name: "FreqTable"; query: "FreqTable/string()" }
    XmlRole { name: "LineupId"; query: "LineupId/string()" }
    XmlRole { name: "Password"; query: "Password/string()" }
    XmlRole { name: "UseEIT"; query: "xs:boolean(UseEIT)" }
    XmlRole { name: "ConfigPath"; query: "ConfigPath/string()" }
    XmlRole { name: "NITId"; query: "NITId/number()" }

    onStatusChanged:
    {
        if (status == XmlListModel.Ready)
        {
            log.debug(Verbose.MODEL, "VideoSourceModel: READY - Found " + count + " video sources");
        }

        if (status === XmlListModel.Loading)
        {
            log.debug(Verbose.MODEL, "VideoSourceModel: LOADING - " + source.toString());
        }

        if (status === XmlListModel.Error)
        {
            log.error(Verbose.MODEL, "VideoSourceModel: ERROR: " + errorString() + " - " + source.toString());
        }
    }

    function findById(Id)
    {
        for (var x = 0; x < count; x++)
        {
            if (get(x).Id == Id)
                return x;
        }

        return -1;
    }
}
