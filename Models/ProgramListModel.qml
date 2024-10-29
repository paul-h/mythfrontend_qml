import QtQml.XmlListModel

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

    XmlListModelRole { name: "StartTime"; elementName: "xs:dateTime(StartTime)"} //FIXME??
    XmlListModelRole { name: "EndTime"; elementName: "xs:dateTime(EndTime)" } //FIXME??
    XmlListModelRole { name: "Title"; elementName: "Title" }
    XmlListModelRole { name: "SubTitle"; elementName: "SubTitle" }
    XmlListModelRole { name: "Description"; elementName: "Description" }
    XmlListModelRole { name: "Category"; elementName: "Category" }
    XmlListModelRole { name: "Season"; elementName: "Season" }
    XmlListModelRole { name: "Episode"; elementName: "Episode" }
    XmlListModelRole { name: "TotalEpisodes"; elementName: "TotalEpisodes" }
    XmlListModelRole { name: "RecordingStatus"; elementName: "Recording/Status" }
    XmlListModelRole { name: "AirDate"; elementName: "Airdate" }

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
