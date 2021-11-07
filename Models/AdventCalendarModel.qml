import QtQuick 2.0
import QtQuick.XmlListModel 2.0
import mythqml.net 1.0

Item
{
    id: root

    property var calendarList: adventCalendarsModel
    property int calendarIndex: 3
    property var model: listModel

    signal loaded();

    onCalendarIndexChanged:
    {
        // sanity check index
        if (calendarIndex >= 0 && calendarIndex < adventCalendarsModel.count)
            calendarModel.source = adventCalendarsModel.get(calendarIndex).url + "&v=" + version + "&s=" + systemid
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
        XmlRole { name: "id"; query: "id/number()" }
        XmlRole { name: "title"; query: "title/string()" }
        XmlRole { name: "description"; query: "description/string()" }
        XmlRole { name: "url"; query: "url/string()" }

        onStatusChanged:
        {
            if (status == XmlListModel.Ready)
            {
                log.debug(Verbose.MODEL, "AdventCalendarsModel: READY - Found " + count + " advent calendars");
                loaded();

                calendarModel.source = adventCalendarsModel.get(root.calendarIndex).url + "&v=" + version + "&s=" + systemid
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
    }

    XmlListModel
    {
        id: calendarModel

        query: "/advent/item"
        XmlRole { name: "day"; query: "day/number()" }
        XmlRole { name: "title"; query: "title/string()" }
        XmlRole { name: "icon"; query: "icon/string()" }
        XmlRole { name: "url"; query: "url/string()" }
        XmlRole { name: "player"; query: "player/string()" }
        XmlRole { name: "duration"; query: "duration/string()" }

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
    }
}
