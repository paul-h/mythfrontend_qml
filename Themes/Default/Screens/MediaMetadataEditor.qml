import QtQuick
import QtQml.XmlListModel

import Base 1.0
import Dialogs 1.0
import Models 1.0
import mythqml.net 1.0
import SqlQueryModel 1.0
import com.blackgrain.qml.quickdownload 1.0

import "../../../Util.js" as Util

BaseScreen
{
    defaultFocusItem: titleEdit

    property var metadata: undefined

    property var parentMetadata: []

    //property var sqlModel
    //property int currentIndex: 0

    // private
    property int _currentPage: 1
    property var _lastEdit: undefined
    property var _lastButton: undefined
    property var allMetadata: undefined

    property var tmdbConfig:undefined

    property var imdbSearchResult: undefined
    property var tmdbSearchResult: undefined
    property var thetvdbSearchResult: undefined
    property var tvmazeSearchResult: undefined

    signal saved()

    Component.onCompleted:
    {
        showTitle(true, "Video Metadata Editor (Page 1)");
        showTime(false);
        showTicker(false);
        setHelp("https://mythqml.net/help/media_metadata_editor.php#top");

        // update the artwork preview images
        coverartImage.source = findVideoImage(metadata["folder"] + '/' + metadata["filename"], metadata["coverart"], "coverart");
        fanartImage.source = findVideoImage(metadata["folder"] + '/' + metadata["filename"], metadata["fanart"], "fanart");
        bannerImage.source = findVideoImage(metadata["folder"] + '/' + metadata["filename"], metadata["banner"], "banner");
        screenshotImage.source = findVideoImage(metadata["folder"] + '/' + metadata["filename"], metadata["screenshot"], "screenshot");
        frontImage.source = findVideoImage(metadata["folder"] + '/' + metadata["filename"], metadata["front"], "front");
        backImage.source = findVideoImage(metadata["folder"] + '/' + metadata["filename"], metadata["back"], "back");

        var jsonObj = { "commandType": "Metadata Grabber", "grabber": "ALL", "queryType": "FindAllMetadata", "metadata": metadata };
        sendCommandToHelper(JSON.stringify(jsonObj));

        var folders = metadata["folder"].split('/');
        
        for (var x = 0 ; x < folders.length; x++)
        {
            var folder = folders.pop();

            if (folder === "video")
                break;
            var jsonFile = folders.join('/') + "/" + folder + '/Metadata/' + folder + ".json"

            if (mythUtils.fileExists(jsonFile))
            {
                var json = mythUtils.readTextFile(jsonFile);
                jsonObj = JSON.parse(json);
                parentMetadata.push(jsonObj);
            }
        }
    }

    JSONModel
    {
        id: seriesMetadataModel
    }

    JSONModel
    {
        id: seasonMetadataModel
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
                    contenttypeSelector.selectItem(metadataModel.get(0).contenttype);
                    nsfwCheck.checked = metadataModel.get(0).nsfw
                    FIXME:
                    //inetrefEdit.text = metadataModel.get(0).inetref;
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

    Download
    {
        id: artworkDownloader

        running: false
        followRedirects: true
        overwrite: true

        onFinished:
        {
            var name = Util.getFilename(filename)

            if (name.startsWith("coverart"))
            {
                coverartImage.source = filename; //findVideoImage(metadata["folder"] + '/' + metadata["filename"], coverartEdit.text, "coverart");
                coverartEdit.text = name;
            }
            else if (name.startsWith("fanart"))
            {
                fanartImage.source = filename;
                fanartEdit.text = name;
            }
            else if (name.startsWith("banner"))
            {
                bannerImage.source = filename;
                bannerEdit.text = name;
            }
            else if (name.startsWith("screenshot"))
            {
                screenshotImage.source = filename;
                screenshotEdit.text = name;
            }
            else if (name.startsWith("front"))
            {
                frontImage.source = filename;
                frontEdit.text = name;
            }
            else if (name.startsWith("back"))
            {
                backImage.source = filename;
                backEdit.text = name;
            }
        }
    }

    Keys.onPressed: event =>
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
                    previewImage.source = findVideoImage(metadata["folder"] + '/' + metadata["filename"], coverartEdit.text, "coverart")
                else if (fanartEdit.focus)
                    previewImage.source = findVideoImage(metadata["folder"] + '/' + metadata["filename"], fanartEdit.text, "fanart");
                else if (bannerEdit.focus)
                    previewImage.source = findVideoImage(metadata["folder"] + '/' + metadata["filename"], bannerEdit.text, "banner");
                else if (screenshotEdit.focus)
                    previewImage.source = findVideoImage(metadata["folder"] + '/' + metadata["filename"], screenshotEdit.text, "screenshot");
                else if (frontEdit.focus)
                    previewImage.source = findVideoImage(metadata["folder"] + '/' + metadata["filename"], frontEdit.text, "front");
                else if (backEdit.focus)
                    previewImage.source = findVideoImage(metadata["folder"] + '/' + metadata["filename"], backEdit.text, "back");
                else
                    previewImage.source = findVideoImage(metadata["folder"] + '/' + metadata["filename"], coverartEdit.text, "coverart")
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
            objectName: "title"
            x: xscale(400); y: yscale(100)
            width: xscale(700)
            height: yscale(48)
            text: metadata["title"]
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
            objectName: "subtitle"
            x: xscale(400); y: yscale(150)
            width: xscale(700)
            height: yscale(48)
            text: metadata["subtitle"]
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
            objectName: "season"
            x: xscale(400); y: yscale(200)
            width: xscale(100)
            height: yscale(48)
            text: metadata["season"]
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
            objectName: "episode"
            x: xscale(1000); y: yscale(200)
            width: xscale(100)
            height: yscale(48)
            text: metadata["episode"]
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
            objectName: "description"
            x: xscale(400); y: yscale(250)
            width: xscale(700)
            height: yscale(280)
            text: metadata["description"]
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
            objectName: "tagline"
            x: xscale(400); y: yscale(550)
            width: xscale(700)
            height: yscale(48)
            text: metadata["tagline"]
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
            objectName: "coverart"
            x: xscale(200); y: yscale(60)
            width: xscale(775)
            height: yscale(50)
            text: metadata["coverart"]
            KeyNavigation.up: saveButton
            KeyNavigation.down: fanartEdit
            KeyNavigation.right: coverartButton
            onEditingFinished: coverartImage.source = findVideoImage(metadata["folder"] + '/' + metadata["filename"], text, "coverart");
        }

        BaseButton
        {
            id: coverartButton;
            x: xscale(985)
            y: yscale(60);
            width: xscale(50); height: yscale(50)
            text: "X";
            KeyNavigation.up: saveButton
            KeyNavigation.left: coverartEdit
            KeyNavigation.down: fanartButton
            KeyNavigation.right: coverartDownloadButton
            onClicked:
            {
                _lastEdit = coverartEdit;
                _lastButton = coverartButton;
                fileDialog.showSelected(coverartEdit.text);
            }
        }

        BaseButton
        {
            id: coverartDownloadButton;
            x: xscale(1050)
            y: yscale(60);
            width: xscale(50); height: yscale(50)
            text: "D";
            KeyNavigation.up: saveButton
            KeyNavigation.left: coverartButton
            KeyNavigation.down: fanartDownloadButton
            onClicked:
            {
                if (coverartEdit.text.startsWith("http://") || coverartEdit.text.startsWith("https://"))
                {
                    if (metadata["mediatype"] === "DIRECTORY")
                        artworkDownloader.destination = metadata["folder"] + '/' + metadata["title"] + "/Artwork/coverart.jpg"
                    else
                        artworkDownloader.destination = metadata["folder"] + '/' + metadata["title"] + "/Artwork/" + Util.removeExtension(metadata["filename"]) + "_coverart.jpg";

                    artworkDownloader.start(coverartEdit.text)
                }
            }
        }

        Image
        {
            id: coverartImage
            x: xscale(1120); y: yscale(35); height: yscale(100); width: xscale(100)
            fillMode: Image.PreserveAspectFit
            source: findVideoImage(metadata["folder"] + '/' + metadata["filename"], metadata["coverart"], "coverart")
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
            objectName: "fanart"
            x: xscale(200); y: yscale(160)
            width: xscale(775)
            height: yscale(50)
            text: metadata["fanart"]
            KeyNavigation.up: coverartEdit
            KeyNavigation.down: bannerEdit
            KeyNavigation.right: fanartButton
            onEditingFinished: fanartImage.source = findVideoImage(metadata["folder"] + '/' + metadata["filename"], text, "fanart");
        }

        BaseButton
        {
            id: fanartButton;
            x: xscale(985)
            y: yscale(160);
            width: xscale(50); height: yscale(50)
            text: "X";
            KeyNavigation.up: coverartButton
            KeyNavigation.left: fanartEdit
            KeyNavigation.down: bannerButton
            KeyNavigation.right: fanartDownloadButton
            onClicked:
            {
                _lastEdit = fanartEdit;
                _lastButton = fanartButton;
                fileDialog.showSelected(fanartEdit.text);
            }
        }

        BaseButton
        {
            id: fanartDownloadButton;
            x: xscale(1050)
            y: yscale(160);
            width: xscale(50); height: yscale(50)
            text: "D";
            KeyNavigation.up: coverartDownloadButton
            KeyNavigation.left: fanartButton
            KeyNavigation.down: bannerDownloadButton
            onClicked:
            {
                if (fanartEdit.text.startsWith("http://") || fanartEdit.text.startsWith("https://"))
                {
                    if (metadata["mediatype"] === "DIRECTORY")
                        artworkDownloader.destination = metadata["folder"] + '/' + metadata["title"] + "/Artwork/fanart.jpg"
                    else
                        artworkDownloader.destination = metadata["folder"] + '/' + metadata["title"] + "/Artwork/" + Util.removeExtension(metadata["filename"]) + "_fanart.jpg";

                    artworkDownloader.start(fanartEdit.text)
                }
            }
        }

        Image
        {
            id: fanartImage
            x: xscale(1120); y: yscale(135); width: xscale(100); height: yscale(100)
            fillMode: Image.PreserveAspectFit
            source: findVideoImage(metadata["folder"] + '/' + metadata["filename"], metadata["fanart"], "fanart")
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
            objectName: "banner"
            x: xscale(200); y: yscale(260)
            width: xscale(775)
            height: yscale(50)
            text: metadata["banner"]
            KeyNavigation.up: fanartEdit
            KeyNavigation.down: screenshotEdit
            KeyNavigation.right: bannerButton
            onEditingFinished: bannerImage.source = findVideoImage(metadata["folder"] + '/' + metadata["filename"], text, "banner");
        }

        BaseButton
        {
            id: bannerButton;
            x: xscale(985)
            y: yscale(260);
            width: xscale(50); height: yscale(50)
            text: "X";
            KeyNavigation.up: fanartButton
            KeyNavigation.left: bannerEdit
            KeyNavigation.down: screenshotButton
            KeyNavigation.right: bannerDownloadButton
            onClicked:
            {
                _lastEdit = bannerEdit;
                _lastButton = bannerButton;
                fileDialog.showSelected(bannerEdit.text);
            }
        }

        BaseButton
        {
            id: bannerDownloadButton;
            x: xscale(1050)
            y: yscale(260);
            width: xscale(50); height: yscale(50)
            text: "D";
            KeyNavigation.up: fanartDownloadButton
            KeyNavigation.left: bannerButton
            KeyNavigation.down: screenshotDownloadButton
            onClicked:
            {
                if (bannerEdit.text.startsWith("http://") || bannerEdit.text.startsWith("https://"))
                {
                    if (metadata["mediatype"] === "DIRECTORY")
                        artworkDownloader.destination = metadata["folder"] + '/' + metadata["title"] + "/Artwork/banner.jpg"
                    else
                        artworkDownloader.destination = metadata["folder"] + '/' + metadata["title"] + "/Artwork/" + Util.removeExtension(metadata["filename"]) + "_banner.jpg";

                    artworkDownloader.start(bannerEdit.text)
                }
            }
        }

        Image
        {
            id: bannerImage
            x: xscale(1120); y: yscale(235); height: yscale(100); width: xscale(100)
            fillMode: Image.PreserveAspectFit
            source: findVideoImage(metadata["folder"] + '/' + metadata["filename"], metadata["banner"], "banner")
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
            objectName: "screenshot"
            x: xscale(200); y: yscale(360)
            width: xscale(770)
            height: yscale(50)
            text: metadata["screenshot"]
            KeyNavigation.up: bannerEdit
            KeyNavigation.down: frontEdit
            KeyNavigation.right: screenshotButton
            onEditingFinished: screenshotImage.source = findVideoImage(metadata["folder"] + '/' + metadata["filename"], text, "screenshot");
        }

        BaseButton
        {
            id: screenshotButton;
            x: xscale(985)
            y: yscale(360);
            width: xscale(50); height: yscale(50)
            text: "X";
            KeyNavigation.up: bannerButton
            KeyNavigation.left: screenshotEdit
            KeyNavigation.down: frontButton
            KeyNavigation.right: screenshotDownloadButton
            onClicked:
            {
                _lastEdit = screenshotEdit;
                _lastButton = screenshotButton;
                fileDialog.showSelected(screenshotEdit.text);
            }
        }

        BaseButton
        {
            id: screenshotDownloadButton;
            x: xscale(1050)
            y: yscale(360);
            width: xscale(50); height: yscale(50)
            text: "D";
            KeyNavigation.up: bannerDownloadButton
            KeyNavigation.left: screenshotButton
            KeyNavigation.down: frontDownloadButton
            onClicked:
            {
                if (screenshotEdit.text.startsWith("http://") || screenshotEdit.text.startsWith("https://"))
                {
                    if (metadata["mediatype"] === "DIRECTORY")
                        artworkDownloader.destination = metadata["folder"] + '/' + metadata["title"] + "/Artwork/screenshot.jpg"
                    else
                        artworkDownloader.destination = metadata["folder"] + '/' + metadata["title"] + "/Artwork/" + Util.removeExtension(metadata["filename"]) + "_screenshot.jpg";

                    artworkDownloader.start(screenshotEdit.text)
                }
            }
        }

        Image
        {
            id: screenshotImage
            fillMode: Image.PreserveAspectFit
            x: xscale(1120); y: yscale(335); height: yscale(100); width: xscale(100)
            source: findVideoImage(metadata["folder"] + '/' + metadata["filename"], metadata["screenshot"], "screenshot")
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
            objectName: "front"
            x: xscale(200); y: yscale(460)
            width: xscale(770)
            height: yscale(50)
            text: metadata["front"]
            KeyNavigation.up: screenshotEdit
            KeyNavigation.down: backEdit
            KeyNavigation.right: frontButton
            onEditingFinished: frontImage.source = findVideoImage(metadata["folder"] + '/' + metadata["filename"], text, "front");
        }

        BaseButton
        {
            id: frontButton;
            x: xscale(985)
            y: yscale(460);
            width: xscale(50); height: yscale(50)
            text: "X";
            KeyNavigation.up: screenshotButton
            KeyNavigation.left: frontEdit
            KeyNavigation.down: backButton
            KeyNavigation.right: frontDownloadButton
            onClicked:
            {
                _lastEdit = frontEdit;
                _lastButton = frontButton;
                fileDialog.showSelected(frontEdit.text);
            }
        }

        BaseButton
        {
            id: frontDownloadButton;
            x: xscale(1050)
            y: yscale(460);
            width: xscale(50); height: yscale(50)
            text: "D";
            KeyNavigation.up: screenshotDownloadButton
            KeyNavigation.left: frontButton
            KeyNavigation.down: backDownloadButton
            onClicked:
            {
                if (frontEdit.text.startsWith("http://") || frontEdit.text.startsWith("https://"))
                {
                    if (metadata["mediatype"] === "DIRECTORY")
                        artworkDownloader.destination = metadata["folder"] + '/' + metadata["title"] + "/Artwork/front.jpg"
                    else
                        artworkDownloader.destination = metadata["folder"] + '/' + metadata["title"] + "/Artwork/" + Util.removeExtension(metadata["filename"]) + "_front.jpg";

                    artworkDownloader.start(frontEdit.text)
                }
            }
        }

        Image
        {
            id: frontImage
            fillMode: Image.PreserveAspectFit
            x: xscale(1120); y: yscale(435); height: yscale(100); width: xscale(100)
            //source: findVideoImage(metadata["folder"] + '/' + metadata["filename"], metadata["front"], "front")
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
            objectName: "back"
            x: xscale(200); y: yscale(560)
            width: xscale(770)
            height: yscale(50)
            text: metadata["back"]
            KeyNavigation.up: frontEdit
            KeyNavigation.down: prevButton
            KeyNavigation.right: backButton
            onEditingFinished: backImage.source = findVideoImage(metadata["folder"] + '/' + metadata["filename"], text, "back");
        }

        BaseButton
        {
            id: backButton;
            x: xscale(985)
            y: yscale(560);
            width: xscale(50); height: yscale(50)
            text: "X";
            KeyNavigation.up: frontButton
            KeyNavigation.left: backEdit
            KeyNavigation.down: saveButton
            KeyNavigation.right: backDownloadButton
            onClicked:
            {
                _lastEdit = backEdit;
                _lastButton = backButton;
                fileDialog.showSelected(backEdit.text);
            }
        }

        BaseButton
        {
            id: backDownloadButton;
            x: xscale(1050)
            y: yscale(560);
            width: xscale(50); height: yscale(50)
            text: "D";
            KeyNavigation.up: frontDownloadButton
            KeyNavigation.left: backButton
            KeyNavigation.down: saveButton
            onClicked:
            {
                if (backEdit.text.startsWith("http://") || backEdit.text.startsWith("https://"))
                {
                    if (metadata["mediatype"] === "DIRECTORY")
                        artworkDownloader.destination = metadata["folder"] + '/' + metadata["title"] + "/Artwork/back.jpg"
                    else
                        artworkDownloader.destination = metadata["folder"] + '/' + metadata["title"] + "/Artwork/" + Util.removeExtension(metadata["filename"]) + "_back.jpg";

                    artworkDownloader.start(backEdit.text)
                }
            }
        }

        Image
        {
            id: backImage
            fillMode: Image.PreserveAspectFit
            x: xscale(1120); y: yscale(535); height: yscale(100); width: xscale(100)
            source: findVideoImage(metadata["folder"] + '/' + metadata["filename"], metadata["back"], "back")
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
            objectName: "categories"
            x: xscale(400); y: yscale(100)
            width: xscale(820)
            height: yscale(48)
            text: metadata["categories"].join(", ")
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
            objectName: "studio"
            x: xscale(400); y: yscale(150)
            width: xscale(820)
            height: yscale(48)
            text: metadata["studio"]
            KeyNavigation.up: categoriesEdit
            KeyNavigation.down: hashEdit
        }

        LabelText
        {
            x: xscale(50); y: yscale(200)
            text: "File Hash:"
        }

        BaseEdit
        {
            id: hashEdit
            x: xscale(400); y: yscale(200)
            width: xscale(300)
            height: yscale(48)
            text: metadata["hash"]
            KeyNavigation.up: studioEdit
            KeyNavigation.down: websiteEdit
            KeyNavigation.left: hashButton
            KeyNavigation.right: hashButton
        }

        BaseButton
        {
            id: hashButton;
            x: xscale(710)
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
            objectName: "website"
            x: xscale(400); y: yscale(250)
            width: xscale(820)
            height: yscale(48)
            text: metadata["website"]
            KeyNavigation.up: hashEdit
            KeyNavigation.down: contenttypeSelector
        }

        ListModel
        {
            id: contenttypeModel

            ListElement
            {
                itemText: "TV"
            }
            ListElement
            {
                itemText: "MOVIE"
            }
            ListElement
            {
                itemText: "TV_SERIES"
            }
            ListElement
            {
                itemText: "TV_SEASON"
            }
        }

        LabelText
        {
            x: xscale(50); y: yscale(300)
            text: "Content Type:"
        }

        BaseSelector
        {
            id: contenttypeSelector
            x: xscale(400); y: yscale(300)
            width: xscale(300)
            height: yscale(48)
            showBackground: true
            pageCount: 5
            model: contenttypeModel

            KeyNavigation.up: websiteEdit
            KeyNavigation.down: channumEdit
            KeyNavigation.right: nsfwCheck

            Component.onCompleted: selectItem(metadata["contenttype"])
        }

        // BaseEdit
        // {
        //     id: contenttypeSelector
        //     x: xscale(400); y: yscale(300)
        //     width: xscale(200)
        //     height: yscale(48)
        //     text: metadata["contenttype"]
        //     KeyNavigation.up: websiteEdit
        //     KeyNavigation.down: channumEdit
        //     KeyNavigation.right: nsfwCheck
        // }

        LabelText
        {
            x: xscale(720); y: yscale(300)
            text: "NSFW:"
        }

        BaseCheckBox
        {
            id: nsfwCheck
            x: xscale(1020); y: yscale(300)
            checked: metadata["nsfw"]
            KeyNavigation.up: contenttypeSelector
            KeyNavigation.down: callsignEdit
            KeyNavigation.left: contenttypeSelector
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
            width: xscale(300)
            height: yscale(48)
            text: metadata["channum"]
            KeyNavigation.up: nsfwCheck
            KeyNavigation.down: starttsEdit
            KeyNavigation.right: callsignEdit
        }

        LabelText
        {
            x: xscale(720); y: yscale(350)
            text: "Channel Callsign:"
        }

        BaseEdit
        {
            id: callsignEdit
            x: xscale(1020); y: yscale(350)
            width: xscale(200)
            height: yscale(48)
            text: metadata["callsign"]
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
            text: metadata["startts"]
            KeyNavigation.up: channumEdit
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
            objectName: "releasedate"
            x: xscale(400); y: yscale(450)
            width: xscale(820)
            height: yscale(48)
            text: metadata["releasedate"]
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
            objectName: "runtime"
            x: xscale(400); y: yscale(500)
            width: xscale(200)
            height: yscale(48)
            text: metadata["runtime"]
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
            x: xscale(720); y: yscale(500)
            text: "Run Time (Seconds):"
        }

        BaseEdit
        {
            id: runtimesecEdit
            x: xscale(1020); y: yscale(500)
            width: xscale(200)
            height: yscale(48)
            text: metadata["runtimesecs"]
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

            Component.onCompleted: selectItem(metadata["status"])
        }
    }

    // page 4
    Item
    {
        id: page4
        anchors.fill: parent
        visible: false

        BaseBackground
        {
            id: listBackground
            x: xscale(10); y: yscale(65); width: (parent.width / 2) - x - xscale(5); height: yscale(410)
        }

        TitleText
        {
            x: xscale(20)
            y: yscale(75)
            fontPixelSize: yscale(25)
            width: (parent.width / 2) - x - xscale(5);
            text: "Movie/Series Metadata ID's";
        }

        LabelText
        {
            x: xscale(30); y: yscale(120)
            text: "IMDB ID:"
        }

        BaseEdit
        {
            id: imdbEdit
            objectName: "inetref/series/imdbID"
            x: xscale(200); y: yscale(120)
            width: xscale(300)
            height: yscale(48)
            text: metadata["inetref"]["series"]["imdbID"]
            KeyNavigation.up: saveButton
            KeyNavigation.down: tmdbEdit
            KeyNavigation.right: imdbButton
            KeyNavigation.left: episodeImdbWebButton
        }

        BaseButton
        {
            id: imdbButton
            x: xscale(510)
            y: yscale(120)
            width: xscale(50); height: yscale(50)
            text: "X"
            KeyNavigation.up: saveButton
            KeyNavigation.down: tmdbButton
            KeyNavigation.left: imdbEdit
            KeyNavigation.right: imdbWebButton

            onClicked:
            {
                var jsonObj = { "commandType": "Metadata Grabber", "grabber": "IMDB", "queryType": "Search", "title": titleEdit.text }
                sendCommandToHelper(JSON.stringify(jsonObj));
            }
        }

        BaseButton
        {
            id: imdbWebButton
            x: xscale(570)
            y: yscale(120)
            width: xscale(50); height: yscale(50)
            text: "W"
            KeyNavigation.up: saveButton
            KeyNavigation.down: tmdbWebButton
            KeyNavigation.left: imdbButton
            KeyNavigation.right: episodeImdbEdit

            onClicked:
            {
                var zoom = xscale(1.0);
                var url = "https://www.imdb.com/title/" + imdbEdit.text
                stack.push({item: Qt.resolvedUrl("WebBrowser.qml"), properties:{url: url, zoomFactor: zoom}});
            }
        }

        LabelText
        {
            x: xscale(30); y: yscale(170)
            text: "TMDB ID:"
        }

        BaseEdit
        {
            id: tmdbEdit
            objectName: "inetref/series/tmdbID"
            x: xscale(200); y: yscale(170)
            width: xscale(300)
            height: yscale(48)
            text: metadata["inetref"]["series"]["tmdbID"]
            KeyNavigation.up: imdbEdit
            KeyNavigation.down: thetvdbEdit
            KeyNavigation.right: tmdbButton
            KeyNavigation.left: episodeTmdbWebButton
        }

        BaseButton
        {
            id: tmdbButton
            x: xscale(510)
            y: yscale(170)
            width: xscale(50); height: yscale(50)
            text: "X"
            KeyNavigation.up: imdbButton
            KeyNavigation.down: thetvdbButton
            KeyNavigation.left: tmdbEdit
            KeyNavigation.right: tmdbWebButton

            onClicked:
            {
                var jsonObj;

                if (contenttypeSelector.getSelected() === "TV")
                    jsonObj = { "commandType": "Metadata Grabber", "grabber": "TMDB", "queryType": "TVSearch", "title": titleEdit.text }
                else
                    jsonObj = { "commandType": "Metadata Grabber", "grabber": "TMDB", "queryType": "MovieSearch", "title": titleEdit.text }

                sendCommandToHelper(JSON.stringify(jsonObj));
            }
        }

        BaseButton
        {
            id: tmdbWebButton
            x: xscale(570)
            y: yscale(170)
            width: xscale(50); height: yscale(50)
            text: "W"
            KeyNavigation.up: imdbWebButton
            KeyNavigation.down: thetvdbWebButton
            KeyNavigation.left: tmdbButton
            KeyNavigation.right: episodeTmdbEdit

            onClicked:
            {
                var zoom = xscale(1.0);
                var url = "https://www.themoviedb.org/tv/" + tmdbEdit.text
                stack.push({item: Qt.resolvedUrl("WebBrowser.qml"), properties:{url: url, zoomFactor: zoom}});
            }
        }

        LabelText
        {
            x: xscale(30); y: yscale(220)
            text: "TheTVDB ID:"
        }

        BaseEdit
        {
            id: thetvdbEdit
            objectName: "inetref/series/thetvdbID"
            x: xscale(200); y: yscale(220)
            width: xscale(300)
            height: yscale(48)
            text: metadata["inetref"]["series"]["thetvdbID"]
            KeyNavigation.up: tmdbEdit
            KeyNavigation.down: tvmazeEdit
            KeyNavigation.right: thetvdbButton
            KeyNavigation.left: episodeThetvdbWebButton
        }

        BaseButton
        {
            id: thetvdbButton
            x: xscale(510)
            y: yscale(220)
            width: xscale(50); height: yscale(50)
            text: "X"
            KeyNavigation.up: tmdbButton
            KeyNavigation.down: tvmazeButton
            KeyNavigation.left: thetvdbEdit
            KeyNavigation.right: thetvdbWebButton

            onClicked:
            {
                var jsonObj = { "commandType": "Metadata Grabber", "grabber": "THETVDB", "queryType": "Search", "title": titleEdit.text, "resultKind": "Summary" }
                sendCommandToHelper(JSON.stringify(jsonObj));
            }
        }

        BaseButton
        {
            id: thetvdbWebButton;
            x: xscale(570)
            y: yscale(220)
            width: xscale(50); height: yscale(50)
            text: "W"
            KeyNavigation.up: tmdbWebButton
            KeyNavigation.down: tvmazeWebButton
            KeyNavigation.left: thetvdbButton
            KeyNavigation.right: episodeThetvdbEdit

            onClicked:
            {
                //FIXME I don't see a way to see this website using the Series ID number you have to use the slug from the API
                if (thetvdbSearchResult != undefined)
                {
                    var slug = thetvdbSearchResult["slug"];
                    var zoom = xscale(1.0);
                    var url = "https://thetvdb.com/series/" + slug;
                    stack.push({item: Qt.resolvedUrl("WebBrowser.qml"), properties:{url: url, zoomFactor: zoom}});
                }
            }
        }

        LabelText
        {
            x: xscale(30); y: yscale(270)
            text: "TVMaze ID:"
        }

        BaseEdit
        {
            id: tvmazeEdit
            objectName: "inetref/series/tvmazeID"
            x: xscale(200); y: yscale(270)
            width: xscale(300)
            height: yscale(48)
            text: metadata["inetref"]["series"]["tvmazeID"]
            KeyNavigation.up: thetvdbEdit
            KeyNavigation.down: fanartIDEdit
            KeyNavigation.right: tvmazeButton
            KeyNavigation.left: episodeTvmazeWebButton
        }

        BaseButton
        {
            id: tvmazeButton
            x: xscale(510)
            y: yscale(270)
            width: xscale(50); height: yscale(50)
            text: "X"
            KeyNavigation.up: thetvdbButton
            KeyNavigation.down: fanartIDButton
            KeyNavigation.left: tvmazeEdit
            KeyNavigation.right: tvmazeWebButton

            onClicked:
            {
                var jsonObj;

                if (contenttypeSelector.getSelected() === "TV" && thetvdbEdit.text != "")
                {
                    jsonObj = { "commandType": "Metadata Grabber", "grabber": "TVMAZE", "queryType": "ShowLookupTHETVDB", "thetvdbID": Number(thetvdbEdit.text) }
                }
                else if (contenttypeSelector.getSelected() === "TV" && imdbEdit.text != "")
                {
                    jsonObj = { "commandType": "Metadata Grabber", "grabber": "TVMAZE", "queryType": "ShowLookupIMDB", "imdbID": imdbEdit.text }
                }
                else if (contenttypeSelector.getSelected() === "TV")
                    jsonObj = { "commandType": "Metadata Grabber", "grabber": "TVMAZE", "queryType": "ShowSearch", "title": titleEdit.text }
                else
                {
                    showNotification("The TVMaze grabber can only search for TV shows.", settings.osdTimeoutMedium);
                    return;
                }

                sendCommandToHelper(JSON.stringify(jsonObj));
            }
        }

        BaseButton
        {
            id: tvmazeWebButton
            x: xscale(570)
            y: yscale(270)
            width: xscale(50); height: yscale(50)
            text: "W";
            KeyNavigation.up: thetvdbWebButton
            KeyNavigation.down: fanartWebButton
            KeyNavigation.left: tvmazeButton
            KeyNavigation.right: episodeTvmazeEdit

            onClicked:
            {
                var zoom = xscale(1.0);
                var url = "https://www.tvmaze.com/shows/" + tvmazeEdit.text
                stack.push({item: Qt.resolvedUrl("WebBrowser.qml"), properties:{url: url, zoomFactor: zoom}});
            }
        }

        LabelText
        {
            x: xscale(30); y: yscale(320)
            text: "Fanart ID:"
        }

        BaseEdit
        {
            id: fanartIDEdit
            objectName: "inetref/series/fanartID"
            x: xscale(200); y: yscale(320)
            width: xscale(300)
            height: yscale(48)
            text: metadata["inetref"]["series"]["fanartID"]
            KeyNavigation.up: tvmazeEdit
            KeyNavigation.down: findBestButton
            KeyNavigation.right: fanartIDButton
            KeyNavigation.left: episodeFanartWebButton
        }

        BaseButton
        {
            id: fanartIDButton
            x: xscale(510)
            y: yscale(320)
            width: xscale(50); height: yscale(50)
            text: "X";
            KeyNavigation.up: tvmazeButton
            KeyNavigation.down: findBestButton
            KeyNavigation.left: fanartIDEdit
            KeyNavigation.right: fanartWebButton

            onClicked:
            {
                var jsonObj;

                if (contenttypeSelector.getSelected() === "TV")
                {
                    if (thetvdbEdit.text != "")
                        jsonObj = { "commandType": "Metadata Grabber", "grabber": "FANART", "queryType": "Show", "thetvdbID": thetvdbEdit.text }
                    else
                    {
                        showNotification("TV shows need a THETVDB ID to search for fanart.", settings.osdTimeoutMedium);
                        return;
                    }
                }
                else
                {
                    if (imdbEdit.text != "")
                        jsonObj = { "commandType": "Metadata Grabber", "grabber": "FANART", "queryType": "Movie", "imdbID": imdbEdit.text }
                    else
                    {
                        showNotification("Movies need a IMDB ID to search for fanart.", settings.osdTimeoutMedium);
                        return;
                    }
                }

                sendCommandToHelper(JSON.stringify(jsonObj));
            }
        }

        BaseButton
        {
            id: fanartWebButton
            x: xscale(570)
            y: yscale(320)
            width: xscale(50); height: yscale(50)
            text: "W";
            KeyNavigation.up: tvmazeWebButton
            KeyNavigation.down: findBestButton
            KeyNavigation.left: fanartIDButton
            KeyNavigation.right: episodeFanartEdit

            onClicked:
            {
                var zoom = xscale(1.0);
                var url = "https://fanart.tv/series/" + fanartEdit.text
                stack.push({item: Qt.resolvedUrl("WebBrowser.qml"), properties:{url: url, zoomFactor: zoom}});
            }
        }

        BaseBackground
        {
            id: episodeBackground
            x: xscale(645); y: yscale(65); width: (parent.width / 2) - xscale(15); height: yscale(410)
        }

        TitleText
        {
            x: xscale(655)
            y: yscale(75)
            fontPixelSize: xscale(25)
            width: (parent.width / 2) + x - xscale(5);
            text: "Episode Metadata ID's";
        }

        LabelText
        {
            x: xscale(665); y: yscale(120)
            text: "IMDB ID:"
        }

        BaseEdit
        {
            id: episodeImdbEdit
            x: xscale(835); y: yscale(120)
            width: xscale(300)
            height: yscale(48)
            text: metadata["inetref"]["episode"]["imdbID"]
            KeyNavigation.up: saveButton
            KeyNavigation.down: episodeTmdbEdit
            KeyNavigation.right: episodeImdbButton
            KeyNavigation.left: imdbWebButton
        }

        BaseButton
        {
            id: episodeImdbButton
            x: xscale(1145)
            y: yscale(120)
            width: xscale(50); height: yscale(50)
            text: "X";
            KeyNavigation.up: saveButton
            KeyNavigation.down: episodeTmdbButton
            KeyNavigation.left: episodeImdbEdit
            KeyNavigation.right: episodeImdbWebButton

            onClicked:
            {
                var jsonObj;

                if (contenttypeSelector.getSelected() === "TV")
                {
                    if (imdbEdit.text != "")
                        jsonObj = { "commandType": "Metadata Grabber", "grabber": "IMDB", "queryType": "Episodes", "imdbID": imdbEdit.text };
                    else
                    {
                        showNotification("TV shows need a IMDB ID to search for an episode IMDB ID.", settings.osdTimeoutMedium);
                        return;
                    }
                }
                else
                {
                    showNotification("Only TV shows have a episode IMDB ID.", settings.osdTimeoutMedium);
                    return;
                }

                sendCommandToHelper(JSON.stringify(jsonObj));
            }
        }

        BaseButton
        {
            id: episodeImdbWebButton
            x: xscale(1205)
            y: yscale(120)
            width: xscale(50); height: yscale(50)
            text: "W";
            KeyNavigation.up: saveButton
            KeyNavigation.down: episodeTmdbWebButton
            KeyNavigation.left: episodeImdbButton
            KeyNavigation.right: imdbEdit

            onClicked:
            {
                var zoom = xscale(1.0);
                var url = "https://www.imdb.com/title/" + episodeImdbEdit.text
                stack.push({item: Qt.resolvedUrl("WebBrowser.qml"), properties:{url: url, zoomFactor: zoom}});
            }
        }

        LabelText
        {
            x: xscale(665); y: yscale(170)
            text: "TMDB ID:"
        }

        BaseEdit
        {
            id: episodeTmdbEdit
            x: xscale(835); y: yscale(170)
            width: xscale(300)
            height: yscale(48)
            text: metadata["inetref"]["episode"]["tmdbID"]
            KeyNavigation.up: episodeImdbEdit
            KeyNavigation.down: episodeThetvdbEdit
            KeyNavigation.right: episodeTmdbButton
            KeyNavigation.left: tmdbWebButton
        }

        BaseButton
        {
            id: episodeTmdbButton
            x: xscale(1145)
            y: yscale(170)
            width: xscale(50); height: yscale(50)
            text: "X";
            KeyNavigation.up: episodeImdbButton
            KeyNavigation.down: episodeThetvdbButton
            KeyNavigation.left: episodeTmdbEdit
            KeyNavigation.right: episodeTmdbWebButton

            onClicked:
            {
                var jsonObj;

                if (contenttypeSelector.getSelected() === "TV")
                {
                    if (tmdbEdit.text != "")
                        jsonObj = { "commandType": "Metadata Grabber", "grabber": "TMDB", "queryType": "TVEpisodes", "tmdb3ID": tmdbEdit.text }
                    else
                    {
                        showNotification("TV shows need a THETVDB ID to search for an episode THETVDB ID.", settings.osdTimeoutMedium);
                        return;
                    }
                }
                else
                {
                    showNotification("Only TV shows have an episode THETVDB ID.", settings.osdTimeoutMedium);
                    return;
                }

                sendCommandToHelper(JSON.stringify(jsonObj));
            }
        }

        BaseButton
        {
            id: episodeTmdbWebButton
            x: xscale(1205)
            y: yscale(170)
            width: xscale(50); height: yscale(50)
            text: "W";
            KeyNavigation.up: episodeImdbWebButton
            KeyNavigation.down: episodeThetvdbWebButton
            KeyNavigation.left: episodeTmdbButton
            KeyNavigation.right: tmdbEdit

            onClicked:
            {
                var zoom = xscale(1.0);
                var url = "https://www.themoviedb.org/tv/" + episodeTmdbEdit.text
                stack.push({item: Qt.resolvedUrl("WebBrowser.qml"), properties:{url: url, zoomFactor: zoom}});
            }
        }

        LabelText
        {
            x: xscale(665); y: yscale(220)
            text: "TheTVDB ID:"
        }

        BaseEdit
        {
            id: episodeThetvdbEdit
            x: xscale(835); y: yscale(220)
            width: xscale(300)
            height: yscale(48)
            text: metadata["inetref"]["episode"]["thetvdbID"]
            KeyNavigation.up: episodeTmdbEdit
            KeyNavigation.down: episodeTvmazeEdit
            KeyNavigation.right: episodeThetvdbButton
            KeyNavigation.left: thetvdbWebButton
        }

        BaseButton
        {
            id: episodeThetvdbButton
            x: xscale(1145)
            y: yscale(220)
            width: xscale(50); height: yscale(50)
            text: "X";
            KeyNavigation.up: episodeTmdbButton
            KeyNavigation.down: episodeTvmazeButton
            KeyNavigation.left: episodeThetvdbEdit
            KeyNavigation.right: episodeThetvdbWebButton

            onClicked:
            {
                var jsonObj;

                if (contenttypeSelector.getSelected() === "TV")
                {
                    if (thetvdbEdit.text != "")
                        jsonObj = { "commandType": "Metadata Grabber", "grabber": "THETVDB", "queryType": "Episodes", "thetvdbID": thetvdbEdit.text };
                    else
                    {
                        showNotification("TV shows need a THETVDB ID to search for an episode THETVDB ID.", settings.osdTimeoutMedium);
                        return;
                    }
                }
                else
                {
                    showNotification("Only TV shows have a episode THETVDB ID.", settings.osdTimeoutMedium);
                    return;
                }

                sendCommandToHelper(JSON.stringify(jsonObj));
            }
        }

        BaseButton
        {
            id: episodeThetvdbWebButton
            x: xscale(1205)
            y: yscale(220)
            width: xscale(50); height: yscale(50)
            text: "W";
            KeyNavigation.up: episodeTmdbWebButton
            KeyNavigation.down: episodeTvmazeWebButton
            KeyNavigation.left: episodeThetvdbButton
            KeyNavigation.right: thetvdbEdit

            onClicked:
            {
                var zoom = xscale(1.0);
                var url = "https://www.themoviedb.org/tv/" + episodeTmdbEdit.text
                stack.push({item: Qt.resolvedUrl("WebBrowser.qml"), properties:{url: url, zoomFactor: zoom}});
            }
        }

        LabelText
        {
            x: xscale(665); y: yscale(270)
            text: "TVMaze ID:"
        }

        BaseEdit
        {
            id: episodeTvmazeEdit
            x: xscale(835); y: yscale(270)
            width: xscale(300)
            height: yscale(48)
            text: metadata["inetref"]["episode"]["tvmazeID"]
            KeyNavigation.up: episodeThetvdbEdit
            KeyNavigation.down: episodeFanartEdit
            KeyNavigation.right: episodeTvmazeButton
            KeyNavigation.left: tvmazeWebButton
        }

        BaseButton
        {
            id: episodeTvmazeButton
            x: xscale(1145)
            y: yscale(270)
            width: xscale(50); height: yscale(50)
            text: "X";
            KeyNavigation.up: episodeThetvdbButton
            KeyNavigation.down: episodeFanartIDButton
            KeyNavigation.left: episodeTvmazeEdit
            KeyNavigation.right: episodeTvmazeWebButton

            onClicked:
            {
                var jsonObj;

                if (contenttypeSelector.getSelected() === "TV")
                {
                    if (tvmazeEdit.text != "")
                        var jsonObj = { "commandType": "Metadata Grabber", "grabber": "TVMAZE", "queryType": "ShowEpisodes", "tvmazeID": tvmazeEdit.text };
                    else
                    {
                        showNotification("TV shows need a TVMAZE ID to search for an episode TVMAZE ID.", settings.osdTimeoutMedium);
                        return;
                    }
                }
                else
                {
                    showNotification("Only TV shows have a episode TVMAZE ID.", settings.osdTimeoutMedium);
                    return;
                }

                sendCommandToHelper(JSON.stringify(jsonObj));
            }
        }

        BaseButton
        {
            id: episodeTvmazeWebButton
            x: xscale(1205)
            y: yscale(270)
            width: xscale(50); height: yscale(50)
            text: "W";
            KeyNavigation.up: episodeThetvdbWebButton
            KeyNavigation.down: episodeFanartWebButton
            KeyNavigation.left: episodeTvmazeButton
            KeyNavigation.right: tvmazeEdit

            onClicked:
            {
                var zoom = xscale(1.0);
                var url = "https://www.tvmaze.com/episodes/" + episodeTvmazeEdit.text
                stack.push({item: Qt.resolvedUrl("WebBrowser.qml"), properties:{url: url, zoomFactor: zoom}});
            }
        }

        LabelText
        {
            x: xscale(665); y: yscale(320)
            text: "Fanart ID:"
        }

        BaseEdit
        {
            id: episodeFanartEdit
            x: xscale(835); y: yscale(320)
            width: xscale(300)
            height: yscale(48)
            text: metadata["inetref"]["episode"]["fanartID"]
            KeyNavigation.up: episodeTvmazeEdit
            KeyNavigation.down: findBestButton
            KeyNavigation.right: episodeFanartIDButton
            KeyNavigation.left: fanartWebButton

        }

        BaseButton
        {
            id: episodeFanartIDButton
            x: xscale(1145)
            y: yscale(320)
            width: xscale(50); height: yscale(50)
            text: "X";
            KeyNavigation.up: episodeTvmazeButton
            KeyNavigation.down: findBestButton
            KeyNavigation.left: episodeFanartEdit
            KeyNavigation.right: episodeFanartWebButton

            onClicked:
            {
                var jsonObj;

                if (contenttypeSelector.getSelected() === "TV")
                {
                    if (episodeThetvdbEdit.text != "")
                        jsonObj = { "commandType": "Metadata Grabber", "grabber": "FANART", "queryType": "Show", "thetvdbID": episodeThetvdbEdit.text }
                    else
                    {
                        showNotification("TV shows episodes need a episode THETVDB ID to search for fanart.", settings.osdTimeoutMedium);
                        return;
                    }
                }
                else
                {
                    if (episodeImdbEdit.text != "")
                        jsonObj = { "commandType": "Metadata Grabber", "grabber": "FANART", "queryType": "Movie", "imdbID": episodeImdbEdit.text }
                    else
                    {
                        showNotification("Movies need a IMDB ID to search for fanart.", settings.osdTimeoutMedium);
                        return;
                    }
                }

                sendCommandToHelper(JSON.stringify(jsonObj));
            }
        }

        BaseButton
        {
            id: episodeFanartWebButton
            x: xscale(1205)
            y: yscale(320)
            width: xscale(50); height: yscale(50)
            text: "W";
            KeyNavigation.up: episodeTvmazeWebButton
            KeyNavigation.down: findBestButton
            KeyNavigation.left: episodeFanartIDButton
            KeyNavigation.right: fanartIDEdit

            onClicked:
            {
                var zoom = xscale(1.0);
                var url = "https://fanart.tv/series/" + episodeFanartEdit.text
                stack.push({item: Qt.resolvedUrl("WebBrowser.qml"), properties:{url: url, zoomFactor: zoom}});
            }
        }

        BaseButton
        {
            id: findBestButton;
            x: xscale(485); y: yscale(500); width: xscale(300)
            text: "Find Missing Metadata";

            KeyNavigation.up: fanartIDEdit
            KeyNavigation.down: nextButton
            KeyNavigation.right: saveButton
            KeyNavigation.left: prevButton
            onClicked: findMissingMetadata()
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
            else if (_currentPage === 4)
                findBestButton
        }
        KeyNavigation.down:
        {
            if (_currentPage === 1)
                titleEdit
            else if (_currentPage === 2)
                coverartEdit
            else if (_currentPage === 3)
                categoriesEdit
            else if (_currentPage === 4)
                imdbEdit

        }
        KeyNavigation.right: nextButton
        KeyNavigation.left: saveButton

        onClicked: previousPage()
    }

    BaseButton
    {
        id: nextButton;
        x: xscale(400); y: yscale(620);
        text: "Next Page";
        KeyNavigation.up:
        {
            if (_currentPage === 1)
                taglineEdit
            else if (_currentPage === 2)
                backEdit
            else if (_currentPage === 3)
                statusSelector
            else if (_currentPage === 4)
                findBestButton
        }
        KeyNavigation.down:
        {
            if (_currentPage === 1)
                titleEdit
            else if (_currentPage === 2)
                coverartEdit
            else if (_currentPage === 3)
                categoriesEdit
            else if (_currentPage === 4)
                imdbButton

        }
        KeyNavigation.right: saveButton
        KeyNavigation.left: prevButton
        onClicked: nextPage();
    }

    BaseButton
    {
        id: saveButton;
        x: xscale(900); y: yscale(620);
        text: "Save";
        KeyNavigation.up:
        {
            if (_currentPage === 1)
                taglineEdit
            else if (_currentPage === 2)
                backEdit
            else if (_currentPage === 3)
                statusSelector
            else if (_currentPage === 4)
                episodeFanartEdit
        }

        KeyNavigation.down:
        {
            if (_currentPage === 1)
                titleEdit
            else if (_currentPage === 2)
                coverartEdit
            else if (_currentPage === 3)
                categoriesEdit
            else if (_currentPage === 4)
                episodeImdbEdit

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
        source: findVideoImage(metadata["folder"] + '/' + metadata["filename"], metadata["back"], "back")
        onStatusChanged: if (status == Image.Error) source = mythUtils.findThemeFile("images/grid_noimage.png");
    }

    // FileDirectoryDialog
    // {
    //     id: fileDialog

    //     property bool searchWebsites: true
    //     title: "Choose an image file"
    //     message: ""

    //     onAccepted:
    //     {
    //         _lastButton.focus = true;
    //     }
    //     onCancelled:
    //     {
    //         _lastButton.focus = true;
    //     }

    //     onItemSelected: itemText =>
    //     {
    //         _lastEdit.text = itemText;
    //         _lastButton.focus = true;
    //     }
    // }

    PopupMenu
    {
        id: popupMenu

        title: "Menu"
        message: "Metadata Editor Options"

        onItemSelected: (itemText, itemData) =>
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
                else if (type == "SCRIPT")
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

    PopupMenu
    {
        id: inetrefPopupMenu

        title: "Grabber Menu"
        message: "Metadata Grabber Options"

        onItemSelected:
        {
            var jsonObj;

            if (itemData == "IMDB")
            {
                jsonObj = { "commandType": "Metadata Grabber", "grabber": "IMDB", "queryType": "Search", "title": titleEdit.text }
                sendCommandToHelper(JSON.stringify(jsonObj));
            }
            else if (itemData == "TMDB")
            {
                if (contenttypeSelector.getSelected() == "TV")
                    jsonObj = { "commandType": "Metadata Grabber", "grabber": "TMDB", "queryType": "TVSearch", "title": titleEdit.text }
                else
                    jsonObj = { "commandType": "Metadata Grabber", "grabber": "TMDB", "queryType": "MovieSearch", "title": titleEdit.text }

                sendCommandToHelper(JSON.stringify(jsonObj));
            }
            else if (itemData == "THETVDB")
            {
                jsonObj = { "commandType": "Metadata Grabber", "grabber": "THETVDB", "queryType": "Search", "title": titleEdit.text }
                sendCommandToHelper(JSON.stringify(jsonObj));
            }
            else if (itemData == "TVMAZE")
            {
                if (contenttypeSelector.getSelected() == "TV")
                    jsonObj = { "commandType": "Metadata Grabber", "grabber": "TVMAZE", "queryType": "ShowSearch", "title": titleEdit.text }
                else
                    showNotification("The TVMaze grabber only has data for TV shows", settings.osdTimeoutMedium);
            }
            else if (itemData == "FANART")
            {

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

        onItemSelected: itemText =>
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
            else if (searchItem === "inetref/series/imdbID")
                imdbEdit.text = itemText;
            else if (searchItem === "inetref/series/tmdbID")
                tmdbEdit.text = itemText;
            else if (searchItem === "inetref/series/thetvdbID")
                thetvdbEdit.text = itemText;
            else if (searchItem === "inetref/series/tvmazeID")
                tvmazeEdit.text = itemText;
            else if (searchItem === "inetref/series/fanartID")
                fanartIDEdit.text = itemText;
            else if (searchItem === "search_imdb")
                imdbEdit.text = itemText;
            else if (searchItem === "search_tmdb")
                tmdbEdit.text = itemText;
            else if (searchItem === "search_thetvdb")
                thetvdbEdit.text = itemText;
            else if (searchItem === "search_tvmaze")
                tvmazeEdit.text = itemText;
            else if (searchItem === "search_imdb_episodes")
                episodeImdbEdit.text = itemText;
            else if (searchItem === "search_tmdb_episodes")
                episodeTmdbEdit.text = itemText;
            else if (searchItem === "search_thetvdb_episodes")
                episodeThetvdbEdit.text = itemText;
            else if (searchItem === "search_tvmaze_episodes")
                episodeTvmazeEdit.text = itemText;
            else if (searchItem === "search_fanart")
                fanartIDEdit.text = itemText;
        }
    }

    function showSearchResults(grabber)
    {
        searchResultModel.clear();

        var result, x, no, id, title, year, image, credits, creditsList;

        if (grabber === "IMDB" && imdbSearchResult !== undefined)
        {
            for (x = 0; x < imdbSearchResult.length; x++)
            {
                result = imdbSearchResult[x].listItem;
                no = String(x).padStart(2, '0') + ": ";
                id = imdbSearchResult[x].index;
                title = result.titleText;
                year =  "releaseYear" in result ? result.releaseYear : "N/A";
                image = "primaryImage" in result ? result.primaryImage.url : "N/A";
                credits = "";
                creditsList = result.principalCredits
                if (creditsList != undefined)
                    credits = creditsList.join(", ");

                searchResultModel.append({"source": id, "title": title, "year": year, "credits": credits, "icon": image, "item": title + "(" + year + ") - " + credits, "data": id});
            }

            searchDialog.searchItem = "search_imdb";
        }

        if (grabber === "TMDB Movie Search" && tmdbSearchResult !== undefined)
        {
            var baseUrl = tmdbConfig.images.base_url + "original"

            for (x = 0; x < tmdbSearchResult.length; x++)
            {
                result = tmdbSearchResult[x];
                no = String(x).padStart(2, '0') + ": ";
                id = result.id;
                title = result.title;
                year =  "release_date" in result ? result.release_date : "N/A";
                image = "poster_path" in result ? result.poster_path : "";
                if (image === "")
                    image = "backdrop_path" in result ? result.backdrop_path : "";
                credits = "";
                searchResultModel.append({"source": id, "title": title, "year": year, "credits": credits, "icon": baseUrl + image, "item": title + "(" + year + ") - " + credits, "data": id });
            }

            searchDialog.searchItem = "search_tmdb";
        }

        if (grabber === "TMDB TV Search" && tmdbSearchResult !== undefined)
        {
            var baseUrl = tmdbConfig.images.base_url + "original"

            for (x = 0; x < tmdbSearchResult.length; x++)
            {
                result = tmdbSearchResult[x];
                no = String(x).padStart(2, '0') + ": ";
                id = result.id;
                title = result.name;
                year =  "first_air_date" in result ? result.first_air_date : "N/A";
                image = "poster_path" in result ? result.backdrop_path : "";
                credits = "";
                searchResultModel.append({"source": id, "title": title, "year": year, "credits": credits, "icon": baseUrl + image, "item": title + "(" + year + ") - " + credits, "data": id });
            }

            searchDialog.searchItem = "search_tmdb";
        }

        if (grabber === "THETVDB" && thetvdbSearchResult !== undefined)
        {
            for (x = 0; x < thetvdbSearchResult.length; x++)
            {
                result = thetvdbSearchResult[x];
                no = String(x).padStart(2, '0') + ": ";
                id = result.id;
                title = result.title;
                year =  result.year
                image = result.image
                credits = "";

                searchResultModel.append({"source": id, "title": title, "year": year, "credits": credits, "icon": image, "item": title + "(" + year + ") - " + credits, "data": id });
            }

            searchDialog.searchItem = "search_thetvdb";
        }

        if (grabber === "TVMAZE" && tvmazeSearchResult !== undefined)
        {
            no = String(x).padStart(2, '0') + ": ";
            id = tvmazeSearchResult.id;
            title = tvmazeSearchResult.name;
            year = tvmazeSearchResult.premiered;
            image = tvmazeSearchResult.image.original;
            credits = "";
            searchResultModel.append({"source": id, "title": title, "year": year, "credits": credits, "icon": image, "item": title + "(" + year + ") - " + credits, "data": id });

            searchDialog.searchItem = "search_tvmaze";
        }

        if (grabber === "IMDB_EPISODES" && imdbEpisodes !== undefined)
        {
            for (x = 0; x < imdbEpisodes.length; x++)
            {
                result = imdbEpisodes[x];
                no = String(x).padStart(2, '0') + ": ";
                id = result.id;
                title = result.title;
                year =  result.releaseDate
                image = result.image ? result.image : ""
                credits = "";

                searchResultModel.append({"source": id, "title": title, "year": year, "credits": credits, "icon": image, "item": title + "(" + year + ") - " + credits, "data": id });
            }

            searchDialog.searchItem = "search_imdb_episodes";
        }

        if (grabber === "TMDB_EPISODES" && tmdbEpisodes !== undefined)
        {
            for (x = 0; x < tmdbEpisodes.length; x++)
            {
                result = tmdbEpisodes[x];
                no = String(x).padStart(2, '0') + ": ";
                id = result.id;
                title = result.title;
                year =  result.release_date
                image = result.image ? result.image : ""
                credits = "";

                searchResultModel.append({"source": id, "title": title, "year": year, "credits": credits, "icon": image, "item": title + "(" + year + ") - " + credits, "data": id });
            }

            searchDialog.searchItem = "search_tmdb_episodes";
        }

        if (grabber === "THETVDB_EPISODES" && thetvdbEpisodes !== undefined)
        {
            for (x = 0; x < thetvdbEpisodes.length; x++)
            {
                result = thetvdbEpisodes[x];
                no = String(x).padStart(2, '0') + ": ";
                id = result.id;
                title = result.name;
                year =  result.aired
                image = result.image ? result.image : ""
                credits = "";

                searchResultModel.append({"source": id, "title": title, "year": year, "credits": credits, "icon": image, "item": title + "(" + year + ") - " + credits, "data": id });
            }

            searchDialog.searchItem = "search_thetvdb_episodes";
        }

        if (grabber === "TVMAZE_EPISODES" && tvmazeEpisodes !== undefined)
        {
            for (x = 0; x < tvmazeEpisodes.length; x++)
            {
                result = tvmazeEpisodes[x];
                no = String(x).padStart(2, '0') + ": ";
                id = result.id;
                title = result.name;
                year =  result.airdate
                image = result.image ? result.image.original : ""
                credits = "";

                searchResultModel.append({"source": id, "title": title, "year": year, "credits": credits, "icon": image, "item": title + "(" + year + ") - " + credits, "data": id });
            }

            searchDialog.searchItem = "search_tvmaze_episodes";
        }

        if (searchResultModel.count > 0)
        {
            searchDialog.displayField = "item";
            searchDialog.dataField = "data";
            searchDialog.sortField = "";
            searchDialog.delegate = imageSearchDelegate;
            searchDialog.model = searchResultModel;

            searchDialog.show();
        }
        else
            showNotification("No search results found for this metadata grabber.", settings.osdTimeoutMedium);
    }

    function previousPage()
    {
        if (_currentPage == 1)
            _currentPage = 4;
        else
            _currentPage--;

        switchPage();
    }

    function nextPage()
    {
        if (_currentPage == 4)
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
            page4.visible = false;
            titleEdit.focus = true;
            showTitle(true, "Video Metadata Editor (Page 1)");
            returnSound.play();
        }
        else if (_currentPage == 2)
        {
            page1.visible = false;
            page2.visible = true;
            page3.visible = false;
            page4.visible = false;
            coverartEdit.focus = true;
            showTitle(true, "Video Metadata Editor (Page 2)");
            returnSound.play();
        }
        else if (_currentPage == 3)
        {
            page1.visible = false;
            page2.visible = false;
            page3.visible = true;
            page4.visible = false;
            categoriesEdit.focus = true;
            showTitle(true, "Video Metadata Editor (Page 3)");
            returnSound.play();
        }
        else if (_currentPage == 4)
        {
            page1.visible = false;
            page2.visible = false;
            page3.visible = false;
            page4.visible = true;
            imdbEdit.focus = true;
            showTitle(true, "Metadata Grabber Inetref's (Page 4)");
            returnSound.play();
        }
    }

    function findXMLMetadata()
    {
        var videoFile = metadata["folder"] + '/' + metadata["filename"];
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
        metadata["title"] = titleEdit.text;
        metadata["subtitle"] = subtitleEdit.text;
        metadata["description"] = descriptionEdit.text;
        metadata["season"] = seasonEdit.text;
        metadata["episode"] = episodeEdit.text;
        metadata["tagline"] = taglineEdit.text;

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

        //metadata["categoriesJSON"] = catStr;          // we save this to the DB
        //metadata["categories"] = categoriesEdit.text; // we save this to the MXML file
        metadata["categories"] = JSON.parse(catStr)
        metadata["contenttype"] = contenttypeSelector.getSelected();
        metadata["nsfw"] = nsfwCheck.checked;

        // update all the inetrefID's
        metadata["inetref"]["series"]["imdbID"] = imdbEdit.text;
        metadata["inetref"]["series"]["tmdbID"] = tmdbEdit.text;
        metadata["inetref"]["series"]["thetvdbID"] = thetvdbEdit.text;
        metadata["inetref"]["series"]["tvmazeID"] = tvmazeEdit.text;
        metadata["inetref"]["series"]["fanartID"] = fanartIDEdit.text;
        metadata["inetref"]["episode"]["imdbID"] = episodeImdbEdit.text;
        metadata["inetref"]["episode"]["tmdbID"] = episodeTmdbEdit.text;
        metadata["inetref"]["episode"]["thetvdbID"] = episodeThetvdbEdit.text;
        metadata["inetref"]["episode"]["tvmazeID"] = episodeTvmazeEdit.text;
        metadata["inetref"]["episode"]["fanartID"] = episodeFanartEdit.text;

        //metadata["inetrefJSON"] = JSON.stringify(metadata["inetref"], null, 4);

        metadata["website"] = websiteEdit.text;
        metadata["studio"] = studioEdit.text;
        metadata["coverart"] = coverartEdit.text;
        metadata["fanart"] = fanartEdit.text;
        metadata["banner"] = bannerEdit.text;
        metadata["screenshot"] = screenshotEdit.text;
        metadata["front"] = frontEdit.text;
        metadata["back"] = backEdit.text;

        metadata["channum"] = channumEdit.text;
        metadata["callsign"] = callsignEdit.text;
        metadata["startts"] = starttsEdit.text;
        metadata["releasedate"] = releasedateEdit.text;
        metadata["runtime"] = runtimeEdit.text;
        metadata["runtimesecs"] = runtimesecEdit.text;
        metadata["status"] = statusSelector.getSelected();

        var jsonStr = JSON.stringify(metadata, null, 4)

        // save to mxml file
        //var xmlFile = Util.removeExtension(metadata["folder"] + '/' + metadata["filename"]) + ".mxml";
        //mythUtils.writeMetadataXML(xmlFile, jsonStr);

        // save to json file
        var jsonFile;
        if (metadata["mediatype"] === "DIRECTORY")
            jsonFile = Util.removeExtension(metadata["folder"] + '/' + metadata["filename"] + "/Metadata/" + metadata["filename"]) + ".json";
        else
            jsonFile = Util.removeExtension(metadata["folder"] + "/Metadata/" + metadata["filename"]) + ".json";

        mythUtils.writeMetadataJSON(jsonFile, jsonStr);

        // save to database
        if (metadata["mediaid"] !== undefined)
        {
            if (!dbUtils.updateMediaItem(jsonStr))
            {
                showNotification("Failed to save to the database!", settings.osdTimeoutMedium);
                return;
            }
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
        var x, episodes;

        // search results
        if (resultJson.resultType === "IMDB Search")
        {
            imdbSearchResult = resultJson["result"]["results"];
            hideBusyDialog();
            showSearchResults("IMDB");
        }
        else if (resultJson.resultType === "TMDB Movie Search" || resultJson.resultType === "TMDB TV Search")
        {
            tmdbSearchResult = resultJson["result"]["results"]["results"];

            if (tmdbConfig === undefined)
            {
                tmdbConfig = resultJson["result"]["config"];
            }

            hideBusyDialog();
            showSearchResults(resultJson.resultType);
        }
        else if (resultJson.resultType === "THETVDB Search")
        {
            thetvdbSearchResult = resultJson["result"]["results"];
            hideBusyDialog();
            showSearchResults("THETVDB");
        }
        else if (resultJson.resultType === "TVMAZE Lookup THETVDB")
        {
            tvmazeSearchResult = resultJson["result"]["results"];
            hideBusyDialog();
            showSearchResults("TVMAZE");
        }
        else if (resultJson.resultType === "TVMAZE Lookup IMDB")
        {
            tvmazeSearchResult = resultJson["result"]["results"];
            hideBusyDialog();
            showSearchResults("TVMAZE");
        }
        else if (resultJson.resultType === "FANART Search")
        {
            fanartSearchResult = resultJson["result"]["results"];
            hideBusyDialog();

            if (fanartIDButton.focus)
                showSearchResults("FANART");
            else
                showSearchResults("FANART_EPISODE");
        }

        // metadata
        else if (resultJson.resultType === "GRABBERS FindAllMetadata")
        {
            allMetadata = resultJson["result"];
        }
        else if (resultJson.resultType === "GRABBERS FindBestMetadata")
        {
            var newMetadata = resultJson["result"];

            var fields = ["mediaid", "mediatype", "folder", "filename", "hash", "title", "subtitle", "description", "season", "episode", "tagline",
                          "categories", "contenttype", "nsfw","inetref","website","studio","coverart","fanart","banner","screenshot",
                          "front","back","channum","callsign","startts","releasedate","runtime","runtimesecs","status","extras"];

            for (var x = 0; x < fields.length; x++)
            {

                var field = fields[x];

                if (field == "inetref")
                {
                    if (metadata["inetref"]["series"]["imdbID"] !== allMetadata["inetref"]["series"]["imdbID"])
                        console.log("inetref/series/imdbID: Old: " + metadata["inetref"]["series"]["imdbID"] + ", New: " + newMetadata["inetref"]["series"]["imdbID"])

                    if (metadata["inetref"]["series"]["tmdbID"] !== allMetadata["inetref"]["series"]["tmdbID"])
                        console.log("inetref/series/tmdbID: Old: " + metadata["inetref"]["series"]["tmdbID"] + ", New: " + newMetadata["inetref"]["series"]["tmdbID"])

                    if (metadata["inetref"]["series"]["thetvdbID"] !== allMetadata["inetref"]["series"]["thetvdbID"])
                        console.log("inetref/series/thetvdbID: Old: " + metadata["inetref"]["series"]["thetvdbID"] + ", New: " + newMetadata["inetref"]["series"]["thetvdbID"])

                    if (metadata["inetref"]["series"]["tvmazeID"] !== allMetadata["inetref"]["series"]["tvmazeID"])
                        console.log("inetref/series/tvmazeID: Old: " + metadata["inetref"]["series"]["tvmazeID"] + ", New: " + newMetadata["inetref"]["series"]["tvmazeID"])

                    if (metadata["inetref"]["series"]["fanartID"] !== allMetadata["inetref"]["series"]["fanartID"])
                        console.log("inetref/series/fanartID: Old: " + metadata["inetref"]["series"]["fanartID"] + ", New: " + newMetadata["inetref"]["series"]["fanartID"])

                    if (metadata["inetref"]["episode"]["imdbID"] !== allMetadata["inetref"]["episode"]["imdbID"])
                        console.log("inetref/episode/imdbID: Old: " + metadata["inetref"]["episode"]["imdbID"] + ", New: " + newMetadata["inetref"]["episode"]["imdbID"])

                    if (metadata["inetref"]["episode"]["tmdbID"] !== allMetadata["inetref"]["episode"]["tmdbID"])
                        console.log("inetref/episode/tmdbID: Old: " + metadata["inetref"]["episode"]["tmdbID"] + ", New: " + newMetadata["inetref"]["episode"]["tmdbID"])

                    if (metadata["inetref"]["episode"]["thetvdbID"] !== allMetadata["inetref"]["episode"]["thetvdbID"])
                        console.log("inetref/episode/thetvdbID: Old: " + metadata["inetref"]["episode"]["thetvdbID"] + ", New: " + newMetadata["inetref"]["episode"]["thetvdbID"])

                    if (metadata["inetref"]["episode"]["tvmazeID"] !== allMetadata["inetref"]["episode"]["tvmazeID"])
                        console.log("inetref/episode/tvmazeID: Old: " + metadata["inetref"]["episode"]["tvmazeID"] + ", New: " + newMetadata["inetref"]["episode"]["tvmazeID"])

                    if (metadata["inetref"]["episode"]["fanartID"] !== allMetadata["inetref"]["episode"]["fanartID"])
                        console.log("inetref/episode/fanartID: Old: " + metadata["inetref"]["episode"]["fanartID"] + ", New: " + newMetadata["inetref"]["episode"]["fanartID"])
                }
                else
                {
                    if (metadata[field] != newMetadata[field])
                    {
                        console.log("field: " + field + " changed. Old: " + metadata[field] + ", New: " + newMetadata[field])
                    }
                }
            }
        }

        // episodes results
        else if (resultJson.resultType === "IMDB Episodes")
        {
            // lets see if we can find a matching episode
            episodes = resultJson["result"]["episodes"]

            for (x = 0; x < episodes.length; x++)
            {
                if (episodes[x].title === subtitleEdit.text)
                {
                    episodeimdbEdit.text = episodes[x].id;
                    return true;
                }
            }

            // no match so allow the user to choose from the list
            imdbEpisodes = episodes;
            showSearchResults("IMDB_EPISODES");
        }
        else if (resultJson.resultType === "TMDB TV Episodes")
        {
            // lets see if we can find a matching episode
            episodes = resultJson["result"]["episodes"]

            for (x = 0; x < episodes.length; x++)
            {
                if (episodes[x].title === subtitleEdit.text)
                {
                    episodeTmdbEdit.text = episodes[x].id;
                    return true;
                }
            }

            // no match so allow the user to choose from the list
            tmdbEpisodes = episodes;
            showSearchResults("TMDB_EPISODES");
        }
        else if (resultJson.resultType === "THETVDB Episodes")
        {
            // lets see if we can find a matching episode
            episodes = resultJson["result"]["episodes"]["data"]["episodes"]

            for (x = 0; x < episodes.length; x++)
            {
                if (episodes[x].name === subtitleEdit.text)
                {
                    episodeThetvdbEdit.text = episodes[x].id;
                    return true;
                }
            }

            // no match so allow the user to choose from the list
            thetvdbEpisodes = episodes;
            showSearchResults("THETVDB_EPISODES");
        }
        else if (resultJson.resultType === "TVMAZE Episodes")
        {
            // lets see if we can find a matching episode
            episodes = resultJson["result"]["episodes"]

            for (x = 0; x < episodes.length; x++)
            {
                if (episodes[x].name === subtitleEdit.text)
                {
                    episodeTvmazeEdit.text = episodes[x].id;
                    return true;
                }
            }

            // no match so allow the user to choose from the list
            tvmazeEpisodes = episodes;
            showSearchResults("TVMAZE_EPISODES");
        }


        return true;
    }

    function showMetadataResults(field)
    {
        var x, keys, value, catStr;

        searchResultModel.clear();
        searchDialog.title = "Choose a " + field
        searchDialog.displayField = "item";
        searchDialog.dataField = "data";
        searchDialog.sortField = "";
        searchDialog.delegate = textSearchDelegate;
        searchDialog.searchItem = field;

        if (metadata[field] !== "")
        {
            if (field === "categories")
            {
                if (metadata["categories"] !== "")
                {
                    catStr = metadata["categories"].join(", ");
                    searchResultModel.append({"source": "Current", "item": catStr, "data": catStr, "icon": ""});
                }
            }
            else if (field.startsWith("inetref/series/"))
            {
                keys = field.split('/');
                value =  "" + metadata[keys[0]][keys[1]][keys[2]];
                searchResultModel.append({"source": "Current", "item": value, "data": value, "icon": ""});
            }
            else
                searchResultModel.append({"source": "Current", "item": metadata[field], "data": metadata[field], "icon": ""});
        }

        // add any series or season metadata if we have them
        for (x = 0; x < parentMetadata.length; x++)
        {
            if (field.startsWith("inetref/series/"))
            {
                keys = field.split('/');
                value =  parentMetadata[x][keys[0]][keys[1]][keys[2]];
                searchResultModel.append({"source": parentMetadata[x]["title"], "item": value, "data": value, "icon": ""});
            }
            else if (field === "categories")
            {
                if (parentMetadata[x]["categories"] !== "")
                {
                    catStr = parentMetadata[x]["categories"].join(", ");
                    searchResultModel.append({"source": parentMetadata[x]["title"], "item": catStr, "data": catStr, "icon": ""});
                }
            }
            else
                searchResultModel.append({"source": parentMetadata[x]["title"], "item": parentMetadata[x][field], "data": parentMetadata[x][field], "icon": ""});
        }

        if (allMetadata && allMetadata[field])
        {
            for (x = 0; x < allMetadata[field].length; x++)
            {
                var item = allMetadata[field][x]
                var icon = "";

                if (["coverart", "fanart", "banner", "screenshot", "front", "back"].includes(field))
                {
                    icon = item[field];
                    searchDialog.delegate = imageSearchDelegate;
                }

                searchResultModel.append({"source": item["source"], "item": item[field], "data": item[field], "icon": icon});
            }
        }

        if (searchResultModel.count > 0)
        {
            searchDialog.model = searchResultModel;
            searchDialog.show();
        }
        else
        {
            showNotification("No results found for " + field + " field.", settings.osdTimeoutMedium);
        }
    }

    function findMetadata()
    {
        if (allMetadata === undefined)
        {
            showNotification("No grabber results available yet. Please try again later.", settings.osdTimeoutMedium);
            //return
        }

        var x;
        var fieldName = "";

        for (x = 0; x < page1.children.length; x++)
        {
            if (page1.children[x].focus)
                fieldName = page1.children[x].objectName
        }

        if (fieldName == "")
        {
            for (x = 0; x < page2.children.length; x++)
            {
                if (page2.children[x].focus)
                    fieldName = page2.children[x].objectName
            }
        }

        if (fieldName == "")
        {
            for (x = 0; x < page3.children.length; x++)
            {
                if (page3.children[x].focus)
                    fieldName = page3.children[x].objectName
            }
        }

        if (fieldName == "")
        {
            for (x = 0; x < page4.children.length; x++)
            {
                if (page4.children[x].focus)
                    fieldName = page4.children[x].objectName
            }
        }

        if (fieldName == "")
        {
            showNotification("No results available for this field.", settings.osdTimeoutMedium);
            return
        }

        showMetadataResults(fieldName);
    }

    function findMissingMetadata()
    {
        var metadataStr = JSON.stringify(metadata);
        sendCommandToHelper('{ "commandType": "Metadata Grabber", "grabber": "ALL", "queryType": "FindBestMetadata", "metadata": ' + metadataStr + ' }')
    }
}
