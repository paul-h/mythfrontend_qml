import QtQuick 2.0
import "../../../Models"
import Qt.labs.folderlistmodel 2.5
import Base 1.0
import Process 1.0
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

    Component.onCompleted:
    {
        showTitle(false, "");
        setHelp("https://mythqml.net/help/videos_folder.php#top");
        showTime(false);
        showTicker(false);

        // we no longer support QtAV player
        if (_playerToUse === "QtAV")
        {
            dbUtils.setSetting("InternalPlayer", settings.hostName, "MDK");
            _playerToUse = "MDK";
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
        source:
        {
            if (videoList.model.get(videoList.currentIndex, "fileIsDir"))
                return "";
            else
                return findCoverImage(videoList.model.get(videoList.currentIndex, "filePath"));
        }
    }

    BaseBackground
    {
        x: xscale(15); y: yscale(50); width: parent.width - xscale(30); height: yscale(625)
    }

    TitleText
    {
        x: 20
        width: parent.width - xscale(200)
        text: folderModel.folder
    }

    InfoText
    {
        x: parent.width - xscale(180); y: yscale(5); width: xscale(150);
        text: (videoList.currentIndex + 1) + " of " + videoList.model.count;
        horizontalAlignment: Text.AlignRight
    }

    Component
    {
        id: listRow

        ListItem
        {
            height: yscale(60)

            Image
            {
                id: coverImage
                x: xscale(3); y: yscale(3); height: parent.height - yscale(6); width: height
                asynchronous: true
                source:
                {
                    if (fileIsDir)
                        mythUtils.findThemeFile("images/directory.png");
                    else
                        findCoverImage(filePath)
                }
            }
            ListText
            {
                width: videoList.width - coverImage.width - xscale(20); height: parent.height
                x: coverImage.width + xscale(5)
                text: fileName
            }
        }
    }

    ButtonList
    {
        id: videoList
        x: xscale(25); y: yscale(65); width: parent.width - xscale(50); height: yscale(594)

        clip: true

        FolderListModel
        {
            id: folderModel
            folder: settings.videoPath
            caseSensitive: false
            nameFilters: ["*.mp4", "*.flv", "*.mp2", "*.wmv", "*.avi", "*.mkv", "*.mpg", "*.iso", "*.mov", "*.webm", "*.img"]
            sortField: FolderListModel.Name
        }

        model: folderModel
        delegate: listRow

        Keys.onReturnPressed:
        {
            mediaModel.get(0).title = model.get(currentIndex, "filePath");
            mediaModel.get(0).url = "file://" + model.get(currentIndex, "filePath");
            mediaModel.get(0).player = _playerToUse;

            if (model.get(currentIndex, "fileIsDir"))
            {
                if (model.get(currentIndex, "filePath").endsWith("/VIDEO_TS"))
                {
                    playDVD(model.get(currentIndex, "filePath"))
                }
                else
                {
                    if (root.isPanel)
                        panelStack.push({item: Qt.resolvedUrl("VideosGridFolder.qml"), properties:{folder: model.get(currentIndex, "filePath"), sortField: sortField, sortReversed: sortReversed}});
                    else
                        stack.push({item: Qt.resolvedUrl("VideosGridFolder.qml"), properties:{folder: model.get(currentIndex, "filePath"), sortField: sortField, sortReversed: sortReversed}});
                }
            }
            else
            {
                if (model.get(currentIndex, "filePath").endsWith(".ISO") || model.get(currentIndex, "filePath").endsWith(".iso") ||
                    model.get(currentIndex, "filePath").endsWith(".IMG") || model.get(currentIndex, "filePath").endsWith(".img"))
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
                        var item = stack.push({item: Qt.resolvedUrl("InternalPlayer.qml"), properties:{defaultFeedSource:  "Adhoc", defaultFilter:  "", defaultCurrentFeed: 0}});
                    }
                }
            }

            event.accepted = true;
        }
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
}
