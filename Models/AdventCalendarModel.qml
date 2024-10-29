import QtQuick
import QtQml.XmlListModel

import mythqml.net 1.0

Item
{
    id: root

    property var calendarList: adventCalendarsModel
    property int calendarIndex: dbUtils.getSetting("AdventIndex", settings.hostName, "0");
    property var model: listModel

    signal loaded();

    onCalendarIndexChanged:
    {
        // sanity check index
        if (calendarIndex >= 0 && calendarIndex < adventCalendarsModel.count)
        {
            if (!adventCalendarsModel.get(calendarIndex).url.startsWith("file://"))
                calendarModel.source = adventCalendarsModel.get(calendarIndex).url + "&v=" + version + "&s=" + systemid;
            else
                calendarModel.source = adventCalendarsModel.get(calendarIndex).url;
        }
    }

    ListModel
    {
        id: listModel
    }

    XmlListModel
    {
        id: adventCalendarsModel

        signal loaded();

        source: "https://mythqml.net/download.php?f=advent_calendars.xml&v=" + version + "&s=" + systemid

        query: "/items/item"
        XmlListModelRole { name: "id"; elementName: "id" }
        XmlListModelRole { name: "status"; elementName: "title" }
        XmlListModelRole { name: "dateadded"; elementName: "dateadded" }
        XmlListModelRole { name: "title"; elementName: "title" }
        XmlListModelRole { name: "description"; elementName: "description" }
        XmlListModelRole { name: "url"; elementName: "url" }

        onStatusChanged:
        {
            if (status == XmlListModel.Ready)
            {
                log.debug(Verbose.MODEL, "AdventCalendarsModel: READY - Found " + count + " advent calendars");
                loaded();

                if (!adventCalendarsModel.get(calendarIndex).url.startsWith("file://"))
                    calendarModel.source = adventCalendarsModel.get(calendarIndex).url + "&v=" + version + "&s=" + systemid;
                else
                    calendarModel.source = adventCalendarsModel.get(calendarIndex).url;
            }

            if (status === XmlListModel.Loading)
            {
                log.debug(Verbose.MODEL, "AdventCalendarsModel: LOADING - " + source);
            }

            if (status === XmlListModel.Error)
            {
                log.error(Verbose.MODEL, "AdventCalendarsModel: ERROR: " + errorString() + " - " + source);
            }
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

    XmlListModel
    {
        id: calendarModel

        query: "/advent/item"
        XmlListModelRole { name: "day"; elementName: "day" }
        XmlListModelRole { name: "title"; elementName: "title" }
        XmlListModelRole { name: "icon"; elementName: "icon" }
        XmlListModelRole { name: "url"; elementName: "url" }
        XmlListModelRole { name: "player"; elementName: "player" }
        XmlListModelRole { name: "duration"; elementName: "duration" }

        onStatusChanged:
        {
            if (status == XmlListModel.Ready)
            {
                log.debug(Verbose.MODEL, "CalendarModel: READY - Found " + count + " days");
                doLoad();
            }

            if (status === XmlListModel.Loading)
            {
                log.debug(Verbose.MODEL, "CalendarModel: LOADING - " + source.toString());
            }

            if (status === XmlListModel.Error)
            {
                log.error(Verbose.MODEL, "CalendarModel: ERROR: " + errorString() + " - " + source.toString());
            }
        }

        // copy the XmlListModel model to our ListModel so we can modify it
        function doLoad()
        {
            listModel.clear();

            for (var x = 0; x < count; x++)
            {
                // use the VLC player by default
                var player = get(x).player === "Internal" ? "VLC" : get(x).player;
                listModel.append({"day": get(x).day, "title": get(x).title, "icon": get(x).icon, "url": get(x).url, "player": player, "duration": get(x).duration, "opened": false});
            }

            // send loaded signal
            loaded();
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

    function findIndexFromCalendarId(id)
    {
        for (var x = 0; x < adventCalendarsModel.count; x++)
        {
            if (adventCalendarsModel.get(x).id === id)
                return x;
        }

        return 0;
    }
}
