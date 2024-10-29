import { jsonPath, parseJSONString } from "jsonpath.mjs"

WorkerScript.onMessage = function(msg)
{
    if (msg.action === "Load Model")
    {
        loadModel(msg);
    }
    else if (msg.action === "Expand Node")
    {
        expandNode(msg);
        msg.tree.sync();
        WorkerScript.sendMessage({model: "RadioBrowserModel", status: "ExpandNode Finished", path: msg.path, node: msg.node});
    }
}

function loadModel(msg)
{
    WorkerScript.sendMessage({model: "RadioBrowserModel", status: "Loading"});

    var json = "";
    var x = 0;

    for (x = 0; x < msg.jsonArray.length; x++)
        json = json + msg.jsonArray[x];

    var query = msg.query;
    var objectArray = parseJSONString(json, query);
    var jsonModel = msg.jsonModel;
    var debug = msg.debug;
    var tagList = msg.lists.tagList;
    var countryList = msg.lists.countryList;
    var languageList = msg.lists.languageList;

    var tagsA = [];
    tagList.clear();

    var countries = [];
    countryList.clear();

    var languages = [];
    languageList.clear();

    for ( const key in objectArray )
    {
        var stream = objectArray[key];
        var changeuuid = stream.changeuuid;
        var stationuuid = stream.stationuuid;
        var serveruuid = stream.serveruuid;
        var name = stream.name.trim();
        var url = stream.url;
        var url_resolved = stream.url_resolved;
        var homepage = stream.homepage;
        var favicon = (stream.favicon === undefined || stream.favicon === "" ? "" : stream.favicon);
        var tags = (stream.tags === undefined || stream.tags === "" ? "<Unknown>" : stream.tags);
        var country = stream.country;
        var countrycode = stream.countrycode;
        var iso_3166_2 = stream.iso_3166_2;
        var state = stream.state;
        var language = stream.language;
        var languagecodes = stream.languagecodes;
        var votes = stream.votes;
        var lastchangetime = stream.lastchangetime;
        var lastchangetime_iso8601 = stream.lastchangetime_iso8601;
        var codec = stream.codec;
        var bitrate = stream.bitrate;
        var hls = stream.hls;
        var lastcheckok = stream.lastcheckok;
        var lastchecktime = stream.lastchecktime;
        var lastchecktime_iso8601 = stream.lastchecktime_iso8601;
        var lastcheckoktime = stream.lastcheckoktime;
        var lastcheckoktime_iso8601 = stream.lastcheckoktime_iso8601;
        var lastlocalchecktime= stream.lastlocalchecktime;
        var lastlocalchecktime_iso8601 = stream.lastlocalchecktime_iso8601;
        var clicktimestamp= stream.clicktimestamp;
        var clicktimestamp_iso8601= stream.clicktimestamp_iso8601;
        var clickcount = stream.clickcount;
        var clicktrend = stream.clicktrend;
        var ssl_error = stream.ssl_error;
        var geo_lat = stream.geo_lat;
        var geo_long = stream.geo_long;
        var has_extended_info = stream.has_extended_info;

        jsonModel.append({"id": x, "title": name, "icon": favicon, "player": "VLC", "url": url, "tags": tags, "countries": country, "languages": language});

        var splitTags = tags.split(",");
        for (var y = 0; y < splitTags.length; y++)
        {
            tags = splitTags[y].trim();

            if (tags === "")
                continue;

            if (tagsA.indexOf(tags) < 0)
                tagsA.push(tags);
        }

        var splitCountries = country.split(",");
        for (y = 0; y < splitCountries.length; y++)
        {
            country = splitCountries[y].trim();

            if (country === "")
                continue;

            if (countries.indexOf(country) < 0)
                countries.push(country);
        }

        var splitLanguages = language.split(",");
        for (y = 0; y < splitLanguages.length; y++)
        {
            language = splitLanguages[y].trim();

            if (language === "")
                continue;

            if (languages.indexOf(language) < 0)
                languages.push(language);
        }
    }

    tagsA.sort();

    for (var x = 0; x < tagsA.length; x++)
        tagList.append({"item": tagsA[x]});

    tagList.sync();

    countries.sort();

    for (var x = 0; x < countries.length; x++)
        countryList.append({"item": countries[x]});

    countryList.sync();

    languages.sort();

    for (var x = 0; x < languages.length; x++)
        languageList.append({"item": languages[x]});

    languageList.sync();


    jsonModel.sync();
    WorkerScript.sendMessage({model: "RadioBrowserModel", status: "Ready"});
}

