import QtQuick.XmlListModel 2.0

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
    XmlRole { name: "AirDate"; query: "xs:date(Airdate)" }

    onStatusChanged:
    {
        if (status == XmlListModel.Ready)
        {
            console.log("Status: " + "Guide - Found " + count + " programs");
        }

        if (status === XmlListModel.Loading)
        {
            console.log("Status: " + "Guide - LOADING - " + source.toString());
        }

        if (status === XmlListModel.Error)
        {
            console.log("Status: " + "Guide - ERROR: " + errorString + "\n" + source.toString());
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

        console.log("ProgramListModel url: " + res.toString());

        source = res;
    }
}
