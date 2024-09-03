import QtQuick 2.0
import QtQuick.XmlListModel 2.0
import Base 1.0
import Dialogs 1.0
import Models 1.0
import mythqml.net 1.0
import SqlQueryModel 1.0

import "../../../Util.js" as Util

BaseScreen
{
    defaultFocusItem: titleEdit

    property var sqlModel
    property int currentIndex: 0

    // private
    property int _currentPage: 1
    property var _lastEdit: undefined
    property var _lastButton: undefined
    property var imdbMetadata: undefined
    property var tmdbMetadata: undefined
    property var imdbSearchResult: undefined
    property var tmdbSearchResult: undefined
    property var tmdbConfig:undefined
    property var fanart: undefined

    signal saved()

    QtObject
    {
        id: metadata
        property string id
        property string mediatype
        property string folder
        property string filename
        property string hash
        property string title
        property string subtitle
        property string description
        property string season
        property string episode
        property string tagline
        property string categories
        property string contentType
        property bool   nsfw
        property string inetref
        property string website
        property string studio
        property string coverart
        property string fanart
        property string banner
        property string screenshot
        property string front
        property string back
        property string channum
        property string callsign
        property string startts
        property string releasedate
        property string runtime
        property string runtimesecs
        property string status
        property string extras
    }

    Component.onCompleted:
    {
        showTitle(true, "Video Metadata Editor (Page 1)");
        showTime(false);
        showTicker(false);
        setHelp("https://mythqml.net/help/media_metadata_editor.php#top");

        // save the metadata
        metadata.id = sqlModel.get(currentIndex, "id");
        metadata.mediatype = sqlModel.get(currentIndex, "mediatype");
        metadata.folder = sqlModel.get(currentIndex, "folder");
        metadata.filename = sqlModel.get(currentIndex, "filename");
        metadata.hash = sqlModel.get(currentIndex, "hash");
        metadata.title = sqlModel.get(currentIndex, "title");
        metadata.subtitle = sqlModel.get(currentIndex, "subtitle");
        metadata.description = sqlModel.get(currentIndex, "description");
        metadata.season = sqlModel.get(currentIndex, "season");
        metadata.episode = sqlModel.get(currentIndex, "episode");
        metadata.tagline = sqlModel.get(currentIndex, "tagline");
        metadata.categories = JSON.parse(sqlModel.get(currentIndex, "genres")).join(", ");
        metadata.contentType = sqlModel.get(currentIndex, "contenttype");
        metadata.nsfw = sqlModel.get(currentIndex, "nsfw");
        metadata.inetref = sqlModel.get(currentIndex, "inetref");
        metadata.website = sqlModel.get(currentIndex, "website");
        metadata.studio = sqlModel.get(currentIndex, "studio");
        metadata.coverart = sqlModel.get(currentIndex, "coverart");
        metadata.fanart = sqlModel.get(currentIndex, "fanart");
        metadata.banner = sqlModel.get(currentIndex, "banner");
        metadata.screenshot = sqlModel.get(currentIndex, "screenshot");
        metadata.front = sqlModel.get(currentIndex, "front");
        metadata.back = sqlModel.get(currentIndex, "back");
        metadata.channum = sqlModel.get(currentIndex, "channum");
        metadata.callsign = sqlModel.get(currentIndex, "callsign");
        metadata.startts = sqlModel.get(currentIndex, "startts");
        metadata.releasedate = sqlModel.get(currentIndex, "releasedate");
        metadata.runtime = sqlModel.get(currentIndex, "runtime")
        metadata.runtimesecs = sqlModel.get(currentIndex, "runtimesecs");
        metadata.status = sqlModel.get(currentIndex, "status");
        metadata.extras = sqlModel.get(currentIndex, "extras");

        // update the artwork preview images
        coverartImage.source = findVideoImage(metadata.folder + '/' + metadata.filename, metadata.coverart, "coverart");
        fanartImage.source = findVideoImage(metadata.folder + '/' + metadata.filename, metadata.fanart, "fanart");
        bannerImage.source = findVideoImage(metadata.folder + '/' + metadata.filename, metadata.banner, "banner");
        screenshotImage.source = findVideoImage(metadata.folder + '/' + metadata.filename, metadata.screenshot, "screenshot");
        frontImage.source = findVideoImage(metadata.folder + '/' + metadata.filename, metadata.front, "front");
        backImage.source = findVideoImage(metadata.folder + '/' + metadata.filename, metadata.back, "back");

        // if we have a inetref use that to get the latest metadata
        var inetrefs = metadata.inetref.split("|");
        var id, jsonObj;

        for (var x = 0; x < inetrefs.length; x++)
        {
            var inetref = inetrefs[x];

            if (inetref.startsWith("IMDB_"))
            {
                id = inetref.replace("IMDB_", "");
                jsonObj = { "commandType": "Metadata Grabber", "grabber": "IMDB", "queryType": "All", "imdbID": id }
                sendCommandToHelper(JSON.stringify(jsonObj));

                jsonObj = { "commandType": "Metadata Grabber", "grabber": "FANART", "queryType": "Movie", "imdbID": id }
                sendCommandToHelper(JSON.stringify(jsonObj));
            }
            else if (inetref.startsWith("TMDB_"))
            {
                id = inetref.replace("TMDB_", "");
                jsonObj = { "commandType": "Metadata Grabber", "grabber": "TMDB", "queryType": "MovieAll", "tmdb3ID": id }
                sendCommandToHelper(JSON.stringify(jsonObj));
            }
        }
    }

    MythMetadataXMLModel
    {
        id: metadataModel

        onStatusChanged:
        {
            if (status === XmlListModel.Ready)
            {
                if (metadataModel.count)
                {
                    titleEdit.text = metadataModel.get(0).title;
                    subtitleEdit.text = metadataModel.get(0).subtitle;
                    descriptionEdit.text = metadataModel.get(0).description;
                    seasonEdit.text = metadataModel.get(0).season;
                    episodeEdit.text = metadataModel.get(0).episode;
                    taglineEdit.text = metadataModel.get(0).tagline;
                    categoriesEdit.text = metadataModel.get(0).categories;
                    typeEdit.text = metadataModel.get(0).contenttype;
                    nsfwCheck.checked = metadataModel.get(0).nsfw
                    inetrefEdit.text = metadataModel.get(0).inetref;
                    websiteEdit.text = metadataModel.get(0).website;
                    studioEdit.text = metadataModel.get(0).studio;
                    coverartEdit.text = metadataModel.get(0).coverart;
                    fanartEdit.text = metadataModel.get(0).fanart;
                    bannerEdit.text = metadataModel.get(0).banner;
                    screenshotEdit.text = metadataModel.get(0).screenshot;
                    frontEdit.text = metadataModel.get(0).front;
                    backEdit.text = metadataModel.get(0).back;
                    channumEdit.text = metadataModel.get(0).channum;
                    callsignEdit.text = metadataModel.get(0).callsign;
                    starttsEdit.text = metadataModel.get(0).startts;
                    releasedateEdit.text = metadataModel.get(0).releasedate;
                    runtimeEdit.text = metadataModel.get(0).runtime;
                    runtimesecEdit.text = metadataModel.get(0).runtimesecs;
                    statusSelector.selectItem(metadataModel.get(0).status);

                    showNotification("Metadata loaded from mxml file.", settings.osdTimeoutMedium);
                }
            }
        }
    }

    SqlQueryModel
    {
        id: linksModel

        sql: "SELECT * FROM metadatalinks ORDER BY nsfw, title"

        onSqlChanged:
        {
            while (canFetchMore(index(-1, -1)))
                fetchMore(index(-1, -1));
        }
    }

    ListModel
    {
        id: searchResultModel
    }

    Keys.onPressed:
    {
        event.accepted = true;

        if (event.key === Qt.Key_F1)
        {
            // RED - cancel
            returnSound.play();
            stack.pop();
        }
        else if (event.key === Qt.Key_F2)
        {
            // GREEN - save
            save();
        }
        else if (event.key === Qt.Key_F3)
        {
            // YELLOW - previous page
            previousPage();
        }
        else if (event.key === Qt.Key_F4)
        {
            // BLUE - next page
            nextPage();
        }
        else if (event.key === Qt.Key_F5 || event.key === Qt.Key_M)
        {
            popupMenu.clearMenuItems();

            popupMenu.addMenuItem("", "Search for Metadata");
            popupMenu.addMenuItem("Search for Metadata", "Find XML Metadata", "XML");

            if (nsfwCheck.checked)
                linksModel.sql = "SELECT * FROM metadatalinks ORDER BY nsfw, title";
            else
                linksModel.sql = "SELECT * FROM metadatalinks WHERE nsfw = 0 ORDER BY title";

            for (var x = 0; x < linksModel.rowCount(); x++)
            {
                if (linksModel.get(x, 'type') === "HELPER" && !isHelperAvailable())
                    continue;

                popupMenu.addMenuItem("Search for Metadata", linksModel.get(x, 'title'), "LINK" + x);
            }

            if (_currentPage == 2)
                popupMenu.addMenuItem("", "Show Artwork...", "ARTWORK" );

            if (websiteEdit.text != "")
                popupMenu.addMenuItem("", "Show Website...", "WEBSITE");

            popupMenu.addMenuItem("", "Show Help...", "HELP");

            popupMenu.show();
        }
        else if (event.key === Qt.Key_F6)
        {
            findXMLMetadata();
        }
        else if (event.key === Qt.Key_F9)
        {
            if (_currentPage == 2)
            {
                previewImage.visible = !previewImage.visible;

                if (coverartEdit.focus)
                    previewImage.source = findVideoImage(metadata.folder + '/' + metadata.filename, coverartEdit.text, "coverart")
                else if (fanartEdit.focus)
                    previewImage.source = findVideoImage(metadata.folder + '/' + metadata.filename, fanartEdit.text, "fanart");
                else if (bannerEdit.focus)
                    previewImage.source = findVideoImage(metadata.folder + '/' + metadata.filename, bannerEdit.text, "banner");
                else if (screenshotEdit.focus)
                    previewImage.source = findVideoImage(metadata.folder + '/' + metadata.filename, screenshotEdit.text, "screenshot");
                else if (frontEdit.focus)
                    previewImage.source = findVideoImage(metadata.folder + '/' + metadata.filename, frontEdit.text, "front");
                else if (backEdit.focus)
                    previewImage.source = findVideoImage(metadata.folder + '/' + metadata.filename, backEdit.text, "back");
                else
                    previewImage.source = findVideoImage(metadata.folder + '/' + metadata.filename, coverartEdit.text, "coverart")
            }
        }
        else if (event.key === Qt.Key_Insert)
        {
            findMetadata();
        }

        else
            event.accepted = false;
    }

    // page 1
    Item
    {
        id: page1
        anchors.fill: parent
        visible: true

        LabelText
        {
            x: xscale(48); y: yscale(100)
            text: "Title:"
        }

        BaseEdit
        {
            id: titleEdit
            x: xscale(400); y: yscale(100)
            width: xscale(700)
            height: yscale(48)
            text: metadata.title
            KeyNavigation.up: saveButton
            KeyNavigation.down: subtitleEdit
        }

        LabelText
        {
            x: xscale(50); y: yscale(150)
            text: "Subtitle:"
        }

        BaseEdit
        {
            id: subtitleEdit
            x: xscale(400); y: yscale(150)
            width: xscale(700)
            height: yscale(48)
            text: metadata.subtitle
            KeyNavigation.up: titleEdit
            KeyNavigation.down: seasonEdit
        }

        LabelText
        {
            x: xscale(50); y: yscale(200)
            text: "Season:"
        }

        BaseEdit
        {
            id: seasonEdit
            x: xscale(400); y: yscale(200)
            width: xscale(100)
            height: yscale(48)
            text: metadata.season
            KeyNavigation.up: subtitleEdit
            KeyNavigation.down: descriptionEdit
            KeyNavigation.right: episodeEdit
        }

        LabelText
        {
            x: xscale(700); y: yscale(200)
            text: "Episode:"
        }

        BaseEdit
        {
            id: episodeEdit
            x: xscale(1000); y: yscale(200)
            width: xscale(100)
            height: yscale(48)
            text: metadata.episode
            KeyNavigation.up: subtitleEdit
            KeyNavigation.down: descriptionEdit
            KeyNavigation.left: seasonEdit
        }

        LabelText
        {
            x: xscale(50); y: yscale(250)
            text: "Description:"
        }

        BaseMultilineEdit
        {
            id: descriptionEdit
            x: xscale(400); y: yscale(250)
            width: xscale(700)
            height: yscale(280)
            text: metadata.description
            KeyNavigation.up: seasonEdit
            KeyNavigation.down: taglineEdit
        }

        LabelText
        {
            x: xscale(50); y: yscale(550)
            text: "Tagline:"
        }

        BaseEdit
        {
            id:taglineEdit
            x: xscale(400); y: yscale(550)
            width: xscale(700)
            height: yscale(48)
            text: metadata.tagline
            KeyNavigation.up: descriptionEdit
            KeyNavigation.down: prevButton
        }
    }

    // page 2
    Item
    {
        id: page2
        anchors.fill: parent
        visible: false

        LabelText
        {
            x: xscale(50); y: yscale(60)
            text: "Coverart:"
        }

        BaseEdit
        {
            id: coverartEdit
            x: xscale(250); y: yscale(60)
            width: xscale(775)
            height: yscale(50)
            text: metadata.coverart
            KeyNavigation.up: saveButton
            KeyNavigation.down: fanartEdit
            KeyNavigation.right: coverartButton
            onEditingFinished: coverartImage.source = findVideoImage(metadata.folder + '/' + metadata.filename, text, "coverart");
        }

        BaseButton
        {
            id: coverartButton;
            x: xscale(1050)
            y: yscale(60);
            width: xscale(50); height: yscale(50)
            text: "X";
            KeyNavigation.up: saveButton
            KeyNavigation.left: coverartEdit
            KeyNavigation.down: fanartButton
            onClicked:
            {
                _lastEdit = coverartEdit;
                _lastButton = coverartButton;
                fileDialog.show();
            }
        }

        Image
        {
            id: coverartImage
            x: xscale(1120); y: yscale(35); height: yscale(100); width: xscale(100)
            fillMode: Image.PreserveAspectFit
            source: findVideoImage(metadata.folder + '/' + metadata.filename, metadata.coverart, "coverart")
            onStatusChanged: if (status == Image.Error) source = mythUtils.findThemeFile("images/grid_noimage.png");
        }

        LabelText
        {
            x: xscale(50); y: yscale(160)
            text: "Fanart:"
        }

        BaseEdit
        {
            id: fanartEdit
            x: xscale(250); y: yscale(160)
            width: xscale(775)
            height: yscale(50)
            text: metadata.fanart
            KeyNavigation.up: coverartEdit
            KeyNavigation.down: bannerEdit
            KeyNavigation.right: fanartButton
            onEditingFinished: fanartImage.source = findVideoImage(metadata.folder + '/' + metadata.filename, text, "fanart");
        }

        BaseButton
        {
            id: fanartButton;
            x: xscale(1050)
            y: yscale(160);
            width: xscale(50); height: yscale(50)
            text: "X";
            KeyNavigation.up: coverartButton
            KeyNavigation.left: fanartEdit
            KeyNavigation.down: bannerButton
            onClicked:
            {
                _lastEdit = fanartEdit;
                _lastButton = fanartButton;
                fileDialog.show();
            }
        }

        Image
        {
            id: fanartImage
            x: xscale(1120); y: yscale(135); width: xscale(100); height: yscale(100)
            fillMode: Image.PreserveAspectFit
            source: findVideoImage(metadata.folder + '/' + metadata.filename, metadata.fanart, "fanart")
            onStatusChanged: if (status == Image.Error) source = mythUtils.findThemeFile("images/grid_noimage.png");
        }

        LabelText
        {
            x: xscale(50); y: yscale(260)
            text: "Banner:"
        }

        BaseEdit
        {
            id: bannerEdit
            x: xscale(250); y: yscale(260)
            width: xscale(775)
            height: yscale(50)
            text: metadata.banner
            KeyNavigation.up: fanartEdit
            KeyNavigation.down: screenshotEdit
            KeyNavigation.right: bannerButton
            onEditingFinished: bannerImage.source = findVideoImage(metadata.folder + '/' + metadata.filename, text, "banner");
        }

        BaseButton
        {
            id: bannerButton;
            x: xscale(1050)
            y: yscale(260);
            width: xscale(50); height: yscale(50)
            text: "X";
            KeyNavigation.up: fanartButton
            KeyNavigation.left: bannerEdit
            KeyNavigation.down: screenshotButton
            onClicked:
            {
                _lastEdit = bannerEdit;
                _lastButton = bannerButton;
                fileDialog.show();
            }
        }

        Image
        {
            id: bannerImage
            x: xscale(1120); y: yscale(235); height: yscale(100); width: xscale(100)
            fillMode: Image.PreserveAspectFit
            source: findVideoImage(metadata.folder + '/' + metadata.filename, metadata.banner, "banner")
            onStatusChanged: if (status == Image.Error) source = mythUtils.findThemeFile("images/grid_noimage.png");
        }

        LabelText
        {
            x: xscale(50); y: yscale(360)
            text: "Screenshot:"
        }

        BaseEdit
        {
            id: screenshotEdit
            x: xscale(250); y: yscale(360)
            width: xscale(770)
            height: yscale(50)
            text: metadata.screenshot
            KeyNavigation.up: bannerEdit
            KeyNavigation.down: frontEdit
            KeyNavigation.right: screenshotButton
            onEditingFinished: screenshotImage.source = findVideoImage(metadata.folder + '/' + metadata.filename, text, "screenshot");
        }

        BaseButton
        {
            id: screenshotButton;
            x: xscale(1050)
            y: yscale(360);
            width: xscale(50); height: yscale(50)
            text: "X";
            KeyNavigation.up: bannerButton
            KeyNavigation.left: screenshotEdit
            KeyNavigation.down: frontButton
            onClicked:
            {
                _lastEdit = screenshotEdit;
                _lastButton = screenshotButton;
                fileDialog.show();
            }
        }

        Image
        {
            id: screenshotImage
            fillMode: Image.PreserveAspectFit
            x: xscale(1120); y: yscale(335); height: yscale(100); width: xscale(100)
            source: findVideoImage(metadata.folder + '/' + metadata.filename, metadata.screenshot, "screenshot")
            onStatusChanged: if (status == Image.Error) source = mythUtils.findThemeFile("images/grid_noimage.png");
        }

        LabelText
        {
            x: xscale(50); y: yscale(460)
            text: "Front:"
        }

        BaseEdit
        {
            id: frontEdit
            x: xscale(250); y: yscale(460)
            width: xscale(770)
            height: yscale(50)
            text: metadata.front
            KeyNavigation.up: screenshotEdit
            KeyNavigation.down: backEdit
            KeyNavigation.right: frontButton
            onEditingFinished: frontImage.source = findVideoImage(metadata.folder + '/' + metadata.filename, text, "front");
        }

        BaseButton
        {
            id: frontButton;
            x: xscale(1050)
            y: yscale(460);
            width: xscale(50); height: yscale(50)
            text: "X";
            KeyNavigation.up: screenshotButton
            KeyNavigation.left: frontEdit
            KeyNavigation.down: backButton
            onClicked:
            {
                _lastEdit = frontEdit;
                _lastButton = frontButton;
                fileDialog.show();
            }
        }

        Image
        {
            id: frontImage
            fillMode: Image.PreserveAspectFit
            x: xscale(1120); y: yscale(435); height: yscale(100); width: xscale(100)
            //source: findVideoImage(metadata.folder + '/' + metadata.filename, metadata.front, "front")
            onStatusChanged: if (status == Image.Error) source = mythUtils.findThemeFile("images/grid_noimage.png");
        }

        LabelText
        {
            x: xscale(50); y: yscale(560)
            text: "Back:"
        }

        BaseEdit
        {
            id: backEdit
            x: xscale(250); y: yscale(560)
            width: xscale(770)
            height: yscale(50)
            text: metadata.back
            KeyNavigation.up: frontEdit
            KeyNavigation.down: prevButton
            KeyNavigation.right: backButton
            onEditingFinished: backImage.source = findVideoImage(metadata.folder + '/' + metadata.filename, text, "back");
        }

        BaseButton
        {
            id: backButton;
            x: xscale(1050)
            y: yscale(560);
            width: xscale(50); height: yscale(50)
            text: "X";
            KeyNavigation.up: frontButton
            KeyNavigation.left: backEdit
            KeyNavigation.down: saveButton
            onClicked:
            {
                _lastEdit = backEdit;
                _lastButton = backButton;
                fileDialog.show();
            }
        }

        Image
        {
            id: backImage
            fillMode: Image.PreserveAspectFit
            x: xscale(1120); y: yscale(535); height: yscale(100); width: xscale(100)
            source: findVideoImage(metadata.folder + '/' + metadata.filename, metadata.back, "back")
            onStatusChanged: if (status == Image.Error) source = mythUtils.findThemeFile("images/grid_noimage.png");
        }
    }

    // page 3
    Item
    {
        id: page3
        anchors.fill: parent
        visible: false

        LabelText
        {
            x: xscale(50); y: yscale(100)
            height: yscale(48)
            text: "Categories:"
        }

        BaseEdit
        {
            id: categoriesEdit
            x: xscale(400); y: yscale(100)
            width: xscale(820)
            height: yscale(48)
            text: metadata.categories
            KeyNavigation.up: saveButton;
            KeyNavigation.down: studioEdit
        }

        LabelText
        {
            x: xscale(50); y: yscale(150)
            text: "Studio:"
        }

        BaseEdit
        {
            id: studioEdit
            x: xscale(400); y: yscale(150)
            width: xscale(820)
            height: yscale(48)
            text: metadata.studio
            KeyNavigation.up: categoriesEdit
            KeyNavigation.down: inetrefEdit
        }

        LabelText
        {
            x: xscale(50); y: yscale(200)
            text: "Inetref:"
        }

        BaseEdit
        {
            id: inetrefEdit
            x: xscale(400); y: yscale(200)
            width: xscale(300)
            height: yscale(48)
            text: metadata.inetref
            KeyNavigation.up: studioEdit
            KeyNavigation.down: websiteEdit
            KeyNavigation.right: inetrefButton
        }

        BaseButton
        {
            id: inetrefButton;
            x: xscale(710)
            y: yscale(200);
            width: xscale(50); height: yscale(50)
            text: "X";
            KeyNavigation.up: studioEdit
            KeyNavigation.down: websiteEdit
            KeyNavigation.left: inetrefEdit
            KeyNavigation.right: hashEdit

            onClicked:
            {
                if (imdbSearchResult !== undefined && tmdbSearchResult !== undefined)
                {
                    showSearchResults();
                }
                else
                {
                    showBusyDialog("Searching for metadata. Please Wait...", 10000);

                    var jsonObj;

                    if (imdbSearchResult === undefined)
                    {
                        jsonObj = { "commandType": "Metadata Grabber", "grabber": "IMDB", "queryType": "Search", "searchQuery": titleEdit.text }
                        sendCommandToHelper(JSON.stringify(jsonObj));
                    }

                    if (tmdbSearchResult === undefined)
                    {
                        jsonObj = { "commandType": "Metadata Grabber", "grabber": "TMDB", "queryType": "Search", "searchQuery": titleEdit.text }
                        sendCommandToHelper(JSON.stringify(jsonObj));
                    }
                }
            }
        }

        LabelText
        {
            x: xscale(800); y: yscale(200)
            text: "File Hash:"
        }

        BaseEdit
        {
            id: hashEdit
            x: xscale(910); y: yscale(200)
            width: xscale(250)
            height: yscale(48)
            text: metadata.hash
            KeyNavigation.up: studioEdit
            KeyNavigation.down: websiteEdit
            KeyNavigation.left: inetrefButton
            KeyNavigation.right: hashButton
        }

        BaseButton
        {
            id: hashButton;
            x: xscale(1170)
            y: yscale(200);
            width: xscale(50); height: yscale(50)
            text: "X";
            KeyNavigation.up: studioEdit
            KeyNavigation.down: websiteEdit
            KeyNavigation.left: hashEdit
            KeyNavigation.right: websiteEdit
            onClicked:
            {
                _lastEdit = hashEdit;
                _lastButton = hashButton;
                // TODO
            }
        }

        LabelText
        {
            x: xscale(50); y: yscale(250)
            text: "Website:"
        }

        BaseEdit
        {
            id: websiteEdit
            x: xscale(400); y: yscale(250)
            width: xscale(820)
            height: yscale(48)
            text: metadata.website
            KeyNavigation.up: inetrefEdit
            KeyNavigation.down: typeEdit
        }

        LabelText
        {
            x: xscale(50); y: yscale(300)
            text: "Content Type:"
        }

        BaseEdit
        {
            id: typeEdit
            x: xscale(400); y: yscale(300)
            width: xscale(200)
            height: yscale(48)
            text: metadata.contentType
            KeyNavigation.up: websiteEdit
            KeyNavigation.down: nsfwCheck
            KeyNavigation.right: nsfwCheck
        }

        LabelText
        {
            x: xscale(650); y: yscale(300)
            text: "NSFW:"
        }

        BaseCheckBox
        {
            id: nsfwCheck
            x: xscale(1020); y: yscale(300)
            checked: metadata.nsfw
            KeyNavigation.up: typeEdit
            KeyNavigation.down: callsignEdit
            KeyNavigation.left: typeEdit
        }

        LabelText
        {
            x: xscale(50); y: yscale(350)
            text: "Channel No.:"
        }

        BaseEdit
        {
            id: channumEdit
            x: xscale(400); y: yscale(350)
            width: xscale(200)
            height: yscale(48)
            text: metadata.channum
            KeyNavigation.up: nsfwCheck
            KeyNavigation.down: callsignEdit
            KeyNavigation.right: callsignEdit
        }

        LabelText
        {
            x: xscale(650); y: yscale(350)
            text: "Channel Callsign:"
        }

        BaseEdit
        {
            id: callsignEdit
            x: xscale(1020); y: yscale(350)
            width: xscale(200)
            height: yscale(48)
            text: metadata.callsign
            KeyNavigation.up: channumEdit;
            KeyNavigation.down: starttsEdit
            KeyNavigation.left: channumEdit
        }

        LabelText
        {
            x: xscale(50); y: yscale(400)
            text: "Start Time:"
        }

        BaseEdit
        {
            id: starttsEdit
            x: xscale(400); y: yscale(400)
            width: xscale(820)
            height: yscale(48)
            text: metadata.startts
            KeyNavigation.up: callsignEdit
            KeyNavigation.down: releasedateEdit
        }

        LabelText
        {
            x: xscale(50); y: yscale(450)
            text: "Release Date:"
        }

        BaseEdit
        {
            id: releasedateEdit
            x: xscale(400); y: yscale(450)
            width: xscale(820)
            height: yscale(48)
            text: metadata.releasedate
            KeyNavigation.up: starttsEdit
            KeyNavigation.down: runtimeEdit
        }

        LabelText
        {
            x: xscale(50); y: yscale(500)
            text: "Run Time (Minutes):"
        }

        BaseEdit
        {
            id: runtimeEdit
            x: xscale(400); y: yscale(500)
            width: xscale(200)
            height: yscale(48)
            text: metadata.runtime
            KeyNavigation.up: releasedateEdit;
            KeyNavigation.down: runtimesecEdit
            KeyNavigation.right: runtimesecEdit
            onEditingFinished:
            {
                // calculate the runtimesec value
                var seconds = Util.durationToSeconds(text);
                runtimesecEdit.text = seconds;
            }
        }

        LabelText
        {
            x: xscale(650); y: yscale(500)
            text: "Run Time (Seconds):"
        }

        BaseEdit
        {
            id: runtimesecEdit
            x: xscale(1020); y: yscale(500)
            width: xscale(200)
            height: yscale(48)
            text: metadata.runtimesecs
            KeyNavigation.up: runtimeEdit;
            KeyNavigation.down: statusSelector
            KeyNavigation.left: runtimeEdit
        }

        ListModel
        {
            id: statusModel

            ListElement
            {
                itemText: "Unverified"
            }
            ListElement
            {
                itemText: "Working"
            }
            ListElement
            {
                itemText: "Broken"
            }
            ListElement
            {
                itemText: "Deleted"
            }
        }

        LabelText
        {
            x: xscale(50); y: yscale(550)
            text: "Status:"
        }

        BaseSelector
        {
            id: statusSelector
            x: xscale(400); y: yscale(550)
            width: parent.width - x - xscale(60)
            height: yscale(50)
            showBackground: true
            pageCount: 5
            model: statusModel

            KeyNavigation.up: runtimesecEdit
            KeyNavigation.down: saveButton

            Component.onCompleted: selectItem(metadata.status)
        }
    }

    BaseButton
    {
        id: prevButton;
        x: xscale(100); y: yscale(620);
        text: "Previous Page";
        KeyNavigation.up:
        {
            if (_currentPage === 1)
                taglineEdit
            else if (_currentPage === 2)
                backEdit
            else if (_currentPage === 3)
                statusSelector
        }
        KeyNavigation.down: nextButton
        KeyNavigation.right: nextButton
        KeyNavigation.left: saveButton

        onClicked: previousPage()
    }

    BaseButton
    {
        id: nextButton;
        x: xscale(400); y: yscale(620);
        text: "Next Page";
        KeyNavigation.up: prevButton
        KeyNavigation.down: saveButton
        KeyNavigation.right: saveButton
        KeyNavigation.left: prevButton
        onClicked: nextPage();
    }

    BaseButton
    {
        id: saveButton;
        x: xscale(900); y: yscale(620);
        text: "Save";
        KeyNavigation.up: nextButton

        KeyNavigation.down:
        {
            if (_currentPage === 1)
                titleEdit
            else if (_currentPage === 2)
                coverartEdit
            else if (_currentPage === 3)
                categoriesEdit
        }

        KeyNavigation.right: prevButton
        KeyNavigation.left: nextButton

        onClicked: save()
    }

    Footer
    {
        id: footer
        redText: "Cancel"
        greenText: "Save"
        yellowText: "Previous Page"
        blueText: "Next Page"
    }

    Rectangle
    {
        anchors.fill: parent
        color: "black"
        visible: previewImage.visible
    }

    Image
    {
        id: previewImage
        anchors.fill: parent
        fillMode: Image.PreserveAspectFit
        visible: false
        source: findVideoImage(metadata.folder + '/' + metadata.filename, metadata.back, "back")
        onStatusChanged: if (status == Image.Error) source = mythUtils.findThemeFile("images/grid_noimage.png");
    }

    FileDirectoryDialog
    {
        id: fileDialog

        property bool searchWebsites: true
        title: "Choose an image file"
        message: ""

        onAccepted:
        {
            _lastButton.focus = true;
        }
        onCancelled:
        {
            _lastButton.focus = true;
        }

        onItemSelected:
        {
            _lastEdit.text = itemText;
            _lastButton.focus = true;
        }
    }

    PopupMenu
    {
        id: popupMenu

        title: "Menu"
        message: "Metadata Editor Options"

        onItemSelected:
        {
            if (itemData == "XML")
            {
                findXMLMetadata();
            }
            else if (itemData.startsWith("LINK"))
            {
                var index = itemData.replace("LINK", "");
                var link = linksModel.get(index, "url");
                var type = linksModel.get(index, "type");
                link = link.replace("{TITLE}", titleEdit.text);

                if (type === "WEBSITE")
                    showWebpage(link, xscale(1.0), false);
                else if (type === "HELPER")
                {
                    if (isHelperAvailable())
                    {
                        var index = itemData.replace("LINK", "");
                        var link = linksModel.get(index, "url");
                        var type = linksModel.get(index, "type");
                        link = link.replace("{TITLE}", '"' + titleEdit.text + '"');
                        var jsonObj = JSON.parse(link);
                        sendCommandToHelper(JSON.stringify(jsonObj));
                        showNotification("Command was sent to the Helper Service.", settings.osdTimeoutMedium);
                    }
                    else
                        showNotification("Looks like our Helper Service is not running.", settings.osdTimeoutMedium);
                }
                else if (type = "SCRIPT")
                    // TODO
                    ;
            }
            else if (itemData == "WEBSITE")
            {
                showWebpage(websiteEdit.text, xscale(1.0), false);
            }
            else if (itemData == "HELP")
            {
                showHelp();
            }
        }

        onCancelled:
        {
        }
    }

    Component
    {
        id: imageSearchDelegate
        ListItem
        {
            width: ListView.view.width; height: yscale(100)
            Image
            {
                x: xscale(20); y: 0
                width: xscale(100)
                height: yscale(100)
                fillMode: Image.PreserveAspectFit
                source: icon
            }
            ListText
            {
                x: xscale(130); y: 0
                width: xscale(200)
                text: source
            }
            ListText
            {
                x: xscale(340); y: 0
                width: searchDialog.width - xscale(380)
                text: item
            }
        }
    }

    Component
    {
        id: textSearchDelegate
        ListItem
        {
            width: searchDialog.width - xscale(80); height: yscale(50)
            ListText
            {
                x: xscale(10); y: 0
                width: xscale(250)
                text: source
            }
            ListText
            {
                x: xscale(290); y: 0
                width: searchDialog.width - xscale(320)
                text: item
            }
        }
    }

    SearchListDialog
    {
        id: searchDialog

        property string searchItem: ""

        width: xscale(900)

        title: "Choose a title"
        message: ""
        displayField: "title"
        dataField: "link"
        delegate: textSearchDelegate

        onAccepted:
        {
        }
        onCancelled:
        {
        }

        onItemSelected:
        {
            if (searchItem === "title")
                titleEdit.text = itemText;
            else if (searchItem === "description")
                descriptionEdit.text = itemText;
            else if (searchItem === "tagline")
                taglineEdit.text = itemText;
            else if (searchItem === "release")
                releasedateEdit.text = itemText;
            else if (searchItem === "studio")
                studioEdit.text = itemText;
            else if (searchItem === "runtime")
            {
                runtimeEdit.text = itemText;

                // calculate the runtimesec value
                var seconds = Util.durationToSeconds(itemText);;
                runtimesecEdit.text = seconds;
            }
            else if (searchItem === "runtimesec")
                runtimesecEdit.text = itemText
            else if (searchItem === "description")
                descriptionEdit.text = itemText
            else if (searchItem === "coverart")
            {
                coverartEdit.text = itemText;
                coverartImage.source = findVideoImage(itemText);
            }
            else if (searchItem === "fanart")
            {
                fanartEdit.text = itemText;
                fanartImage.source = findVideoImage(itemText);
            }
            else if (searchItem === "banner")
            {
                bannerEdit.text = itemText;
                bannerImage.source = findVideoImage(itemText);
            }
            else if (searchItem === "screenshot")
            {
                screenshotEdit.text = itemText;
                screenshotImage.source = findVideoImage(itemText);
            }
            else if (searchItem === "front")
            {
                frontEdit.text = itemText;
                frontImage.source = findVideoImage(itemText);
            }
            else if (searchItem === "back")
            {
                backEdit.text = itemText;
                backImage.source = findVideoImage(itemText);
            }
            else if (searchItem === "website")
                websiteEdit.text = itemText
            else if (searchItem === "categories")
                categoriesEdit.text = itemText
            else if (searchItem === "search_title")
            {
                var inetrefs = inetrefEdit.text.split("|");
                var found = false

                for (var x = 0; x< inetrefs.length; x++)
                {
                    var inetref = inetrefs[x];

                    if (inetref.startsWith("IMDB_") && itemText.startsWith("IMDB_"))
                    {
                        found = true;
                        inetrefs[x] = itemText
                    }
                    else if (inetref.startsWith("TMDB_") && itemText.startsWith("TMDB_"))
                    {
                        found = true;
                        inetrefs[x] = itemText
                    }
                }

                if (!found)
                    inetrefs.push(itemText);

                inetrefEdit.text = inetrefs.join('|');
            }
        }
    }

    function showSearchResults()
    {
        searchResultModel.clear();

        if (imdbSearchResult !== undefined)
        {
            for (var x = 0; x < imdbSearchResult.length; x++)
            {
                var no = String(x).padStart(2, '0') + ": ";
                var id = "IMDB_" + imdbSearchResult[x].id;
                var title = imdbSearchResult[x].titleNameText;
                var year =  "titleReleaseText" in imdbSearchResult[x] ? imdbSearchResult[x].titleReleaseText : "N/A";
                var image = "titlePosterImageModel" in imdbSearchResult[x] ? imdbSearchResult[x].titlePosterImageModel.url : "N/A";
                var credits = "";
                var creditsList = imdbSearchResult[x].topCredits
                if (creditsList != undefined)
                    credits = creditsList.join(", ");

                searchResultModel.append({"source": id, "title": title, "year": year, "credits": credits, "icon": image, "item": title + "(" + year + ") - " + credits, "data": id});
            }
        }

        if (tmdbSearchResult !== undefined)
        {
            var baseUrl = tmdbConfig.images.base_url + "original"

            for (var x = 0; x < tmdbSearchResult.length; x++)
            {
                var no = String(x).padStart(2, '0') + ": ";
                var id = "TMDB_" + tmdbSearchResult[x].id;
                var title = tmdbSearchResult[x].original_title;
                var year =  "release_date" in tmdbSearchResult[x] ? tmdbSearchResult[x].release_date : "N/A";
                var image = "poster_path" in tmdbSearchResult[x] ? tmdbSearchResult[x].poster_path : "";
                var credits = "";

                searchResultModel.append({"source": id, "title": title, "year": year, "credits": credits, "icon": baseUrl + image, "item": title + "(" + year + ") - " + credits, "data": id });
            }
        }

        searchDialog.searchItem = "search_title";
        searchDialog.displayField = "item";
        searchDialog.dataField = "data";
        searchDialog.sortField = "";
        searchDialog.delegate = imageSearchDelegate;
        searchDialog.model = searchResultModel;

        searchDialog.show();
    }

    function previousPage()
    {
        if (_currentPage == 1)
            _currentPage = 3;
        else
            _currentPage--;

        switchPage();
    }

    function nextPage()
    {
        if (_currentPage == 3)
            _currentPage = 1;
        else
            _currentPage++;

        switchPage();
    }

    function switchPage()
    {
        if (_currentPage == 1)
        {
            page1.visible = true;
            page2.visible = false;
            page3.visible = false;
            titleEdit.focus = true;
            showTitle(true, "Video Metadata Editor (Page 1)");
            returnSound.play();
        }
        else if (_currentPage == 2)
        {
            page1.visible = false;
            page2.visible = true;
            page3.visible = false;
            coverartEdit.focus = true;
            showTitle(true, "Video Metadata Editor (Page 2)");
            returnSound.play();
        }
        else if (_currentPage == 3)
        {
            page1.visible = false;
            page2.visible = false;
            page3.visible = true;
            categoriesEdit.focus = true;
            showTitle(true, "Video Metadata Editor (Page 3)");
            returnSound.play();
        }
    }

    function findXMLMetadata()
    {
        var videoFile = metadata.folder + '/' + metadata.filename;
        var xmlFile = Util.removeExtension(videoFile) + ".mxml";

        if (mythUtils.fileExists(xmlFile))
        {
            // force the model to reload
            if (metadataModel.source == "file://" + xmlFile)
                metadataModel.source = ""

            metadataModel.source = "file://" + xmlFile;
        }
        else
        {
            showNotification("No MXML file found!", settings.osdTimeoutMedium);
        }
    }

    function save()
    {
        metadata.title = titleEdit.text;
        metadata.subtitle = subtitleEdit.text;
        metadata.description = descriptionEdit.text;
        metadata.season = seasonEdit.text;
        metadata.episode = episodeEdit.text;
        metadata.tagline = taglineEdit.text;

        var catList = categoriesEdit.text.split(",");
        var catStr = '[';
        var first = true;

        for (var x = 0; x < catList.length; x++)
        {
            if (first)
            {
                catStr = catStr + '"' + catList[x].trim() + '"';
                first = false;
            }
            else
                catStr = catStr + ', "' + catList[x].trim() + '"';
        }
        catStr = catStr + ']'

        metadata.categories = catStr;
        metadata.contentType = typeEdit.text;
        metadata.nsfw = nsfwCheck.checked;
        metadata.inetref = inetrefEdit.text;
        metadata.website = websiteEdit.text;
        metadata.studio = studioEdit.text;
        metadata.coverart = coverartEdit.text;
        metadata.fanart = fanartEdit.text;
        metadata.banner = bannerEdit.text;
        metadata.screenshot = screenshotEdit.text;
        metadata.front = frontEdit.text;
        metadata.back = backEdit.text;

        metadata.channum = channumEdit.text;
        metadata.callsign = callsignEdit.text;
        metadata.startts = starttsEdit.text;
        metadata.releasedate = releasedateEdit.text;
        metadata.runtime = runtimeEdit.text;
        metadata.runtimesecs = runtimesecEdit.text;
        metadata.status = statusSelector.getSelected();

        // save to mxml file
        var xmlFile = Util.removeExtension(metadata.folder + '/' + metadata.filename) + ".mxml";
        mythUtils.writeMetadataXML(xmlFile, metadata);

        // save to database
        if (!dbUtils.updateMediaItem(metadata))
        {
            showNotification("Failed to save to the database!", settings.osdTimeoutMedium);
            return;
        }

        saved();

        returnSound.play();
        stack.pop();
    }

    function checkedValue(value, defaultValue)
    {
        if (value === undefined )
            return defaultValue;

        return value;
    }

    function handleResult(resultJson)
    {
        if (resultJson.resultType === "IMDB Search")
        {
            imdbSearchResult = resultJson["result"];

            if (imdbSearchResult !== undefined && tmdbSearchResult != undefined)
            {
                hideBusyDialog();
                showSearchResults();
            }
        }
        else if (resultJson.resultType === "TMDB Search")
        {
            tmdbSearchResult = resultJson["result"]["results"]["results"];

            if (tmdbConfig === undefined)
            {
                tmdbConfig = resultJson["Result"]["config"];
            }

            if (imdbSearchResult !== undefined && tmdbSearchResult != undefined)
            {
                hideBusyDialog();
                showSearchResults();
            }
        }
        else if (resultJson.resultType === "IMDB All")
        {
            imdbMetadata = resultJson["result"];
        }
        else if (resultJson.resultType === "TMDB MovieAll")
        {
            tmdbMetadata = resultJson["result"];

            if (tmdbConfig === undefined)
                tmdbConfig = tmdbMetadata["config"];

        }
        else if (resultJson.resultType === "FANART Movie")
        {
            fanart = resultJson["result"];
        }

        return true;
    }

    function findMetadata()
    {
        searchResultModel.clear();
        searchDialog.displayField = "item";
        searchDialog.dataField = "data";
        searchDialog.sortField = "";
        searchDialog.delegate = textSearchDelegate;

        if (titleEdit.focus)
        {
            searchDialog.searchItem = "title";

            if (metadata.title !== "")
                searchResultModel.append({"source": "Current", "item": metadata.title, "data": metadata.title, "icon": ""});

            if (imdbMetadata)
                searchResultModel.append({"source": "IMDB title", "item": imdbMetadata.title, "data": imdbMetadata.title, "icon": ""});

            if (tmdbMetadata)
            {
                searchResultModel.append({"source": "TMDB title", "item":  tmdbMetadata.details.title, "data": tmdbMetadata.details.title, "icon": ""});
                searchResultModel.append({"source": "TMDB original title", "item":  tmdbMetadata.details.original_title, "data": tmdbMetadata.details.original_title, "icon": ""});
            }
        }
        else if (descriptionEdit.focus)
        {
            searchDialog.searchItem = "description";

            if (metadata.description !== "")
                searchResultModel.append({"source": "Current", "item": metadata.description, "data": metadata.description, "icon": ""});

            if (imdbMetadata)
            {
                for (var x = 0 ; x < imdbMetadata.summaries.length; x++)
                {
                    searchResultModel.append({"source": "IMDB summary", "item": imdbMetadata.summaries[x], "data": imdbMetadata.summaries[x], "icon": ""});
                }
            }

            if (tmdbMetadata)
                searchResultModel.append({"source": "TMDB overview", "item":  tmdbMetadata.details.overview, "data": tmdbMetadata.details.overview, "icon": ""});
        }
        else if (releasedateEdit.focus)
        {
            searchDialog.searchItem = "release";

            if (metadata.releasedate !== "")
                searchResultModel.append({"source": "Current", "item": releasedateEdit.text, "data": releasedateEdit.text, "icon": ""});

            if (imdbMetadata)
            {
                searchResultModel.append({"source": "IMDB release year", "item": imdbMetadata.releaseYear, "data": imdbMetadata.releaseYear, "icon": ""});
                searchResultModel.append({"source": "IMDB release date", "item": imdbMetadata.releaseDate, "data": imdbMetadata.releaseDate, "icon": ""});
            }

            if (tmdbMetadata)
                searchResultModel.append({"source": "TMDB release date", "item":  tmdbMetadata.details.release_date, "data": tmdbMetadata.details.release_date, "icon": ""});
        }
        else if (studioEdit.focus)
        {
            searchDialog.searchItem = "studio";

            if (metadata.studio !== "")
                searchResultModel.append({"source": "Current", "item": studioEdit.text, "data": studioEdit.text, "icon": ""});

            if (imdbMetadata)
                searchResultModel.append({"source": "IMDB studio", "item": imdbMetadata.studio, "data": imdbMetadata.studio, "icon": ""});

            if (tmdbMetadata)
            {
                var production_companies = tmdbMetadata.details.production_companies;
                var companies = ""
                for (var x = 0 ; x < production_companies.length; x++)
                {
                    if (companies == "")
                        companies = production_companies[x].name;
                    else
                        companies = companies + ", " + production_companies[x].name;
                }

                searchResultModel.append({"source": "TMDB studio", "item": companies, "data": companies, "icon": ""});
            }
        }
        else if (taglineEdit.focus)
        {
            searchDialog.searchItem = "tagline";

            if (metadata.tagline !== "")
                searchResultModel.append({"source": "Current: ", "item": taglineEdit.text, "data": taglineEdit.text, "icon": ""});

            if (imdbMetadata)
            {
                var taglines = imdbMetadata.taglines
                for (var x = 0; x < taglines.length; x++)
                {
                    searchResultModel.append({"source": "IMDB", "item": taglines[x], "data": taglines[x], "icon": ""});
                }
            }

            if (tmdbMetadata)
            {
                var tagline = tmdbMetadata.details.tagline
                searchResultModel.append({"source": "TMDB", "item": tagline, "data": tagline, "icon": ""});
            }
        }
        else if (categoriesEdit.focus)
        {
            searchDialog.searchItem = "categories";

            if (metadata.categories !== "")
                searchResultModel.append({"source": "Current", "item": categoriesEdit.text, "data": categoriesEdit.text, "icon": ""});

            if (imdbMetadata)
            {
                var genresArr = imdbMetadata.genres
                var genres = ""
                for (var x = 0; x < genresArr.length; x++)
                {
                    if (genres == "")
                        genres = genresArr[x];
                    else
                        genres = genres + ", " + genresArr[x];
                }

                searchResultModel.append({"source": "IMDB genres", "item": genres, "data": genres, "icon": ""});

                if (categoriesEdit.text !== "")
                    searchResultModel.append({"source": "IMDB genres", "item": categoriesEdit.text + ", " + genres, "data": categoriesEdit.text + ", " + genres, "icon": ""});
            }

            if (tmdbMetadata)
            {
                var genresArr = tmdbMetadata.details.genres
                var genres = ""
                for (var x = 0; x < genresArr.length; x++)
                {
                    if (genres == "")
                        genres = genresArr[x].name;
                    else
                        genres = genres + ", " + genresArr[x].name;
                }

                searchResultModel.append({"source": "TMDB genres", "item": genres, "data": genres, "icon": ""});

                if (categoriesEdit.text !== "")
                    searchResultModel.append({"source": "TMDB genres", "item": categoriesEdit.text + ", " + genres, "data": categoriesEdit.text + ", " + genres, "icon": ""});
            }
        }
        else if (websiteEdit.focus)
        {
            searchDialog.searchItem = "website";

            if (metadata.website !== "")
                searchResultModel.append({"source": "Current", "item": websiteEdit.text, "data": websiteEdit.text, "icon": ""});

            if (tmdbMetadata)
                searchResultModel.append({"source": "TMDB website", "item": tmdbMetadata.details.homepage, "data": tmdbMetadata.details.homepage, "icon": ""});

            if (imdbMetadata)
            {
                var websites = imdbMetadata.websites
                if (websites)
                {
                    for (var x = 0; x < websites.length; x++)
                        searchResultModel.append({"source": "IMDB Website", "item": websites[x].name + " ~ " + websites[x].url, "data": websites[x].url, "icon": ""});
                }
            }
        }
        else if (runtimeEdit.focus)
        {
            searchDialog.searchItem = "runtime";

            var formatedTime;

            if (metadata.runtime !== "")
                searchResultModel.append({"source": "Current", "item": metadata.runtime, "data": metadata.runtime, "icon": ""});

            if (tmdbMetadata)
            {
                formatedTime = Util.format_time(tmdbMetadata.details.runtime * 60 * 1000, "h'h' m'm' s's'");
                searchResultModel.append({"source": "TMDB runtime", "item": formatedTime, "data": formatedTime, "icon": ""});
            }

            if (imdbMetadata)
            {
                formatedTime = Util.format_time(imdbMetadata.runTimeSec * 1000, "h'h' m'm' s's'");
                searchResultModel.append({"source": "IMDB Runtime Seconds: ", "item": formatedTime, "data": formatedTime, "icon": ""});
            }
        }
        else if (coverartEdit.focus)
        {
            searchDialog.searchItem = "coverart";
            searchDialog.delegate = imageSearchDelegate;

            if (metadata.coverart != "")
                searchResultModel.append({"source": "Current", "item": coverartEdit.text, "data": coverartEdit.text, "icon": coverartEdit.text, "icon": ""});

            if (tmdbMetadata)
            {
                var baseUrl = tmdbConfig.images.base_url + "original"
                searchResultModel.append({"source": "TMDB default poster", "item": tmdbMetadata.details.poster_path, "data": baseUrl + tmdbMetadata.details.poster_path, "icon": baseUrl + tmdbMetadata.details.poster_path});

                var posters = tmdbMetadata.images.posters
                for (var x = 0; x < posters.length; x++)
                {
                    searchResultModel.append({"source": "TMDB poster", "item": posters[x].file_path, "data": baseUrl + posters[x].file_path, "icon": baseUrl + posters[x].file_path});
                }
            }

            if (imdbMetadata)
            {
                searchResultModel.append({"source": "IMDB default poster", "item": imdbMetadata.image, "data": imdbMetadata.image, "icon": imdbMetadata.image});

                var images = imdbMetadata.images
                for (var x = 0; x < images.length; x++)
                {
                    searchResultModel.append({"source": "IMDB image", "item": images[x].caption, "data": images[x].url, "icon": images[x].url});
                }
            }

            if (fanart)
            {
                var posters = fanart.movie.movieposter;
                for (var x = 0; x < posters.length; x++)
                {
                    searchResultModel.append({"source": "FANART image", "item": posters[x].url, "data": posters[x].url, "icon": posters[x].url});
                }
            }
        }
        else if (fanartEdit.focus)
        {
            searchDialog.searchItem = "fanart";
            searchDialog.delegate = imageSearchDelegate;

            if (metadata.fanart != "")
                searchResultModel.append({"source": "Current", "item": fanartEdit.text, "data": fanartEdit.text, "icon": fanartEdit.text});

            if (tmdbMetadata)
            {
                var baseUrl = tmdbConfig.images.base_url + "original"
                searchResultModel.append({"source": "TMDB default poster", "item": tmdbMetadata.details.poster_path, "data": baseUrl + tmdbMetadata.details.poster_path, "icon": baseUrl + tmdbMetadata.details.poster_path});

                var backdrops = tmdbMetadata.images.backdrops
                for (var x = 0; x < backdrops.length; x++)
                {
                    searchResultModel.append({"source": "TMDB backdrop", "item": backdrops[x].file_path, "data": baseUrl + backdrops[x].file_path, "icon": baseUrl + backdrops[x].file_path});
                }
            }

            if (imdbMetadata)
            {
                searchResultModel.append({"source": "IMDB default poster: ", "item": imdbMetadata.image, "data": imdbMetadata.image, "icon": imdbMetadata.image});

                var images = imdbMetadata.images
                for (var x = 0; x < images.length; x++)
                {
                    searchResultModel.append({"source": "IMDB poster: ", "item": images[x].caption, "data": images[x].url, "icon": images[x].url});
                }
            }

            if (fanart)
            {
                var posters = fanart.movie.moviebackground;
                for (var x = 0; x < posters.length; x++)
                {
                    searchResultModel.append({"source": "FANART background", "item": posters[x].url, "data": posters[x].url, "icon": posters[x].url});
                }
            }
        }
        else if (bannerEdit.focus)
        {
            searchDialog.searchItem = "banner";
            searchDialog.delegate = imageSearchDelegate;

            if (metadata.banner != "")
                searchResultModel.append({"source": "Current", "item": bannerEdit.text, "data": bannerEdit.text, "icon": bannerEdit.text});

            if (tmdbMetadata)
            {
                var baseUrl = tmdbConfig.images.base_url + "original"
                searchResultModel.append({"source": "TMDB default poster", "item": tmdbMetadata.details.poster_path, "data": baseUrl + tmdbMetadata.details.poster_path, "icon": baseUrl + tmdbMetadata.details.poster_path});

                var logos = tmdbMetadata.images.logos
                for (var x = 0; x < logos.length; x++)
                {
                    searchResultModel.append({"source": "TMDB logos", "item": logos[x].file_path, "data": baseUrl + logos[x].file_path, "icon": baseUrl + logos[x].file_path});
                }
            }

            if (fanart)
            {
                var banners = fanart.movie.moviebanner;
                for (var x = 0; x < banners.length; x++)
                {
                    searchResultModel.append({"source": "FANART image", "item": banners[x].url, "data": banners[x].url, "icon": banners[x].url});
                }
            }
        }
        else if (screenshotEdit.focus)
        {
            searchDialog.searchItem = "screenshot";
            searchDialog.delegate = imageSearchDelegate;

            if (metadata.screenshot != "")
                searchResultModel.append({"source": "Current", "item": screenshotEdit.text, "data": screenshotEdit.text, "icon": screenshotEdit.text});

            if (tmdbMetadata)
            {
                var baseUrl = tmdbConfig.images.base_url + "original"
                searchResultModel.append({"source": "TMDB default poster", "item": tmdbMetadata.details.poster_path, "data": baseUrl + tmdbMetadata.details.poster_path, "icon": baseUrl + tmdbMetadata.details.poster_path});

                var backdrops = tmdbMetadata.images.backdrops
                for (var x = 0; x < backdrops.length; x++)
                {
                    searchResultModel.append({"source": "TMDB backdrop", "item": backdrops[x].file_path, "data": baseUrl + backdrops[x].file_path, "icon": baseUrl + backdrops[x].file_path});
                }
            }

            if (imdbMetadata)
            {
                searchResultModel.append({"item": "IMDB default poster: " + imdbMetadata.image, "data": imdbMetadata.image, "icon": imdbMetadata.image});

                var images = imdbMetadata.images
                for (var x = 0; x < images.length; x++)
                {
                    searchResultModel.append({"source": "TMDB studio: ", "item": "IMDB image: " + images[x].caption, "data": images[x].url, "icon": images[x].url});
                }
            }
        }
        else if (frontEdit.focus)
        {
            searchDialog.searchItem = "front";
            searchDialog.delegate = imageSearchDelegate;

            if (metadata.front != "")
                searchResultModel.append({"source": "Current", "item": frontEdit.text, "data": frontEdit.text, "icon": frontEdit.text});

            if (tmdbMetadata)
            {
                var baseUrl = tmdbConfig.images.base_url + "original"
                searchResultModel.append({"source": "TMDB default poster", "item": tmdbMetadata.details.poster_path, "data": baseUrl + tmdbMetadata.details.poster_path, "icon": baseUrl + tmdbMetadata.details.poster_path});

                var backdrops = tmdbMetadata.images.backdrops
                for (var x = 0; x < backdrops.length; x++)
                {
                    searchResultModel.append({"source": "TMDB backdrop", "item": backdrops[x].file_path, "data": baseUrl + backdrops[x].file_path, "icon": baseUrl + backdrops[x].file_path});
                }
            }

            if (imdbMetadata)
            {
                searchResultModel.append({"item": "IMDB default poster: " + imdbMetadata.image, "data": imdbMetadata.image, "icon": imdbMetadata.image});

                var images = imdbMetadata.images
                for (var x = 0; x < images.length; x++)
                {
                    searchResultModel.append({"source": "TMDB studio: ", "item": "IMDB image: " + images[x].caption, "data": images[x].url, "icon": images[x].url});
                }
            }
        }
        else if (backEdit.focus)
        {
            searchDialog.searchItem = "back";
            searchDialog.delegate = imageSearchDelegate;

            if (metadata.back != "")
                searchResultModel.append({"source": "Current", "item": backEdit.text, "data": backEdit.text, "icon": backEdit.text});

            if (tmdbMetadata)
            {
                var baseUrl = tmdbConfig.images.base_url + "original"
                searchResultModel.append({"source": "TMDB default poster", "item": tmdbMetadata.details.poster_path, "data": baseUrl + tmdbMetadata.details.poster_path, "icon": baseUrl + tmdbMetadata.details.poster_path});

                var backdrops = tmdbMetadata.images.backdrops
                for (var x = 0; x < backdrops.length; x++)
                {
                    searchResultModel.append({"source": "TMDB backdrop", "item": backdrops[x].file_path, "data": baseUrl + backdrops[x].file_path, "icon": baseUrl + backdrops[x].file_path});
                }
            }

            if (imdbMetadata)
            {
                searchResultModel.append({"item": "IMDB default poster: " + imdbMetadata.image, "data": imdbMetadata.image, "icon": imdbMetadata.image});

                var images = imdbMetadata.images
                for (var x = 0; x < images.length; x++)
                {
                    searchResultModel.append({"source": "TMDB studio: ", "item": "IMDB image: " + images[x].caption, "data": images[x].url, "icon": images[x].url});
                }
            }
        }

        if (searchResultModel.count > 0)
        {
            searchDialog.model = searchResultModel;
            searchDialog.show();
        }
    }
}