function getNodeFromPath(tree, path)
{
    var list = path.split(" ~ ");
    var node = tree;
    var found = false;

    for (var x = 0; x < list.length; x++)
    {
        found = false;

        for (var y = 0; y < node.count; y++)
        {
            if (node.get(y).itemData == list[x])
            {
                if (x < list.length - 1)
                    node = node.get(y).subNodes;
                else
                    node = node.get(y);

                found = true;
                break;
            }
        }

        if (!found)
            return undefined;
    }

    return node;
}

function expandNode(msg)
{
    WorkerScript.sendMessage({model: "RadioBrowserModel", status: "ExpandingNode"});

    var tree = msg.tree;
    var path = msg.path;
    var defaultIcon = msg.defaultIcon;

    var jsonModel = msg.jsonModel;

    var tagList = msg.lists.tagList;
    var countryList = msg.lists.countryList;
    var languageList = msg.lists.languageList;

    var proxyModel = msg.proxyModel;

    // from SourceTreeModel.qml
    var Root_Title = 1;
    var Radio_Stream = 52;
    var Radio_Filters = 53;
    var Radio_Filter_All = 54;
    var Radio_Filter_Tag = 55;
    var Radio_Filter_Country = 56;
    var Radio_Filter_Language = 57;

    var node = getNodeFromPath(tree, path);

    var stream;
    var x;
    var sort = "Name";
    var tag = "";
    var language = "";
    var country = "";

    var fNode = node;

    while (fNode && fNode.parent !== null)
    {
        if (fNode.type === Radio_Filter_Country)
            country = fNode.itemTitle;
        else if (fNode.type === Radio_Filter_Tag)
            tag = fNode.itemTitle;
        else if (fNode.type === Radio_Filter_Language)
            language = fNode.itemTitle;

        fNode = fNode.parent;
    }

    node.expanded  = true
    node.subNodes.clear();

    if (node.type === Root_Title)
    {
        node.subNodes.append({"parent": node, "itemTitle": "<All Radio Streams>", "itemData": "AllRadioStreams", "checked": false, "expanded": false, "icon": "", "subNodes": [], type: Radio_Filters})
        node.subNodes.append({"parent": node, "itemTitle": "Tags", "itemData": "Tags", "checked": false, "expanded": false, "icon": "", "subNodes": [], type: Radio_Filters})
        node.subNodes.append({"parent": node, "itemTitle": "Countries", "itemData": "Countries", "checked": false, "expanded": false, "icon": "", "subNodes": [], type: Radio_Filters})
        node.subNodes.append({"parent": node, "itemTitle": "Languages", "itemData": "Languages", "checked": false, "expanded": false, "icon": "", "subNodes": [], type: Radio_Filters})
    }
    else if (node.type === Radio_Filters)
    {
        if (node.itemData === "AllRadioStreams")
        {
            for (x = 0; x < jsonModel.count; x++)
            {
                stream = jsonModel.get(x);
                node.subNodes.append({
                                         "parent": node, "itemTitle": stream.title, "itemData": String(stream.id), "checked": false, "expanded": true, "icon": getIconURL(stream.icon, defaultIcon), "subNodes": [], type: Radio_Stream,
                                         "player": "Internal", "url": stream.url, "tag": stream.tags, "countries": stream.countries, "languages": stream.languages
                                     })
            }
        }
        else if (node.itemData === "Countries")
        {
            if (tag === "" && country === "" && language === "")
            {
                // get the full list of countries
                for (x = 0; x < countryList.count; x++)
                {
                    node.subNodes.append({"parent": node, "itemTitle": countryList.get(x).item, "itemData": countryList.get(x).item, "checked": false, "expanded": false, "icon": "", "subNodes": [], type: Radio_Filter_Country})
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
                    node.subNodes.append({"parent": node, "itemTitle": countries[x], "itemData": countries[x], "checked": false, "expanded": false, "icon": "", "subNodes": [], type: Radio_Filter_Country})
                }
            }
        }
        else if (node.itemData === "Tags")
        {
            if (tag === "" && country === "" && language === "")
            {
                // get the full list of tags
                for (x = 0; x < tagList.count; x++)
                {
                    node.subNodes.append({"parent": node, "itemTitle": tagList.get(x).item, "itemData": tagList.get(x).item, "checked": false, "expanded": false, "icon": "", "subNodes": [], type: Radio_Filter_Tag})
                }
            }
            else
            {
                // get a filtered list of tags
                var tags = [];

                for (x = 0; x < node.parent.subNodes.get(0).subNodes.count; x++)
                {
                    var splitTags = node.parent.subNodes.get(0).subNodes.get(x).tags.split(",");
                    for (var y = 0; y < splitTags.length; y++)
                    {
                        tag = splitTags[y].trim();

                        if (tags.indexOf(tag) < 0)
                            tags.push(tag);
                    }
                }

                tags.sort();

                for (x = 0; x < tags.length; x++)
                {
                    node.subNodes.append({"parent": node, "itemTitle": tags[x], "itemData": tags[x], "checked": false, "expanded": false, "icon": "", "subNodes": [], type: Radio_Filter_Tag})
                }
            }
        }
        else if (node.itemData === "Languages")
        {
            if (tag === "" && country === "" && language === "")
            {
                // get the full list of languages
                for (x = 0; x < languageList.count; x++)
                {
                    node.subNodes.append({"parent": node, "itemTitle": languageList.get(x).item, "itemData": languageList.get(x).item, "checked": false, "expanded": false, "icon": "", "subNodes": [], type: Radio_Filter_Language})
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
                    node.subNodes.append({"parent": node, "itemTitle": languages[x], "itemData": languages[x], "checked": false, "expanded": false, "icon": "", "subNodes": [], type: Radio_Filter_Language})
                }
            }
        }
    }
    else if (node.type === Radio_Filter_Tag || node.type === Radio_Filter_Country || node.type === Radio_Filter_Language || node.type === Radio_Filter_All)
    {
        if (node.type !== Radio_Filter_All && (tag === "" || country === "" || language === ""))
        {
            node.subNodes.append({"parent": node, "itemTitle": "<All Radio Streams>", "itemData": "AllRadioStreamss", "checked": false, "expanded": false, "icon": "", "subNodes": [], type: Radio_Filter_All})

            if (country === "")
                node.subNodes.append({"parent": node, "itemTitle": "Countries", "itemData": "Countries", "checked": false, "expanded": false, "icon": "", "subNodes": [], type: Radio_Filters})

            if (tag === "")
                node.subNodes.append({"parent": node, "itemTitle": "Tags", "itemData": "Tags", "checked": false, "expanded": false, "icon": "", "subNodes": [], type: Radio_Filters});

            if (language === "")
                node.subNodes.append({"parent": node, "itemTitle": "Languages", "itemData": "Languages", "checked": false, "expanded": false, "icon": "", "subNodes": [], type: Radio_Filters});
        }
        else
        {
            for (x = 0; x < jsonModel.count; x++)
            {
                stream = jsonModel.get(x);

                if (tag != "" && stream.tags.indexOf(tag) === -1)
                    continue;

                if (country != "" && stream.countries.indexOf(country) === -1)
                    continue;

                if (language != "" && stream.languages.indexOf(language) === -1)
                    continue;

                node.subNodes.append({
                                         "parent": node, "itemTitle": stream.title, "itemData": String(stream.id), "checked": false, "expanded": true, "icon": getIconURL(stream.icon, defaultIcon), "subNodes": [], type: Radio_Stream,
                                         "player": "Internal", "url": stream.url, "tag": stream.tags, "countries": stream.countries, "languages": stream.languages
                                     })
            }
        }
    }
}

function getIconURL(iconURL, defaultIcon)
{
    if (iconURL && iconURL != "")
        return iconURL;

    return defaultIcon;
}

function listModelSort(listModel, compareFunction)
{
    var indexes = [...Array(listModel.count).keys()]
    indexes.sort((a, b) => compareFunction(listModel.get(a), listModel.get(b)))

    let sorted = 0

    while (sorted < indexes.length && sorted === indexes[sorted])
        sorted++;

    if ( sorted === indexes.length )
        return;

    for ( let i = sorted; i < indexes.length; i++ )
    {
        listModel.move(indexes[i], listModel.count - 1, 1);
        listModel.insert( indexes[i], { });
    }

    listModel.remove(sorted, indexes.length - sorted);
}
