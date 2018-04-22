import QtQuick 2.0
import QtQuick.XmlListModel 2.0

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
    XmlRole { name: "No"; query: "no/number()" }
    XmlRole { name: "Broadcaster"; query: "broadcaster/string()" }
    XmlRole { name: "Channel"; query: "channel/string()" }
    XmlRole { name: "Description"; query: "description/string()" }
    XmlRole { name: "Genre"; query: "genre/string()" }
    XmlRole { name: "Logo"; query: "logourl/string()" }
    XmlRole { name: "Country"; query: "country/string()" }
    XmlRole { name: "MetaFormat"; query: "metadataformat/string()" }
    XmlRole { name: "Language"; query: "language/string()" }
    XmlRole { name: "Url1"; query: "url1/string()" }
    XmlRole { name: "Url2"; query: "url2/string()" }
    XmlRole { name: "Url3"; query: "url3/string()" }
    XmlRole { name: "Url4"; query: "url4/string()" }
    XmlRole { name: "Url5"; query: "url5/string()" }
    XmlRole { name: "Url6"; query: "url6/string()" }

    signal loaded();

    onStatusChanged:
    {
        if (status == XmlListModel.Ready)
        {
            screenBackground.showBusyIndicator = false

            console.log("Loaded XML: " + streamModel.source.toString());
            //updateLists();
            console.log("Loaded Lists: " + streamModel.source.toString());
            loaded();
        }

        if (status === XmlListModel.Loading)
        {
            screenBackground.showBusyIndicator = true
        }

        if (status === XmlListModel.Error)
        {
            screenBackground.showBusyIndicator = false
            console.log("Error: " + errorString + "\n" + streamModel.source.toString());
        }
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
