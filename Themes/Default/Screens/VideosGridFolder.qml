import QtQuick 2.0
import QtQml.XmlListModel
import Qt.labs.folderlistmodel 2.15
import Base 1.0
import Process 1.0
import Models 1.0
import Dialogs 1.0
import "../../../Util.js" as Util

BaseScreen
{
    id: root

    defaultFocusItem: videoList

    property alias folder: folderModel.folder
    property alias sortField: folderModel.sortField
    property alias sortReversed: folderModel.sortReversed

    // one of VLC or MDK
    property string _playerToUse: dbUtils.getSetting("InternalPlayer", settings.hostName, "VLC");
    property var _folderMap: new Map()

    property var _metadata: []

    property string _directoryImage: mythUtils.findThemeFile("images/folder.png")

    Component.onCompleted:
    {
        showTitle(false, "");
        setHelp("https://mythqml.net/help/videos_folder.php#top");
        showTime(false);
        showTicker(false);

        while (stack.busy) {};

        // we no longer support QtAV player
        if (_playerToUse === "QtAV")
        {
            dbUtils.setSetting("InternalPlayer", settings.hostName, "MDK");
            _playerToUse = "MDK";
        }
    }

    Connections
    {
        target: helper
        function onFileCounterResult(folder, fileCount)
        {
            videoDesc.text = "There are " + fileCount + " video files in this folder."
        }
    }

    ListModel
    {
        id: playbackModel
        ListElement
        {
            no: "1"
            title: ""
            icon: ""
            url: ""
            player: ""
            duration: ""
        }
    }

    ListModel
    {
        id: mediaModel
        ListElement
        {
            url: ""
            mediaid: 0
            mediatype: ""
            folder: ""
            filename: ""
            hash: ""
            title: ""
            subtitle: ""
            description: ""
            season: 0
            episode: 0
            tagline: ""
            categories: "Unknown"
            contenttype: "TV"
            nsfw: false
            website: ""
            studio: ""
            icon: ""
            coverart: ""
            fanart: ""
            banner: ""
            screenshot: ""
            front: ""
            back: ""
            channum: ""
            callsign: ""
            startts: ""
            releasedate: ""
            runtime: ""
            runtimesecs: 0
            status: "Unverified"
            extras: ""
        }
    }

    FolderListModel
    {
        id: folderModel
        folder: settings.videoPath
        caseSensitive: false
        nameFilters: ["*.mp4", "*.ts", "*.flv", "*.mp2", "*.wmv", "*.avi", "*.mkv", "*.mpg", "*.iso", "*.mov", "*.webm", "*.img"]
        sortField: FolderListModel.Name

        onStatusChanged:
        {
            if (folderModel.status == FolderListModel.Ready)
            {
                loadModel();
            }
        }
    }

    JSONModel
    {
        id: metadataModel

        onLoaded: loadJSONMetadata(source.toString());
    }

    Keys.onPressed:
    {
        event.accepted = true;

        if (event.key === Qt.Key_F1)
        {
            // red
            if (folderModel.sortField === FolderListModel.Name)
                folderModel.sortField = FolderListModel.Time;
            else
                folderModel.sortField = FolderListModel.Name;

            footer.redText = "Sort (" + (folderModel.sortField === FolderListModel.Name ? "Name" : "Modified") + ")";
        }
        else if (event.key === Qt.Key_F2)
        {
            // green
            folderModel.sortReversed = !folderModel.sortReversed;
            footer.greenText = "Order (" + (folderModel.sortReversed ? "Z-A" : "A-Z") + ")";
        }
        else if (event.key === Qt.Key_F4)
        {
            ffmpegProcess.start("/usr/bin/mythffmpeg", ["-i",  "file://" + videoList.model.get(videoList.currentIndex, "filePath"),
                                                        "-vcodec", "copy", "-acodec", "copy",
                                                        "file://" + videoList.model.get(videoList.currentIndex, "filePath") + "_clean.mp4"
                                                       ]);
        }
        else if (event.key === Qt.Key_F5)
        {
            if (_playerToUse === "VLC")
            {
                _playerToUse = "MDK";
                dbUtils.setSetting("InternalPlayer", settings.hostName, "MDK");
                showNotification("Using MDK for internal playback");
            }
            else
            {
                _playerToUse = "VLC";
                dbUtils.setSetting("InternalPlayer", settings.hostName, "VLC");
                showNotification("Using VLC player for internal playback");
            }
        }
        else if (event.key === Qt.Key_E)
        {
            var item = stack.push({item: Qt.resolvedUrl("MediaMetadataEditor.qml"), properties:{metadata: _metadata[videoList.currentIndex]}});
            item.saved.connect(updateMetadata);
            event.accepted = true;
        }
        else if (event.key === Qt.Key_I)
        {
            showInfo();
        }
        else if (event.key === Qt.Key_1)
        {
            folderModel = settings.videoPath;
        }
        else if (event.key === Qt.Key_2)
        {
            folderModel = settings.videoPath1;
        }
        else
            event.accepted = true;
    }

    // ffmpeg cleanup script
    Process
    {
        id: ffmpegProcess
        onFinished:
        {
            if (exitStatus == Process.NormalExit)
                dialog.message = "ffmpeg finished OK"
            else
                dialog.message = "ffmpeg failed!!"

            dialog.show();
        }
    }

    // cvlc player for fullscreen DVD playback
    Process
    {
        id: vlcPlayerProcess
        onFinished:
        {
            showVideo(true);
            pauseVideo(false);
        }
    }

    OkCancelDialog
    {
        id: dialog

        title: "ffmpeg process"
        message: ""
        rejectButtonText: ""
        acceptButtonText: "OK"

        width: xscale(600); height: yscale(300)

        onAccepted:
        {
            videoList.focus = true;
        }
        onCancelled:
        {
            videoList.focus = true;
        }
    }

   Image
   {
       id: coverImageBG
       x: 0; y: 0; height: parent.height; width: parent.width
       asynchronous: true
   }

    BaseBackground
    {
        id: listBackground
        x: xscale(10); y: yscale(45); width: parent.width - x - xscale(10); height: yscale(410)
    }

    BaseBackground { x: xscale(10); y: yscale(465); width: parent.width - xscale(20); height: yscale(210) }

    TitleText
    {
        id: breadcrumb
        x: 20
        width: parent.width - xscale(200)
    }

    InfoText
    {
        x: parent.width - xscale(180); y: yscale(5); width: xscale(150);
        text: (videoList.currentIndex + 1) + " of " + videoList.model.count;
        horizontalAlignment: Text.AlignRight
    }

    ButtonGrid
    {
        id: videoList
        x: xscale(22)
        y: yscale(55)
        width: parent.width - xscale(44)
        height: yscale(390)
        cellWidth: width / (root.isPanel ? 4 : 5);
        cellHeight: yscale(130)
        clip: true

        model: mediaModel

        Component
        {
            id: folderDelegate
            Item
            {
                x: 0;
                y: 0;
                width: videoList.cellWidth;
                height: videoList.cellHeight;
                Image
                {
                    opacity: 0.80
                    asynchronous: true
                    anchors.fill: parent
                    anchors.margins: xscale(5)
                    fillMode: mediatype == "DIRECTORY" ? Image.Stretch : Image.PreserveAspectFit
                    source: mediatype == "DIRECTORY" ? _directoryImage : coverart;
                    onStatusChanged: if (status == Image.Error) source = mythUtils.findThemeFile("images/no_image.png");
                }
                Image
                {
                    visible: (mediatype == "DIRECTORY")
                    opacity: 0.80
                    asynchronous: true
                    x: xscale(100)
                    y: yscale(35)
                    width: xscale(65)
                    height: yscale(65)
                    source: mediatype != "DIRECTORY" ? "" : coverart;
                    onStatusChanged: if (status == Image.Error) source = "";
                }
                LabelText
                {
                    x: 5;
                    y: videoList.cellHeight - yscale(42)
                    width: videoList.cellWidth - xscale(10)
                    text: title
                    horizontalAlignment: Text.AlignHCenter;
                    fontPixelSize: xscale(14)
                }
            }
        }

        delegate: folderDelegate

        Keys.onReturnPressed: event =>
        {
            var url = model.get(currentIndex).url;

            playbackModel.get(0).title = model.get(currentIndex).title;
            playbackModel.get(0).url = url;
            playbackModel.get(0).icon = model.get(currentIndex).icon;
            playbackModel.get(0).player = _playerToUse;

            if (model.get(currentIndex).mediatype === "DIRECTORY")
            {
                if (url.endsWith("/VIDEO_TS"))
                {
                    playDVD(url)
                }
                else
                {
                    rightSound.play();

                    if (root.isPanel)
                        panelStack.push(Qt.resolvedUrl("VideosGridFolder.qml"), {folder: url, sortField: sortField, sortReversed: sortReversed});
                    else
                        stack.push(Qt.resolvedUrl("VideosGridFolder.qml"), {folder: url, sortField: sortField, sortReversed: sortReversed});
                }
            }
            else
            {
                if (url.endsWith(".ISO") || url.endsWith(".iso") ||
                    url.endsWith(".IMG") || url.endsWith(".img"))
                {
                    playDVD(url);
                }
                else
                {
                    playDialog.title = _metadata[videoList.currentIndex].title;
                    playDialog.message = _metadata[videoList.currentIndex].description;
                    playDialog.image = _metadata[videoList.currentIndex].coverart;
                    playDialog.bookmark = dbUtils.getVideoBookmark(url);
                    playDialog.show();
                }
            }

            event.accepted = true;
        }

        onCurrentIndexChanged: updateMetadata();
    }

    TitleText
    {
        id: title
        x: xscale(30); y: yscale(470)
        width: parent.width - _xscale(1280 - 900); height: yscale(35)
        verticalAlignment: Text.AlignTop
        multiline: true
    }

    LabelText
    {
        id: subtitle
        x: xscale(30); y: yscale(510)
        width: parent.width - _xscale(1280 - 820); height: yscale(35)
        verticalAlignment: Text.AlignTop
    }

    Image
    {
        id: videoImage
        x: parent.width - _xscale(1280 - 950); y: yscale(480); width: _xscale(266); height: _yscale(150)
        asynchronous: true
        onStatusChanged: if (status == Image.Error) source = mythUtils.findThemeFile("images/no_image.png");
    }

    InfoText
    {
        id: videoDesc
        x: xscale(30); y: yscale(545)
        width: _xscale(910); height: yscale(75)
        verticalAlignment: Text.AlignTop
        multiline: true
    }

    InfoText
    {
        id: fileStatus
        x: _xscale(970); y: yscale(630); width: _xscale(266)
        horizontalAlignment: Text.AlignHCenter
        fontColor: if (text === "Unverified") "red"; else theme.infoFontColor;
    }

    InfoText
    {
        id: videoCategory
        x: xscale(20); y: yscale(630); width: _xscale(320)
        fontColor: "grey"
    }

    InfoText
    {
        id: videoEpisode
        x: _xscale(345); y: yscale(630); width: _xscale(290)
        horizontalAlignment: Text.AlignHCenter
        fontColor: "grey"
    }

    InfoText
    {
        id: videoReleaseDate
        x: _xscale(650); y: yscale(630); width: _xscale(280)
        fontColor: "grey"
        horizontalAlignment: Text.AlignRight
    }

    InfoText
    {
        id: videoLength
        x: _xscale(850); y: yscale(500); width: _xscale(90)
        fontColor: "grey"
        horizontalAlignment: Text.AlignRight
    }

    Image
    {
        id: websiteIcon
        x: _xscale(950); y: yscale(635); width: xscale(32); height: yscale(32)
        source: mythUtils.findThemeFile("images/website.png")
    }

    Image
    {
        id: hashIcon
        x: _xscale(990); y: yscale(635); width: xscale(32); height: yscale(32)
        source: mythUtils.findThemeFile("images/hash.png")
    }

    Image
    {
        id: extrasIcon
        x: _xscale(1040); y: yscale(635); width: xscale(32); height: yscale(32)
        source: mythUtils.findThemeFile("images/extras.png")
    }

    Footer
    {
        id: footer
        width: parent.width
        redText: "Sort (" + (sortField === FolderListModel.Name ? "Name" : "Modified") + ")"
        greenText: "Order (" + (sortReversed ? "Z-A" : "A-Z") + ")"
        yellowText: ""
        blueText: ""
    }

    InfoDialog
    {
        id: infoDialog
        width: xscale(800)
    }

    VideoPlayDialog
    {
        id: playDialog

        title: ""
        message: ""
        image: ""

        width: xscale(800); height: yscale(500)

        onPlay:
        {
            videoList.focus = true;
            if (root.isPanel)
            {
                internalPlayer.previousFocusItem = videoList;
                playerSources.adhocList = playbackModel;
                feedSelected("Adhoc", "", 0);
            }
            else
            {
                playerSources.adhocList = playbackModel;
                stack.push(Qt.resolvedUrl("InternalPlayer.qml"), {defaultFeedSource:  "Adhoc", defaultFilter:  "", defaultCurrentFeed: 0, bookmark: 0});
            }
        }

        onPlayFrom:
        {
            videoList.focus = true;
            if (root.isPanel)
            {
                internalPlayer.previousFocusItem = videoList;
                playerSources.adhocList = playbackModel;
                feedSelected("Adhoc", "", 0);
            }
            else
            {
                playerSources.adhocList = playbackModel;
                stack.push(Qt.resolvedUrl("InternalPlayer.qml"), {defaultFeedSource:  "Adhoc", defaultFilter:  "", defaultCurrentFeed: 0, bookmark: bookmark});
            }
        }

        onCancelled:
        {
            videoList.focus = true;
        }
    }

    function feedChanged(filter, index)
    {
        videoList.currentIndex = index;
    }

    function playDVD(filename)
    {
        pauseVideo(true);
        showVideo(false);
        vlcPlayerProcess.start("/usr/bin/cvlc", ["--play-and-exit",  "--fullscreen",
                                                 "--key-quit", "Esc", "--key-leave-fullscreen", "Ctrl+F",
                                                 filename]);
    }

    function loadModel()
    {
        mediaModel.clear();
        _metadata = [];

        var index = 0;

        for (var x = 0; x < folderModel.count; x++)
        {
            if (folderModel.get(x, "fileIsDir") && (folderModel.get(x, "fileName") === "Artwork" || folderModel.get(x, "fileName") === "Metadata") || folderModel.get(x, "fileName") === "Extras")
                continue;

            var metadata = {
                    "url": "file://" + folderModel.get(x, "filePath"),
                    "mediaid": 0,
                    "mediatype": folderModel.get(x, "fileIsDir") ? "DIRECTORY" : "VIDEO",
                    "folder": folderModel.folder.toString().replace("file://", ""),
                    "filename": folderModel.get(x, "fileName") !== undefined ? folderModel.get(x, "fileName") : "",
                    "hash": "",
                    "title": folderModel.get(x, "fileBaseName"),
                    "subtitle": "",
                    "description": folderModel.get(x, "filePath"),
                    "season": 0,
                    "episode": 0,
                    "tagline": "",
                    "categories": ["Unknown"],
                    "contenttype": "TV",
                    "nsfw": false,
                    "inetref": JSON.parse('{
                        "series": {
                            "imdbID": null,
                            "tmdbID": null,
                            "thetvdbID": null,
                            "tvmazeID": null,
                            "fanartID": null
                        },
                        "episode": {
                            "imdbID": null,
                            "tmdbID": null,
                            "thetvdbID": null,
                            "tvmazeID": null,
                            "fanartID": null
                        }
                    }'),
                    "website": "",
                    "studio": "",
                    "coverart":  folderModel.get(x, "fileIsDir") ? _directoryImage : findVideoImage(folderModel.get(x, "filePath"), "", "coverart"),
                    "fanart": "",
                    "banner": "",
                    "screenshot": "",
                    "front": "",
                    "back": "",
                    "channum": "",
                    "callsign": "",
                    "startts": "",
                    "releasedate": Qt.formatDateTime(folderModel.get(x, "fileModified"), "dd/MM/yyyy (hh:mm)"),
                    "runtime": "",
                    "runtimesecs": 0,
                    "status": "Unverified",
                    "extras": ""
                }

            mediaModel.append({"title": metadata["title"], "url": metadata["url"], "folder": metadata["folder"], "filename": metadata["filename"], "icon:": metadata["coverart"], "coverart":  metadata["coverart"], "front":  metadata["front"], "mediatype": metadata["mediatype"] });
            _metadata.push(metadata);

            var baseName = Util.removeExtension(metadata.filename);
            var jsonFile1 = metadata.folder + "/" + baseName + ".json";
            var jsonFile2 = metadata.folder + "/Metadata/" + baseName + ".json";
            var jsonFile3 = metadata.folder + "/" + metadata.filename + "/Metadata/" + baseName + ".json";

            if (mythUtils.fileExists(jsonFile1))
            {
                _folderMap.set(jsonFile1, index);

                if (metadataModel.status != XmlListModel.Loading)
                    metadataModel.source = jsonFile1;

                index += 1;
            }
            else if (mythUtils.fileExists(jsonFile2))
            {
                _folderMap.set(jsonFile2, index);

                if (metadataModel.status != XmlListModel.Loading)
                    metadataModel.source = jsonFile2;

                index += 1;
            }
            else if (mythUtils.fileExists(jsonFile3))
            {
                _folderMap.set(jsonFile3, index);

                if (metadataModel.status != XmlListModel.Loading)
                    metadataModel.source = jsonFile3;

                index += 1;
            }
            else
            {
                // use the default metadata
                _metadata[index] = metadata
                if (index == videoList.currentIndex)
                    updateMetadata();

                index += 1;
            }
        }

        const array = Array.from(_folderMap)
    }

    function loadJSONMetadata(url)
    {
        var index = _folderMap.get(url);
        _folderMap.delete(url)

        var catStr = ""
        for (var x = 0; x < metadataModel.jsonObj.categories.length; x++)
        {
            if (catStr == "")
                catStr =  metadataModel.jsonObj.categories[x];
            else
                catStr =  catStr + ", " + metadataModel.jsonObj.categories[x];
        }

        _metadata[index] = metadataModel.jsonObj;
        _metadata[index].folder = mediaModel.get(index).folder;
        _metadata[index].filename = mediaModel.get(index).filename;
        mediaModel.setProperty(index, "title", metadataModel.jsonObj.title);
        mediaModel.setProperty(index, "icon", findVideoImage(mediaModel.get(index).url, metadataModel.jsonObj.coverart, "coverart"));
        // mediaModel.get(index).subtitle = metadataModel.jsonObj.subtitle;
        mediaModel.setProperty(index, "description", metadataModel.jsonObj.description);
        mediaModel.setProperty(index, "coverart", mediaModel.get(index).icon);
        mediaModel.setProperty(index, "fanart", findVideoImage(mediaModel.get(index).url, metadataModel.jsonObj.fanart, "fanart"));
        mediaModel.setProperty(index, "screenshot", findVideoImage(mediaModel.get(index).url, metadataModel.jsonObj.screenshot, "screenshot"));

        if (index == videoList.currentIndex)
            updateMetadata();

        const iterator = _folderMap.keys();
        url = iterator.next().value;

        if (url != undefined)
            metadataModel.source = url
    }

    function updateMetadata()
    {
        breadcrumb.text = mediaModel.get(videoList.currentIndex).url;

        if (_metadata[videoList.currentIndex] == undefined)
            return;

        title.text = _metadata[videoList.currentIndex].title;

        if (_metadata[videoList.currentIndex].subtitle != "")
            subtitle.text = _metadata[videoList.currentIndex].subtitle;
        else if (_metadata[videoList.currentIndex].tagline != "")
            subtitle.text = _metadata[videoList.currentIndex].tagline;
        else
            subtitle.text = "";

        videoCategory.text = _metadata[videoList.currentIndex].categories.join(", ");

        var season = _metadata[videoList.currentIndex].season;
        var episode = _metadata[videoList.currentIndex].episode ? _metadata[videoList.currentIndex].episode : 0;
        var res = "";

        if (season > 0)
            res = "Season: " + season + " ";
        if (episode > 0)
            res += " Episode: " + episode;

        videoEpisode.text = res;

        videoLength.text = _metadata[videoList.currentIndex].runtime ? _metadata[videoList.currentIndex].runtime : "";

        videoReleaseDate.text = (_metadata[videoList.currentIndex].releasedate ? _metadata[videoList.currentIndex].releasedate : "");

        videoDesc.text =  _metadata[videoList.currentIndex].description;

        if (_metadata[videoList.currentIndex].screenshot != "")
            videoImage.source = findVideoImage(mediaModel.get(videoList.currentIndex).url, _metadata[videoList.currentIndex].screenshot, "screenshot");
        else if (_metadata[videoList.currentIndex].front != "")
            videoImage.source = findVideoImage(mediaModel.get(videoList.currentIndex).url, _metadata[videoList.currentIndex].front, "front");
        else if (_metadata[videoList.currentIndex].coverart != "")
            videoImage.source = findVideoImage(mediaModel.get(videoList.currentIndex).url, _metadata[videoList.currentIndex].coverart, "coverart");
        else
            videoImage.source = ""

        if (_metadata[videoList.currentIndex].fanart != "")
            coverImageBG.source = findVideoImage(mediaModel.get(videoList.currentIndex).url, _metadata[videoList.currentIndex].fanart, "fanart");
        else if (_metadata[videoList.currentIndex].screenshot != "")
            coverImageBG.source = findVideoImage(mediaModel.get(videoList.currentIndex).url, _metadata[videoList.currentIndex].screenshot, "screenshot");
        else
            coverImageBG.source = ""

        websiteIcon.visible = ((_metadata[videoList.currentIndex].website !== "" ) ? true : false);
        hashIcon.visible = ((_metadata[videoList.currentIndex].hash !== "" ) ? true : false);
        extrasIcon.visible = ((_metadata[videoList.currentIndex].extras.length > 0) ? true : false);
        fileStatus.text = _metadata[videoList.currentIndex].status;
    }

    function showInfo()
    {
        var infoText = videoDesc.text.replace(/\n/g, "<br>") +
                "<br><br>Title: " + _metadata[videoList.currentIndex].title +
                "<br><br>Tagline: " + _metadata[videoList.currentIndex].tagline +
                "<br><br>Folder: " + _metadata[videoList.currentIndex].folder +
                "<br><br>Filename: " + _metadata[videoList.currentIndex].filename;
        infoDialog.infoText = infoText;
        infoDialog.show(videoList);
    }
}
