import QtQuick 2.0
import QtQuick.XmlListModel 2.0
import mythqml.net 1.0
import SortFilterProxyModel 0.2

Item
{
    id: root

    property alias model: channelModel.model

    property JSONListModel channelModel: channelModel
    property JSONListModel languageModel: languageModel
    property JSONListModel countryModel: countryModel
    property JSONListModel categoryModel: categoryModel
    property JSONListModel streamModel: streamModel

    property var genreList: ListModel{}
    property var countryList: ListModel{}
    property var languageList: ListModel{}

    signal loaded();

    property list<QtObject> iptvFilter:
    [
        AllOf
        {
            RegExpFilter
            {
                id: iptvCountry
                roleName: "countries"
                pattern: ""
                caseSensitivity: Qt.CaseInsensitive
            }
            RegExpFilter
            {
                id: iptvLanguage
                roleName: "languages"
                pattern: ""
                caseSensitivity: Qt.CaseInsensitive
            }
            RegExpFilter
            {
                id: iptvGenre
                roleName: "genre"
                pattern: ""
                caseSensitivity: Qt.CaseInsensitive
            }
        }
    ]

    property list<QtObject> titleSorter:
    [
        RoleSorter { roleName: "title"; ascendingOrder: true}
    ]

    property list<QtObject> idSorter:
    [
        RoleSorter { roleName: "id"; ascendingOrder: true}
    ]

    property list<QtObject> countrySorter:
    [
        RoleSorter { roleName: "countries"; ascendingOrder: true},
        RoleSorter { roleName: "title" }
    ]

    property list<QtObject> languageSorter:
    [
        RoleSorter { roleName: "languages"; ascendingOrder: true},
        RoleSorter { roleName: "title" }
    ]

    property list<QtObject> genreSorter:
    [
        RoleSorter { roleName: "genre"; ascendingOrder: true},
        RoleSorter { roleName: "title" }
    ]

    SortFilterProxyModel
    {
        id: proxyModel
        filters: iptvFilter
        sorters: titleSorter
    }

    JSONListModel
    {
        id: categoryModel

        source: "https://iptv-org.github.io/api/categories.json"
        onLoaded: loadChannels()
    }

    JSONListModel
    {
        id: languageModel

        source: "https://iptv-org.github.io/api/languages.json"
        onLoaded: loadChannels()
    }

    JSONListModel
    {
        id: countryModel

        source: "https://iptv-org.github.io/api/countries.json"
        onLoaded: loadChannels()
    }

    JSONListModel
    {
        id: streamModel

        source: "https://iptv-org.github.io/api/streams.json"
        onLoaded: loadChannels()
    }

    JSONListModel
    {
        id: guideModel
        source: "https://iptv-org.github.io/api/guides.json"
        onLoaded: loadChannels()
    }

    JSONListModel
    {
        id: logoModel
        source: "https://iptv-org.github.io/api/logos.json"
        onLoaded: loadChannels()
    }

    JSONListModel
    {
        id: channelModel

        property alias genreList: root.genreList;
        property alias countryList: root.countryList
        property alias languageList: root.languageList

        workerSource: "IPTVModel.mjs"
        parser: myparser
        parserData: root

        function myparser(json, query, jsonModel, workerScript, parserData)
        {
            // tell the WorkerScript to run the parser
            var models = {'countryModel': countryModel.model, 'languageModel': languageModel.model, 'streamModel': streamModel.model, 'categoryModel': categoryModel.model, 'guideModel': guideModel.model, 'logoModel': logoModel.model};
            var lists = {'categoryList': root.genreList, 'countryList': root.countryList, 'languageList': root.languageList};
            var msg = {'json': json, 'query': query, 'jsonModel': jsonModel, 'models': models, 'lists': lists};

            workerScript.sendMessage(msg);
        }
    }

    function loadChannels()
    {
        // only load the channels when we have all the other data loaded
        //if (categoryModel.count > 0 && countryModel.count > 0 && languageModel.count > 0 && streamModel.count > 0 && logoModel.count > 0 && guideModel.count > 0)
        //    channelModel.source = "https://iptv-org.github.io/api/channels.json"
        if (categoryModel.count > 0 && countryModel.count > 0 && languageModel.count > 0 && streamModel.count > 0 && logoModel.count > 0)
            channelModel.source = "https://iptv-org.github.io/api/channels.json"
    }

    function expandNode(tree, path, node)
    {
        var chan;
        var x;
        var sort = "Title";
        var genre = "";
        var language = "";
        var country = "";

        var fNode = node;

        while (fNode && fNode.parent !== null)
        {
            if (fNode.type === SourceTreeModel.NodeType.IPTV_Filter_Country)
                country = fNode.itemTitle;
            else if (fNode.type === SourceTreeModel.NodeType.IPTV_Filter_Genre)
                genre = fNode.itemTitle;
            else if (fNode.type === SourceTreeModel.NodeType.IPTV_Filter_Language)
                language = fNode.itemTitle;

            fNode = fNode.parent;
        }

        node.expanded  = true

        if (node.type === SourceTreeModel.NodeType.Root_Title)
        {
            node.subNodes.append({"parent": node, "itemTitle": "<All IPTV Channels>", "itemData": "AllChannels", "checked": false, "expanded": false, "icon": "", "subNodes": [], type: SourceTreeModel.NodeType.IPTV_Filters})
            node.subNodes.append({"parent": node, "itemTitle": "Genres", "itemData": "Genres", "checked": false, "expanded": false, "icon": "", "subNodes": [], type: SourceTreeModel.NodeType.IPTV_Filters})
            node.subNodes.append({"parent": node, "itemTitle": "Countries", "itemData": "Countries", "checked": false, "expanded": false, "icon": "", "subNodes": [], type: SourceTreeModel.NodeType.IPTV_Filters})
            node.subNodes.append({"parent": node, "itemTitle": "Languages", "itemData": "Languages", "checked": false, "expanded": false, "icon": "", "subNodes": [], type: SourceTreeModel.NodeType.IPTV_Filters})
        }
        else if (node.type === SourceTreeModel.NodeType.IPTV_Filters)
        {
            if (node.itemData === "AllChannels")
            {
                for (x = 0; x < channelModel.model.count; x++)
                {
                    chan = channelModel.model.get(x);
                    node.subNodes.append({
                                             "parent": node, "itemTitle": chan.title, "itemData": String(chan.id), "checked": false, "expanded": true, "icon": getIconURL(chan.icon), "subNodes": [], type: SourceTreeModel.NodeType.IPTV_Channel,
                                             "player": "Internal", "url": chan.url, "genre": chan.genre, "countries": chan.countries, "languages": chan.languages, "xmltvid": chan.xmltvid, "xmltvurl": chan.xmltvurl
                                         })
                }
            }
            else if (node.itemData === "Countries")
            {
                if (genre === "" && country === "" && language === "")
                {
                    // get the full list of countries
                    for (x = 0; x < countryList.count; x++)
                    {
                        node.subNodes.append({"parent": node, "itemTitle": countryList.get(x).item, "itemData": countryList.get(x).item, "checked": false, "expanded": false, "icon": "", "subNodes": [], type: SourceTreeModel.NodeType.IPTV_Filter_Country})
                    }
                }
                else
                {
                    // get a filtered list of countries
                    var countries = [];

                    for (x = 0; x < node.parent.subNodes.get(0).subNodes.count; x++)
                    {
                        var splitCountries = node.parent.subNodes.get(0).subNodes.get(x).countries.split(",");
                        for (var y = 0; y < splitCountries.length; y++)
                        {
                            country = splitCountries[y].trim();

                            if (countries.indexOf(country) < 0)
                                countries.push(country);
                        }
                    }

                    countries.sort();

                    for (x = 0; x < countries.length; x++)
                    {
                        node.subNodes.append({"parent": node, "itemTitle": countries[x], "itemData": countries[x], "checked": false, "expanded": false, "icon": "", "subNodes": [], type: SourceTreeModel.NodeType.IPTV_Filter_Country})
                    }
                }
            }
            else if (node.itemData === "Genres")
            {
                if (genre === "" && country === "" && language === "")
                {
                    // get the full list of genres
                    for (x = 0; x < genreList.count; x++)
                    {
                        node.subNodes.append({"parent": node, "itemTitle": genreList.get(x).item, "itemData": genreList.get(x).item, "checked": false, "expanded": false, "icon": "", "subNodes": [], type: SourceTreeModel.NodeType.IPTV_Filter_Genre})
                    }
                }
                else
                {
                    // get a filtered list of countries
                    var genres = [];

                    for (x = 0; x < node.parent.subNodes.get(0).subNodes.count; x++)
                    {
                        var splitGenres = node.parent.subNodes.get(0).subNodes.get(x).genres.split(",");
                        for (var y = 0; y < splitGenres.length; y++)
                        {
                            genre = splitGenres[y].trim();

                            if (genres.indexOf(genre) < 0)
                                genres.push(genre);
                        }
                    }

                    genres.sort();

                    for (x = 0; x < genres.length; x++)
                    {
                        node.subNodes.append({"parent": node, "itemTitle": genres[x], "itemData": countries[x], "checked": false, "expanded": false, "icon": "", "subNodes": [], type: SourceTreeModel.NodeType.IPTV_Filter_Genre})
                    }
                }
            }
            else if (node.itemData === "Languages")
            {
                if (genre === "" && country === "" && language === "")
                {
                    // get the full list of languages
                    for (x = 0; x < languageList.count; x++)
                    {
                        node.subNodes.append({"parent": node, "itemTitle": languageList.get(x).item, "itemData": languageList.get(x).item, "checked": false, "expanded": false, "icon": "", "subNodes": [], type: SourceTreeModel.NodeType.IPTV_Filter_Language})
                    }
                }
                else
                {
                    // get a filtered list of languages
                    var languages = [];

                    for (x = 0; x < node.parent.subNodes.get(0).subNodes.count; x++)
                    {
                        var splitLanguages = node.parent.subNodes.get(0).subNodes.get(x).languages.split(",");
                        for (var y = 0; y < splitLanguages.length; y++)
                        {
                            language = splitLanguages[y].trim();

                            if (languages.indexOf(language) < 0)
                                languages.push(language);
                        }
                    }

                    languages.sort();

                    for (x = 0; x < languages.length; x++)
                    {
                        node.subNodes.append({"parent": node, "itemTitle": languages[x], "itemData": languages[x], "checked": false, "expanded": false, "icon": "", "subNodes": [], type: SourceTreeModel.NodeType.IPTV_Filter_Language})
                    }
                }
            }
        }
        else if (node.type === SourceTreeModel.NodeType.IPTV_Filter_Genre || node.type === SourceTreeModel.NodeType.IPTV_Filter_Country || node.type === SourceTreeModel.NodeType.IPTV_Filter_Language || node.type === SourceTreeModel.NodeType.IPTV_Filter_All)
        {
            proxyModel.sourceModel =  channelModel.model;


            if (sort === "Title")
                proxyModel.sorters = titleSorter;
            else if (sort === "Genre")
                proxyModel.sorters = genreSorter;
            else if (sort === "Country")
                proxyModel.sorters = countrySorter;
            else if (sort === "Language")
                proxyModel.sorters = languageSorter;
            else
                proxyModel.sorters = idSorter;

            iptvGenre.pattern = genre;
            iptvCountry.pattern = country;
            iptvLanguage.pattern = language;

            if (node.type !== SourceTreeModel.NodeType.IPTV_Filter_All && (genre === "" || country === "" || language === ""))
            {
                node.subNodes.append({"parent": node, "itemTitle": "<All IPTV Channels>", "itemData": "AllChannels", "checked": false, "expanded": false, "icon": "", "subNodes": [], type: SourceTreeModel.NodeType.IPTV_Filter_All})

                if (country === "")
                    node.subNodes.append({"parent": node, "itemTitle": "Countries", "itemData": "Countries", "checked": false, "expanded": false, "icon": "", "subNodes": [], type: SourceTreeModel.NodeType.IPTV_Filters})

                if (genre === "")
                    node.subNodes.append({"parent": node, "itemTitle": "Genres", "itemData": "Genres", "checked": false, "expanded": false, "icon": "", "subNodes": [], type: SourceTreeModel.NodeType.IPTV_Filters});

                if (language === "")
                    node.subNodes.append({"parent": node, "itemTitle": "Languages", "itemData": "Languages", "checked": false, "expanded": false, "icon": "", "subNodes": [], type: SourceTreeModel.NodeType.IPTV_Filters});
            }
            else
            {
                for (x = 0; x < proxyModel.count; x++)
                {
                    chan = proxyModel.get(x);
                    node.subNodes.append({
                                             "parent": node, "itemTitle": chan.title, "itemData": String(chan.id), "checked": false, "expanded": true, "icon": getIconURL(chan.icon), "subNodes": [], type: SourceTreeModel.NodeType.IPTV_Channel,
                                             "player": "Internal", "url": chan.url, "genre": chan.genre, "countries": chan.countries, "languages": chan.languages, "xmltvid": chan.xmltvid, "xmltvurl": chan.xmltvurl
                                         })
                }
            }
        }
    }

    function getIconURL(iconURL)
    {
        if (iconURL && iconURL != "")
            return iconURL;

        return "https://archive.org/download/icon-default/icon-default.png";
    }
}
