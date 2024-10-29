import QtQuick
import QtQml.XmlListModel

import mythqml.net 1.0

XmlListModel
{
    id: streamModel

    property var broadcasterList: ListModel{}
    property var channelList: ListModel{}
    property var languageList: ListModel{}
    property var countryList: ListModel{}
    property var genreList: ListModel{}

    source: "file:///home/paul/RadioStreamValidator/spiders/streams_new.xml"
    query: "/streams/item"
    XmlListModelRole { name: "No"; elementName: "no" } // number
    XmlListModelRole { name: "Broadcaster"; elementName: "broadcaster" }
    XmlListModelRole { name: "Channel"; elementName: "channel" }
    XmlListModelRole { name: "Description"; elementName: "description" }
    XmlListModelRole { name: "Genre"; elementName: "genre" }
    XmlListModelRole { name: "Logo"; elementName: "logourl" }
    XmlListModelRole { name: "Country"; elementName: "country" }
    XmlListModelRole { name: "MetaFormat"; elementName: "metadataformat" }
    XmlListModelRole { name: "Language"; elementName: "language" }
    XmlListModelRole { name: "Url1"; elementName: "url1" }
    XmlListModelRole { name: "Url2"; elementName: "url2" }
    XmlListModelRole { name: "Url3"; elementName: "url3" }
    XmlListModelRole { name: "Url4"; elementName: "url4" }
    XmlListModelRole { name: "Url5"; elementName: "url5" }
    XmlListModelRole { name: "Url6"; elementName: "url6" }

    signal loaded();

    onStatusChanged:
    {
        if (status == XmlListModel.Ready)
        {
            log.debug(Verbose.MODEL, "RadioStreamModel: READY - found " + count + " radio streams");
            //updateLists();
            loaded();
            screenBackground.showBusyIndicator = false
        }

        if (status === XmlListModel.Loading)
        {
            log.debug(Verbose.MODEL, "RadioStreamModel:- LOADING" + source);
            screenBackground.showBusyIndicator = true
        }

        if (status === XmlListModel.Error)
        {
            screenBackground.showBusyIndicator = false
            log.debug(Verbose.MODEL, "RadioStreamModel: ERROR - " + errorString() + " - " + source);
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

    function updateLists()
    {
        var broadcaster;
        var channel;
        var genre;
        var country;
        var language;

        var broadcasters = [];
        var channels = [];
        var genres = [];
        var countries = [];
        var languages = [];

        broadcasterList.clear();
        channelList.clear();
        genreList.clear();
        countryList.clear();
        languageList.clear();

        for (var x = 0; x < count; x++)
        {
            broadcaster = get(x).Broadcaster;
            channel = get(x).Channel;
            genre = get(x).Genre
            country = get(x).Country;
            language = get(x).Langauge;

            if (broadcasters.indexOf(broadcaster) < 0)
                broadcasters.push(broadcaster);

            if (channels.indexOf(channel) < 0)
                channels.push(channel);

            if (genres.indexOf(genre) < 0)
                genres.push(genre);

            if (countries.indexOf(country) < 0)
                countries.push(country);

            if (languages.indexOf(language) < 0)
                languages.push(language);
        }

        broadcasters.sort();
        channels.sort();
        genres.sort();
        countries.sort();
        languages.sort();

        for (var x = 0; x < broadcasters.length; x++)
            broadcasterList.append({"item": broadcasters[x]});

        for (var x = 0; x < channels.length; x++)
            channelList.append({"item": channels[x]});

        for (var x = 0; x < genres.length; x++)
            genreList.append({"item": genres[x]});

        for (var x = 0; x < countries.length; x++)
            countryList.append({"item": countries[x]});

        for (var x = 0; x < languages.length; x++)
            languageList.append({"item": languages[x]});
    }
}
