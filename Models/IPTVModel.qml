import QtQuick 2.0
import QtQuick.XmlListModel 2.0
import mythqml.net 1.0

Item
{
    id: root

    property alias model: listModel
    property JSONListModel jsonModel: jsonModel

    signal loaded();

    ListModel
    {
        id: listModel

        property var genreList: ListModel{}
        property var countryList: ListModel{}
        property var languageList: ListModel{}

        signal loadingStatus(int status);
    }

    JSONListModel
    {
        id: jsonModel
        source: "https://iptv-org.github.io/iptv/channels.json"

        onLoaded:
        {
            var genres = [];
            var countries = [];
            var languages = [];

            listModel.genreList.clear();
            listModel.countryList.clear();
            listModel.languageList.clear();

            for (var x = 0; x < jsonModel.model.count; x++)
            {
                var title = jsonModel.model.get(x).name;
                var url = jsonModel.model.get(x).url;
                var icon = jsonModel.model.get(x).logo && jsonModel.model.get(x).logo !== undefined ? jsonModel.model.get(x).logo : "";
                var genre = getCategories(jsonModel.model.get(x).categories);
                var country = getCountries(jsonModel.model.get(x).countries);
                var language = getLanguages(jsonModel.model.get(x).languages);
                var xmltvid = jsonModel.model.get(x).tvg && jsonModel.model.get(x).tvg !== undefined ? jsonModel.model.get(x).tvg.id : ""
                var xmltvurl = jsonModel.model.get(x).tvg && jsonModel.model.get(x).tvg !== undefined ? jsonModel.model.get(x).tvg.url : ""

                listModel.append({"id": x, "title": title, "icon": icon, "player": "Internal", "url": url, "genre": genre, "countries": country, "languages": language, "xmltvid": xmltvid, "xmltvurl": xmltvurl});

                var splitGenres = genre.split(",");
                for (var y = 0; y < splitGenres.length; y++)
                {
                    genre = splitGenres[y].trim();

                    if (genres.indexOf(genre) < 0)
                        genres.push(genre);
                }

                var splitCountries = country.split(",");
                for (var y = 0; y < splitCountries.length; y++)
                {
                    country = splitCountries[y].trim();

                    if (countries.indexOf(country) < 0)
                        countries.push(country);
                }

                var splitLanguages = language.split(",");
                for (var y = 0; y < splitLanguages.length; y++)
                {
                    language = splitLanguages[y].trim();

                    if (languages.indexOf(language) < 0)
                        languages.push(language);
                }
            }

            genres.sort();
            listModel.genreList.append({"item": "<All Genres>"});

            for (var x = 0; x < genres.length; x++)
                listModel.genreList.append({"item": genres[x]});

            countries.sort();
            listModel.countryList.append({"item": "<All Countries>"});

            for (var x = 0; x < countries.length; x++)
                listModel.countryList.append({"item": countries[x]});

            languages.sort();
            listModel.languageList.append({"item": "<All Languages>"});

            for (var x = 0; x < languages.length; x++)
                listModel.languageList.append({"item": languages[x]});

            listModel.loadingStatus(XmlListModel.Ready);
        }

        function getCategories(categories)
        {
            var result = "";

            if (!categories || categories === undefined || categories.count == 0)
                return "Unknown"

            for (var x = 0; x < categories.count; x++)
            {
                if (result.length === 0)
                    result = categories.get(x).name;
                else
                    result = result + ", " + categories.get(x).name;
            }

            return result
        }

        function getCountries(countries)
        {
            var result = "";

            if (!countries || countries === undefined || countries.count == 0)
                return "Unknown"

            for (var x = 0; x < countries.count; x++)
            {
                if (result.length === 0)
                    result = countries.get(x).name;
                else
                    result = result + ", " + countries.get(x).name;
            }

            return result
        }

        function getLanguages(languages)
        {
            var result = "";

            if (!languages || languages === undefined || languages.count == 0)
                return "Unknown"

            for (var x = 0; x < languages.count; x++)
            {
                if (result.length === 0)
                    result = languages.get(x).name;
                else
                    result = result + ", " + languages.get(x).name;
            }

            return result
        }
    }
}
