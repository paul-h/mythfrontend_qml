import QtQuick 2.0
import QtQuick.XmlListModel 2.0
import mythqml.net 1.0

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

    JSONListModel
    {
        id: categoryModel

        source: "https://iptv-org.github.io/api/categories.json"
        onLoaded: loadChannels();
    }

    JSONListModel
    {
        id: languageModel

        source: "https://iptv-org.github.io/api/languages.json"
        onLoaded: loadChannels();
    }

    JSONListModel
    {
        id: countryModel

        source: "https://iptv-org.github.io/api/countries.json"
        onLoaded: loadChannels();
    }

    JSONListModel
    {
        id: streamModel

        source: "https://iptv-org.github.io/api/streams.json"
        onLoaded: loadChannels();
    }

    JSONListModel
    {
        id: guideModel
        source: "https://iptv-org.github.io/api/guides.json"
        onLoaded: loadChannels();
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

        function myparser(objectArray, jsonModel, workerScript, iptvModel)
        {
            // tell the WorkerScript to run the parser
            var models = {'countryModel': countryModel.model, 'languageModel': languageModel.model, 'streamModel': streamModel.model, 'categoryModel': categoryModel.model, 'guideModel': guideModel.model};
            var lists = {'categoryList': root.genreList, 'countryList': root.countryList, 'languageList': root.languageList};
            var msg = {'objectArray': objectArray,  'jsonModel': jsonModel, 'models': models, 'lists': lists};

            workerScript.sendMessage(msg);
        }
    }

    function loadChannels()
    {
        // only load the channels when we have all the other data loaded
        if (categoryModel.count > 0 && countryModel.count > 0 && languageModel.count > 0 && streamModel.count > 0 && guideModel.count > 0)
            channelModel.source = "https://iptv-org.github.io/api/channels.json"
    }
}
