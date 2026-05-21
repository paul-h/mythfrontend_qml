import { jsonPath, parseJSONString } from "jsonpath.mjs"

WorkerScript.onMessage = function(msg)
{
    WorkerScript.sendMessage({model: msg.model, status: "Loading"});

    if (msg.model === "FeedsModel")
        parseFeeds(msg);
    else
        parseChannels(msg);
}

function parseFeeds(msg)
{
    var json = msg.json;
    var query = msg.query;
    var objectArray = parseJSONString(json, query);

    var jsonModel = msg.jsonModel;

    for ( const key in objectArray )
    {
        var feed = objectArray[key];
        var channel = feed.channel
        var id = feed.id;
        var name = feed.name;
        var alt_names = feed.alt_names.toString();
        var is_main = feed.is_main;
        var broadcast_area = feed.broadcast_area.toString()
        var timezones = feed.timezones.toString();
        var languages = feed.languages.toString();
        var format = feed.format

        jsonModel.append({"channel": channel, "id": id, "name": name, "alt_names": alt_names, "broadcast_area": broadcast_area, "timezones": timezones, "languages": languages, "format": format});
    }

    jsonModel.sync();

    WorkerScript.sendMessage({model: "FeedsModel", status: "Ready"});
}

function parseChannels(msg)
{
    var json = msg.json;
    var query = msg.query;
    var objectArray = parseJSONString(json, query);

    var jsonModel = msg.jsonModel;
    var categoryModel = msg.models.categoryModel;
    var languageModel = msg.models.languageModel;
    var countryModel = msg.models.countryModel;
    var streamModel = msg.models.streamModel;
    var guideModel = msg.models.guideModel;
    var logoModel = msg.models.logoModel;
    var feedModel = msg.models.feedsModel;

    var categoryList = msg.lists.categoryList;
    var countryList = msg.lists.countryList;
    var languageList = msg.lists.languageList;

    var x;
    var categories = [];
    categoryList.clear();

    var countries = [];
    countryList.clear();

    var languages = [];
    languageList.clear();

    for ( const key in objectArray )
    {
        var channel = objectArray[key];
        var id = channel.id;
        var title = channel.title;
        var url = channel.url;
        var icon = channel.icon;
        var category = channel.genre;
        var country = channel.countries;
        var language = channel.languages;
        var xmltvid = channel.xmltvid;
        var xmltvurl = channel.xmltvurl;

        var cats = channel.genre;
        var langs = channel.languages;
        var country = channel.countries;

        getCategories(categories, cats);
        getLanguages(languages, langs);
        getCountries(countries, country);

        jsonModel.append({"id": id, "title": title, "icon": icon, "player": "Internal", "url": url, "genre": category, "countries": country, "languages": language, "xmltvid": xmltvid, "xmltvurl": xmltvurl});

    }

    // add categories
    categories.sort();
    categoryList.append({"item": "<All Genres>"});

    for (x = 0; x < categories.length; x++)
        categoryList.append({"item": categories[x]});

    categoryList.sync();

    // add countries
    countries.sort();
    countryList.append({"item": "<All Countries>"});

    for (x = 0; x < countries.length; x++)
        countryList.append({"item": countries[x]});

    countryList.sync();

    // add languages
    languages.sort();
    languageList.append({"item": "<All Languages>"});

    for (x = 0; x < languages.length; x++)
        languageList.append({"item": languages[x]});

    languageList.sync();

    jsonModel.sync();

    WorkerScript.sendMessage({model: "IPTVModel", status: "Ready"});
}

function getCountries(countryArray, country)
{
    if (country === undefined)
        return;

    if (countryArray.indexOf(country) < 0)
        countryArray.push(country);
}

function getCategories(categoryArray, categories)
{
    if (categories === undefined)
        return;

    var cats = categories.split(",");

    for (var x = 0; x < cats.length; x++)
    {
        var cat = cats[x].trim()

        if (cat === undefined)
            continue;

        if (categoryArray.indexOf(cat) < 0)
            categoryArray.push(cat);
    }
}

function getLanguages(languagesArray, languages)
{
    if (languages === undefined)
        return;

    var langs = languages.split(",");

    for (var x = 0; x < langs.length; x++)
    {
        var lang = langs[x];

        if (lang === undefined)
            continue;

        if (languagesArray.indexOf(lang) < 0)
            languagesArray.push(lang);
    }
}
