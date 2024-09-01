import QtQuick 2.0
import QtQuick.XmlListModel 2.0
import Qt.labs.folderlistmodel 2.5
import Base 1.0
import Process 1.0
import Models 1.0
import Dialogs 1.0
import SqlQueryModel 1.0
import mythqml.net 1.0

import "../../../Util.js" as Util

BaseScreen
{
    id: root

    defaultFocusItem: videoList
    property string mediaType: "VIDEO"
    property string sortField: "title"
    property bool showNSFW: false
    property bool sortReversed: false
    property string contentType: "ALL"

    // one of VLC or MDK
    property string _playerToUse: dbUtils.getSetting("InternalPlayer", settings.hostName, "VLC");
    // one of coverart, fanart, banner, screenshot, front or back
    property string _currentArtwork: "coverart"
    property alias _showArtwork: previewImage.visible

    closeOnEscape: !_showArtwork

    Component.onCompleted:
    {
        showTitle(false, "");
        setHelp("https://mythqml.net/help/media_viewer.php#top");
        showTime(false);
        showTicker(false);

        // we no longer support QtAV player
        if (_playerToUse === "QtAV")
        {
            dbUtils.setSetting("InternalPlayer", settings.hostName, "MDK");
            _playerToUse = "MDK";
        }

        sortField = dbUtils.getSetting("MediaViewerSortField", settings.hostName, "title");
        sortReversed = (dbUtils.getSetting("MediaViewerSortReversed", settings.hostName, "false") == "true");
        contentType = dbUtils.getSetting("MediaViewerContentType", settings.hostName, "ALL");
        mediaType = dbUtils.getSetting("MediaViewerMediaType", settings.hostName, "VIDEO");

        if (sortField === "datemodified")
            footer.redText = "Sort (Modified)";
        else if (sortField === "releasedate")
            footer.redText = "Sort (Release Date)";
        else
            footer.redText = "Sort (Name)";

        footer.greenText = "Order (" + (sortReversed ? "Z-A" : "A-Z") + ")";
        footer.yellowText = "Show (" + contentType + ")";
        footer.blueText = "Media Type (" + mediaType + ")";

        updateSQL();
    }

    Component.onDestruction:
    {
        dbUtils.setSetting("MediaViewerSortField", settings.hostName, sortField);
        dbUtils.setSetting("MediaViewerSortReversed", settings.hostName, (sortReversed ? "true" : "false"));
        dbUtils.setSetting("MediaViewerContentType", settings.hostName, contentType);
        dbUtils.setSetting("MediaViewerMediaType", settings.hostName, mediaType);
    }

    SqlQueryModel
    {
        id: mediaItemsModel

        sql: "SELECT * FROM mediaitems WHERE mediatype = '" + mediaType + "' ORDER BY " + sortField + (sortReversed ? " DESC" : " ASC");

        onSqlChanged:
        {
            while (canFetchMore(index(-1, -1)))
                fetchMore(index(-1, -1));

            updateMetadata();
        }
    }

    ListModel
    {
        id: mediaModel
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
        id: extrasModel
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

    MythMetadataXMLModel
    {
        id: metadataModel

        onStatusChanged:
        {
            if (status === XmlListModel.Ready)
                updateMetadata();
        }
    }

    Keys.onPressed:
    {
        event.accepted = true;

        if (event.key === Qt.Key_F1)
        {
            // red
            if (_showArtwork)
            {
                if (_currentArtwork === "coverart")
                    _currentArtwork = "back";
                else if (_currentArtwork === "fanart")
                    _currentArtwork = "coverart";
                else if (_currentArtwork === "screenshot")
                    _currentArtwork = "fanart";
                else if (_currentArtwork === "banner")
                    _currentArtwork = "screenshot";
                else if (_currentArtwork === "front")
                    _currentArtwork = "banner";
                else if (_currentArtwork === "back")
                    _currentArtwork = "front";

                updatePreviewImage();
            }
            else
            {
                if (sortField === "title")
                {
                    sortField = "datemodified";
                    footer.redText = "Sort (Modified)";
                }
                else if (sortField === "datemodified")
                {
                    sortField = "releasedate";
                    footer.redText = "Sort (Release Date)";
                }
                else
                {
                    sortField = "title"
                    footer.redText = "Sort (Name)";
                }

                updateSQL();
            }
        }
        else if (event.key === Qt.Key_F2)
        {
            // green
            if (_showArtwork)
            {
                if (_currentArtwork === "coverart")
                    _currentArtwork = "fanart";
                else if (_currentArtwork === "fanart")
                    _currentArtwork = "screenshot";
                else if (_currentArtwork === "screenshot")
                    _currentArtwork = "banner";
                else if (_currentArtwork === "banner")
                    _currentArtwork = "front";
                else if (_currentArtwork === "front")
                    _currentArtwork = "back";
                else if (_currentArtwork === "back")
                    _currentArtwork = "coverart";

                updatePreviewImage();
            }
            else
            {
                sortReversed = !sortReversed;
                footer.greenText = "Order (" + (sortReversed ? "Z-A" : "A-Z") + ")";
                updateSQL();
            }
        }
        else if (event.key === Qt.Key_F3)
        {
            // yellow
            if (contentType === "ALL")
                contentType = "MOVIE";
            else if (contentType === "MOVIE")
                contentType = "TV";
            else if (contentType === "TV")
                contentType = "ADULT";
            else if (contentType === "ADULT")
                contentType = "ALL";

            footer.yellowText = "Show (" + contentType + ")";
            updateSQL();
        }
        else if (event.key === Qt.Key_F4)
        {
            if (mediaType == "VIDEO")
                mediaType = "DVD";
            else if (mediaType == "DVD")
                mediaType = "VIDEO";

            footer.blueText = "Media Type (" + mediaType + ")";
            updateSQL();
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
        else if (event.key === Qt.Key_F6)
        {
            ffmpegProcess.start("/usr/bin/mythffmpeg", ["-i",  "file://" + videoList.model.get(videoList.currentIndex, "filePath"),
                                                        "-vcodec", "copy", "-acodec", "copy",
                                                        "file://" + videoList.model.get(videoList.currentIndex, "filePath") + "_clean.mp4"
                                                       ]);
        }
        else if (event.key === Qt.Key_F7)
        {
            showWebsite();
        }
        else if (event.key === Qt.Key_F8 || event.key === Qt.Key_X)
        {
            showNSFW = !showNSFW;
            updateSQL();
            showNotification("NSFW is " + (showNSFW ? "ON" : " OFF"));
        }
        else if (event.key === Qt.Key_F9)
        {
            showArtwork();
        }
        else if (event.key === Qt.Key_A)
            textEditDialog.show();
        else if (event.key === Qt.Key_E)
        {
            showMetadataEditor();
        }
        else if (event.key === Qt.Key_M)
        {
            popupMenu.clearMenuItems();
            extrasModel.clear();

            if ((mediaItemsModel.get(videoList.currentIndex, "extras") !== ""))
            {
                popupMenu.addMenuItem("", "Extras", "EXTRAS");
                var extrasJson = JSON.parse(mediaItemsModel.get(videoList.currentIndex, "extras"));
                var extras = extrasJson.extras;

                for (var x = 0; x < extras.length; x++)
                {
                     popupMenu.addMenuItem("0", extras[x].name, "EXTRA:" + x);
                    extrasModel.append({"no": x, "title": extras[x].name, "icon": mythUtils.findThemeFile("images/extras.png"), "url": extras[x].url, "player": _playerToUse, "duration": ""})
                }
            }

            popupMenu.addMenuItem("", "Show Info...", "INFO");
            popupMenu.addMenuItem("", "Show Artwork...", "ARTWORK" );
            popupMenu.addMenuItem("", "Show Help...", "HELP");
            popupMenu.addMenuItem("", "Edit Metadadata...", "EDIT");

            if (mediaItemsModel.get(videoList.currentIndex, "website") != "")
                popupMenu.addMenuItem("", "Show Website...", "WEBSITE");

            popupMenu.addMenuItem("", "Reload", "RELOAD");
            popupMenu.addMenuItem("", "Scan Folder...", "SCAN");

            popupMenu.show();
        }
        else if (event.key === Qt.Key_I)
        {
            showInfo();
        }
        else if (event.key === Qt.Key_Escape && _showArtwork)
        {
            _showArtwork = false;
        }
        else
            event.accepted = false;
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

    BaseBackground
    {
        id: listBackground
        x: xscale(10); y: yscale(45); width: parent.width - x - xscale(10); height: yscale(410)
    }

    BaseBackground { x: xscale(10); y: yscale(465); width: parent.width - xscale(20); height: yscale(210) }

    TitleText
    {
        x: 20
        width: parent.width - xscale(200)
        text: mediaItemsModel.get(videoList.currentIndex, "title");
    }

    InfoText
    {
        id: posText
        x: parent.width - xscale(180); y: yscale(5); width: xscale(150);
        text: (videoList.currentIndex + 1) + " of " + mediaItemsModel.rowCount();
        horizontalAlignment: Text.AlignRight
    }

    Component
    {
        id: itemDelegate
        Item
        {
            width: videoList.cellWidth
            height: videoList.cellHeight

            Rectangle
            {
                opacity: 0.3
                anchors.margins: xscale(4)
                anchors.fill: parent
                radius: xscale(4)
                color: "black"
            }

            Image
            {
                opacity: 0.80
                asynchronous: true
                fillMode: Image.PreserveAspectFit
                anchors.fill: parent
                anchors.margins: xscale(5)
                source:
                {
                    if (front != "")
                        findVideoImage(folder + "/" + filename, front, "front");
                    else if (back != "")
                        findVideoImage(folder + "/" + filename, back, "back");
                    else if (coverart != "")
                        findVideoImage(folder + "/" + filename, coverart, "coverart");
                    else if (fanart != "")
                        findVideoImage(folder + "/" + filename, fanart, "fanart");
                    else if (screenshot != "")
                        findVideoImage(folder + "/" + filename, screenshot, "screenshot");
                    else
                        mythUtils.findThemeFile("images/no_image.png")
                }
                onStatusChanged: if (status == Image.Error) source = mythUtils.findThemeFile("images/no_image.png");
            }

            LabelText
            {
                x: 5;
                y: videoList.cellHeight - yscale(40)
                width: videoList.cellWidth - xscale(10)
                text: title
                horizontalAlignment: Text.AlignHCenter;
                fontPixelSize: xscale(14)
            }

            Image
            {
                x: videoList.cellWidth - xscale(45)
                y: yscale(5)
                width: xscale(40)
                height: yscale(40)
                visible: (mediaItemsModel.get(index, "status") == "Unverified")
                opacity: 1.0
                source: mythUtils.findThemeFile("images/new.png");
            }
        }
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
        model: mediaItemsModel
        delegate: itemDelegate

        Keys.onReturnPressed:
        {
            var folder = "file://" + model.get(currentIndex, "folder");
            var filename = model.get(currentIndex, "filename")
            mediaModel.get(0).title = model.get(currentIndex, "title");
            mediaModel.get(0).url = folder + '/' + filename;
            mediaModel.get(0).player = _playerToUse;

            if (filename == "VIDEO_TS")
            {
                playDVD(folder + '/' + filename)
            }
            else
            {
                if (filename.endsWith(".ISO") || filename.endsWith(".iso") || filename.endsWith(".IMG") || filename.endsWith(".img"))
                {
                    playDVD(model.get(currentIndex, "filePath"))
                }
                else
                {
                    if (root.isPanel)
                    {
                        internalPlayer.previousFocusItem = videoList;
                        playerSources.adhocList = mediaModel;
                        feedSelected("Adhoc", "", 0);
                    }
                    else
                    {
                        playerSources.adhocList = mediaModel;
                        stack.push({item: Qt.resolvedUrl("InternalPlayer.qml"), properties:{defaultFeedSource:  "Adhoc", defaultFilter:  "", defaultCurrentFeed: 0}});
                    }
                }
            }

            event.accepted = true;
        }

        onCurrentIndexChanged: updateMetadata()
    }

    TitleText
    {
        id: title
        x: xscale(30); y: yscale(470)
        width: parent.width - _xscale(1280 - 900); height: yscale(35)
        verticalAlignment: Text.AlignTop
        multiline: true
    }

    Image
    {
        id: videoImage
        x: parent.width - _xscale(1280 - 950); y: yscale(480); width: _xscale(266); height: _yscale(150)
        fillMode: Image.PreserveAspectFit
        asynchronous: true
        onStatusChanged: if (status == Image.Error) source = mythUtils.findThemeFile("images/grid_noimage.png")
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

    LabelText
    {
        id: subtitle
        x: _xscale(30); y: yscale(500); width: _xscale(830)
    }

    InfoText
    {
        id: videoLength
        x: _xscale(860); y: yscale(500); width: _xscale(80)
        fontColor: "grey"
        horizontalAlignment: Text.AlignRight
    }

    Image
    {
        id: websiteIcon
        x: _xscale(940); y: yscale(635); width: xscale(32); height: yscale(32)
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
        redText: "Sort (" + (sortField === "title" ? "Name" : "Modified") + ")"
        greenText: "Order (" + (sortReversed ? "Z-A" : "A-Z") + ")"
        yellowText: "Show (" + contentType + ")"
        blueText: "Media Type (" + mediaType + ")";

    }

    TitleText
    {
        id: noResult
        x: xscale(22)
        y: yscale(55)
        width: parent.width - xscale(44)
        height: yscale(390)
        fontColor: "white"
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        text: "No results found for these search options."
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
        source: ""
        onStatusChanged: if (status == Image.Error) source = mythUtils.findThemeFile("images/grid_noimage.png");
    }

    TitleText
    {
        id: noArtwork
        x: xscale(22)
        y: yscale(55)
        width: parent.width - xscale(44)
        height: yscale(390)
        fontColor: "white"
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        text: "No " + _currentArtwork + " image found for this video."
        visible: _showArtwork && previewImage.source == ""
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

    TextEditDialog
    {
        id: textEditDialog

        title: "Enter Folder"
        message: "Enter folder to scan."

        width: xscale(600); height: yscale(350)

        onResultText:
        {
            var command = "Scan Folder: " + text;
            helperWebSocket.sendTextMessage(command);
            videoList.focus = true
        }
        onCancelled:
        {
            videoList.focus = true
        }
    }

    PopupMenu
    {
        id: popupMenu

        title: "Menu"
        message: "Media Viewer Options"

        onItemSelected:
        {
            videoList.focus = true;

            if (itemData == "INFO")
            {
                showInfo();
            }
            else if (itemData == "WEBSITE")
            {
                showWebsite();
            }
            else if (itemData == "ARTWORK")
            {
                showArtwork();
            }
            else if (itemData == "HELP")
            {
                showHelp();
            }
            else if (itemData == "EDIT")
            {
                showMetadataEditor();
            }
            else if (itemData == "RELOAD")
            {
                mediaItemsModel.reload();
            }
            else if (itemData == "SCAN")
            {
                editDialog.show();
            }
            else if (itemData.startsWith("EXTRA:"))
            {
                var index = parseInt(itemData.replace("EXTRA:", ""));
                playerSources.adhocList = extrasModel;
                stack.push({item: Qt.resolvedUrl("InternalPlayer.qml"), properties:{defaultFeedSource:  "Adhoc", defaultFilter:  "", defaultCurrentFeed: index}});
            }
        }

        onCancelled:
        {
            videoList.focus = true;
        }
    }

    InfoDialog
    {
        id: infoDialog
        width: xscale(800)
    }

    TextEditDialog
    {
        id: editDialog
        title: "Scan Folder"
        message: "Enter folder to scan"

        width: xscale(600); height: yscale(350)

        onResultText:
        {
            showNotification("Scanning folder: " + text);
            sendCommandToHelper("Scan Folder: " + text)
        }
    }

    function showInfo()
    {
        var infoText = videoDesc.text.replace(/\n/g, "<br>") +
                "<br>Folder: " + mediaItemsModel.get(videoList.currentIndex, "folder") +
                "<br>Filename: " + mediaItemsModel.get(videoList.currentIndex, "filename");
        infoDialog.infoText = infoText;
        infoDialog.show(videoList);
    }

    function showWebsite()
    {
        var website = mediaItemsModel.get(videoList.currentIndex, "website");

        if (website != "")
        {
            var zoom = xscale(1.0);
            stack.push({item: Qt.resolvedUrl("WebBrowser.qml"), properties:{url: website, zoomFactor: zoom}});
        }
    }

    function showArtwork()
    {
        _showArtwork = !_showArtwork;
        updatePreviewImage();
    }

    function updatePreviewImage()
    {
        if (_currentArtwork === "coverart")
        {
            //if (mediaItemsModel.get(videoList.currentIndex, "coverart") !== "")
                previewImage.source = mediaItemsModel.get(videoList.currentIndex, "coverart");
            //else
            //    previewImage.source = ""
        }
        else if (_currentArtwork === "fanart")
            previewImage.source = mediaItemsModel.get(videoList.currentIndex, "fanart");
        else if (_currentArtwork === "screenshot")
            previewImage.source = mediaItemsModel.get(videoList.currentIndex, "screenshot");
        else if (_currentArtwork === "banner")
            previewImage.source = mediaItemsModel.get(videoList.currentIndex, "banner");
        else if (_currentArtwork === "front")
            previewImage.source = mediaItemsModel.get(videoList.currentIndex, "front");
        else if (_currentArtwork === "back")
            previewImage.source = mediaItemsModel.get(videoList.currentIndex, "back");
    }

    function showMetadataEditor()
    {
        var item = stack.push({item: Qt.resolvedUrl("MediaMetadataEditor.qml"), properties:{sqlModel: mediaItemsModel, currentIndex: videoList.currentIndex}});
        item.saved.connect(reloadModel);
    }

    function updateSQL()
    {
        var where = contentType == "ALL" ? "" : " AND contenttype = '" + contentType + "'";
        var where2 = " AND nsfw = " + (showNSFW ? "1" : "0");
        var orderby = " ORDER BY " + sortField + (sortReversed ? " DESC" : " ASC");
        var sql = "SELECT * FROM mediaitems WHERE mediatype = '" + mediaType + "' " + where + where2 + orderby;
        mediaItemsModel.sql = sql;
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

    function findCoverImage(path)
    {
        var result = mythUtils.findThemeFile(path + ".png");

        if (result === "")
            result = mythUtils.findThemeFile(path + ".jpg");

        if (result === "")
            result = mythUtils.findThemeFile(Util.removeExtension(path) + ".png");

        if (result === "")
            result = mythUtils.findThemeFile(Util.removeExtension(path) + ".jpg");

        if (result === "")
            result = mythUtils.findThemeFile("images/grid_noimage.png");

        return result;
    }

    function findXMLMetadata()
    {
        var videoFile = videoList.model.get(videoList.currentIndex).folder + '/' + videoList.model.get(videoList.currentIndex).filename;
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
            metadataModel.source = ""
            metadataModel.reload();
            updateMetadata();
        }
    }

    function reloadModel()
    {
        mediaItemsModel.reload();
        updateMetadata();
    }

    function updateMetadata()
    {
        if (mediaItemsModel.rowCount() === 0)
        {
            posText.text = "0 of 0";
            title.text = "";
            subtitle.text = "";
            videoDesc.text = "";
            videoCategory.text = "";
            videoEpisode.text = "";
            videoLength.text = "";
            videoReleaseDate.text = "";
            fileStatus.text = "";
            videoImage.source = "";
            websiteIcon.visible = false;
            hashIcon.visible = false;
            extrasIcon.visible = false;
            noResult.visible = true;
        }
        else
        {
            noResult.visible = false;
            posText.text = (videoList.currentIndex + 1) + " of " + mediaItemsModel.rowCount();

            title.text = mediaItemsModel.get(videoList.currentIndex, "title");

            if (mediaItemsModel.get(videoList.currentIndex, "subtitle") != "")
                subtitle.text = mediaItemsModel.get(videoList.currentIndex, "subtitle");
            else if (mediaItemsModel.get(videoList.currentIndex, "tagline" != ""))
                subtitle.text = mediaItemsModel.get(videoList.currentIndex, "tagline");
            else
                subtitle.text = "";

            videoDesc.text = mediaItemsModel.get(videoList.currentIndex, "description");

            var folder = mediaItemsModel.get(videoList.currentIndex, "folder");
            var filename = mediaItemsModel.get(videoList.currentIndex, "filename");
            var coverart = mediaItemsModel.get(videoList.currentIndex, "coverart");
            var front = mediaItemsModel.get(videoList.currentIndex, "front");
            var back = mediaItemsModel.get(videoList.currentIndex, "back");
            var fanart = mediaItemsModel.get(videoList.currentIndex, "fanart");
            var screenshot = mediaItemsModel.get(videoList.currentIndex, "screenshot");
            if (fanart != "")
                videoImage.source = findVideoImage(folder + "/" + filename, fanart, "fanart");
            else if (screenshot != "")
                videoImage.source = findVideoImage(folder + "/" + filename, screenshot, "screenshot");
            else if (coverart != "")
                videoImage.source = findVideoImage(folder + "/" + filename, coverart, "coverart");
            else if (back != "")
                videoImage.source = findVideoImage(folder + "/" + filename, back, "back");
            else if (front != "")
                videoImage.source = findVideoImage(folder + "/" + filename, front, "front");
            else
                videoImage.source = mythUtils.findThemeFile("images/no_image.png")

            updatePreviewImage();

            var genreJson = JSON.parse(mediaItemsModel.get(videoList.currentIndex, "genres"));
            videoCategory.text = genreJson.join(", ");

            var season = mediaItemsModel.get(videoList.currentIndex, "season");
            var episode = mediaItemsModel.get(videoList.currentIndex, "episode") ? mediaItemsModel.get(videoList.currentIndex, "episode") : 0;
            var res = "";

            if (season > 0)
                res = "Season: " + season + " ";
            if (episode > 0)
                res += " Episode: " + episode;

            videoEpisode.text = res;

            videoLength.text = mediaItemsModel.get(videoList.currentIndex, "runtime") ? mediaItemsModel.get(videoList.currentIndex, "runtime") : "";

            videoReleaseDate.text = mediaItemsModel.get(videoList.currentIndex, "releasedate") ? "Release Date: " + mediaItemsModel.get(videoList.currentIndex, "releasedate") : "";

            websiteIcon.visible = ((mediaItemsModel.get(videoList.currentIndex, "website") !== "" ) ? true : false);
            hashIcon.visible = ((mediaItemsModel.get(videoList.currentIndex, "hash") !== "" ) ? true : false);
            extrasIcon.visible = ((mediaItemsModel.get(videoList.currentIndex, "extras") !== "" ) ? true : false);
            fileStatus.text = mediaItemsModel.get(videoList.currentIndex, "status")
        }
    }

    function handleResult(resultJson)
    {
        log.info(Verbose.GENERAL, "MediaViewer handle result - " + JSON.stringify(resultJson, null, 4));

        if (resultJson.resultType === "Scan Folder")
        {
            var folder = resultJson.folder
            var totalFiles = resultJson.totalFilesFound
            var filesAdded = resultJson.filesAdded
            var filesUpdated = resultJson.filesUpdated
            var filesSkipped = resultJson.filesSkipped
            var filesMoved = resultJson.filesMoved
            var filesInDB = resultJson.filesInDB
            var filesRemovedFromDB = resultJson.filesRemovedFromDB

            if (filesAdded || filesMoved || filesUpdated)
            {
                showNotification("Files have been updated. Reloading list...");
                mediaItemsModel.reload();
            }
        }

        return true
    }
}
