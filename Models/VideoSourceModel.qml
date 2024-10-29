import QtQuick
import QtQml.XmlListModel

import mythqml.net 1.0

XmlListModel
{
    id: videoSourceModel

    property var sourceList: ListModel{}

    source: settings.masterBackend + "Channel/GetVideoSourceList"
    query: "/VideoSourceList/VideoSources/VideoSource"

    XmlListModelRole { name: "Id"; elementName: "Id/number()" }
    XmlListModelRole { name: "SourceName"; elementName: "SourceName/string()" }
    XmlListModelRole { name: "Grabber"; elementName: "Grabber/string()" }
    XmlListModelRole { name: "FreqTable"; elementName: "FreqTable/string()" }
    XmlListModelRole { name: "LineupId"; elementName: "LineupId/string()" }
    XmlListModelRole { name: "Password"; elementName: "Password/string()" }
    XmlListModelRole { name: "UseEIT"; elementName: "xs:boolean(UseEIT)" }
    XmlListModelRole { name: "ConfigPath"; elementName: "ConfigPath/string()" }
    XmlListModelRole { name: "NITId"; elementName: "NITId/number()" }

    onStatusChanged:
    {
        if (status == XmlListModel.Ready)
        {
            log.debug(Verbose.MODEL, "VideoSourceModel: READY - Found " + count + " video sources");
            updateLists();
        }

        if (status === XmlListModel.Loading)
        {
            log.debug(Verbose.MODEL, "VideoSourceModel: LOADING - " + source);
        }

        if (status === XmlListModel.Error)
        {
            log.error(Verbose.MODEL, "VideoSourceModel: ERROR: " + errorString() + " - " + source);
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

    function findByName(Name)
    {
        for (var x = 0; x < count; x++)
        {
            if (get(x).SourceName == Name)
                return x;
        }

        return -1;
    }

    function updateLists()
    {
        var sourceName;
        var sources = [];

        sourceList.clear();

        for (var x = 0; x < count; x++)
        {
            sourceName = get(x).SourceName;

            if (sources.indexOf(sourceName) < 0)
                    sources.push(sourceName);
        }

        sources.sort();
        sourceList.append({"item": "<All Sources>"});

        for (var x = 0; x < sources.length; x++)
            sourceList.append({"item": sources[x]});
    }

    function get(i)
    {
        var o = {}
        for (var j = 0; j < roles.length; ++j)
        {
            o[roles[j].name] = data(index(i,0), Qt.UserRole + j)
        }
        return o
    }
}
