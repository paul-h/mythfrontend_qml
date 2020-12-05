import QtQuick.XmlListModel 2.0
import mythqml.net 1.0

XmlListModel
{
    id: programListModel

    property int    getCount: -1
    property string startTime: ""
    property string endTime: ""
    property int    chanId: -1
    property string titleFilter: ""
    property string categoryFilter: ""
    property string personFilter: ""
    property string keywordFilter: ""
    property bool   onlyNew: false
    property bool   details: true
    property string sort: ""
    property bool   decending: false

    query: "/ProgramList/Programs/Program"

    XmlRole { name: "StartTime"; query: "xs:dateTime(StartTime)"}
    XmlRole { name: "EndTime"; query: "xs:dateTime(EndTime)" }
    XmlRole { name: "Title"; query: "Title/string()" }
    XmlRole { name: "SubTitle"; query: "SubTitle/string()" }
    XmlRole { name: "Description"; query: "Description/string()" }
    XmlRole { name: "Category"; query: "Category/string()" }
    XmlRole { name: "Season"; query: "Season/string()" }
    XmlRole { name: "Episode"; query: "Episode/string()" }
    XmlRole { name: "TotalEpisodes"; query: "TotalEpisodes/string()" }
    XmlRole { name: "RecordingStatus"; query: "Recording/Status/string()" }
    XmlRole { name: "AirDate"; query: "Airdate/string()" }

    onStatusChanged:
    {
        if (status == XmlListModel.Ready)
        {
            log.debug(Verbose.MODEL, "ProgramListModel: READY - Found " + count + " programs");
        }

        if (status === XmlListModel.Loading)
        {
            log.debug(Verbose.MODEL, "ProgramListModel: LOADING - " + source);
        }

        if (status === XmlListModel.Error)
        {
            log.error(Verbose.MODEL,  "ProgramListModel: ERROR - " + errorString() + " - " + source);
        }
    }

    function load()
    {
        var res = settings.masterBackend + "Guide/GetProgramList?";

        if (getCount != -1)
            res += "&count=" + getCount;

        if (startTime != "")
            res += "StartTime=" + startTime;

        if (endTime != "")
            res += "&EndTime=" + endTime;

        if (chanId != -1)
            res += "&ChanId=" + chanId;

        if (titleFilter != "")
            res += "TitleFilter=" + titleFilter;

        if (categoryFilter != "")
            res += "CategoryFilter=" + categoryFilter;

        if (personFilter != "")
            res += "PersonFilter=" + personFilter;

        if (keywordFilter != "")
           res += "keywordFilter=" + keywordFilter;

        if (onlyNew)
            res += "&OnlyNew=" + (onlyNew ? "true" : "false");

        if (details)
            res += "&Details=" + (details ? "true" : "false");

        if (decending)
            res += "&Descending=" + (decending ? "true" : "false");

        if (sort != "")
           res += "Sort=" + sort;

        log.debug(Verbose.MODEL, "ProgramListModel: url - " + res);

        source = res;
    }
}
