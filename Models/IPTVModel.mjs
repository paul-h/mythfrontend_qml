WorkerScript.onMessage = function(msg)
{
    WorkerScript.sendMessage({model: "IPTVModel", status: "Loading"});

    var objectArray = msg.objectArray;
    var jsonModel = msg.jsonModel;
    var categoryModel = msg.models.categoryModel;
    var languageModel = msg.models.languageModel;
    var countryModel = msg.models.countryModel;
    var streamModel = msg.models.streamModel;
    var guideModel = msg.models.guideModel;

    var categoryList = msg.lists.categoryList;
    var countryList = msg.lists.countryList;
    var languageList = msg.lists.languageList;

    var categoryMap = createCategoryMap(categoryModel);
    var languageMap = createLanguageMap(languageModel);
    var countryMap = createCountryMap(countryModel);
    var streamMap = createStreamMap(streamModel);
    var guideMap = createGuideMap(guideModel);

    var categories = [];
    categoryList.clear();

    var countries = [];
    countryList.clear();

    var languages = [];
    languageList.clear();

    var y = 0;

    for ( const key in objectArray )
    {
        var channel = objectArray[key];
        var id = channel.id;
        var title = channel.name;
        var url = streamMap.get(id);
        var icon = channel.logo;
        var category = "";
        var country = countryMap.get(channel.country);
        var language = "";
        var xmltvid = channel.id;
        var xmltvurl = guideMap.get(channel.id);

        if (url === undefined)
            continue;

        category = getCategories(categories, categoryMap, channel.categories.toString());

        if (countries.indexOf(country) < 0)
            countries.push(country);

        language = getLanguages(languages, languageMap, channel.languages.toString());

        if (xmltvurl === undefined)
            xmltvurl = "";

        if (url === undefined)
            continue;

        jsonModel.append({"id": id, "title": title, "icon": icon, "player": "Internal", "url": url, "genre": category, "countries": country, "languages": language, "xmltvid": xmltvid, "xmltvurl": xmltvurl});

    }

    // add categories
    categories.sort();
    categoryList.append({"item": "<All Genres>"});

    for (y = 0; y < categories.length; y++)
        categoryList.append({"item": categories[y]});

    categoryList.sync();

    // add countries
    countries.sort();
    countryList.append({"item": "<All Countries>"});

    for (y = 0; y < countries.length; y++)
        countryList.append({"item": countries[y]});

    countryList.sync();

    // add languages
    languages.sort();
    languageList.append({"item": "<All Languages>"});

    for (y = 0; y < languages.length; y++)
        languageList.append({"item": languages[y]});

    languageList.sync();

    jsonModel.sync();

    WorkerScript.sendMessage({model: "IPTVModel", status: "Ready"});
}

function createCategoryMap(model)
{
    var map = new Map();

    for (var x = 0; x < model.count; x++)
    {
        map.set(model.get(x).id, model.get(x).name);
    }

    return map;
}

function createLanguageMap(model)
{
    var map = new Map();

    for (var x = 0; x < model.count; x++)
    {
        map.set(model.get(x).code, model.get(x).name);
    }

    return map;
}

function createCountryMap(model)
{
    var map = new Map();

    for (var x = 0; x < model.count; x++)
    {
        map.set(model.get(x).code, model.get(x).name);
    }

    return map;
}

function createStreamMap(model)
{
    var map = new Map();

    for (var x = 0; x < model.count; x++)
    {
        map.set(model.get(x).channel, model.get(x).url);
    }

    return map;
}

function createGuideMap(model)
{
    var map = new Map();

    for (var x = 0; x < model.count; x++)
    {
        map.set(model.get(x).channel, model.get(x).url);
    }

    return map;
}

function getCategories(categoryArray, categoryMap, categories)
{
    var result = "";
    var cats = categories.split(",");

    for (var x = 0; x < cats.length; x++)
    {
        var cat = categoryMap.get(cats[x]);

        if (cat === undefined)
            continue;

        if (categoryArray.indexOf(cat) < 0)
            categoryArray.push(cat);

        if (result === "")
            result = cat;
        else
            result = result + ", " + cat;
    }

    if (result === "")
        result = "Unknown";

    return result;
}

function getLanguages(languagesArray, languageMap, languages)
{
    var result = "";
    var langs = languages.split(",");

    for (var x = 0; x < langs.length; x++)
    {
        var lang = languageMap.get(langs[x]);

        if (lang === undefined)
            continue;

        if (languagesArray.indexOf(lang) < 0)
            languagesArray.push(lang);

        if (result === "")
            result = lang;
        else
            result = result + ", " + lang;
    }

    if (result === "")
        result = "Unknown";

    return result;
}

