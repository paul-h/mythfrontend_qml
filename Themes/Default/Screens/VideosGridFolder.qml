import QtQuick 2.0
import "../../../Models"
import Qt.labs.folderlistmodel 2.1
import Base 1.0
import Process 1.0
import Dialogs 1.0

BaseScreen
{
    defaultFocusItem: videoList
    property alias folder: folderModel.folder

    Component.onCompleted:
    {
        showTitle(true, folderModel.folder);
        showTime(false);
        showTicker(false);
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
            player: "Internal"
            duration: ""
        }
    }

    BaseBackground
    {
        x: xscale(15); y: yscale(50); width: xscale(1250); height: yscale(655)
    }

    Keys.onPressed:
    {
        if (event.key === Qt.Key_F1)
        {
            ffmpegProcess.start("/usr/bin/mythffmpeg", ["-i",  "file://" + videoList.model.get(videoList.currentIndex, "filePath"),
                                                        "-vcodec", "copy", "-acodec", "copy",
                                                        "file://" + videoList.model.get(videoList.currentIndex, "filePath") + "_clean.mp4"
                                                       ]);
        }
        else if (event.key === Qt.Key_F2)
        {
        }
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
            {
                return mythUtils.findThemeFile(videoList.model.get(videoList.currentIndex, "filePath") + ".png");
            }
        }
    }

    InfoText
    {
        x: xscale(1050); y: yscale(5); width: xscale(200);
        text: (videoList.currentIndex + 1) + " of " + videoList.model.count;
        horizontalAlignment: Text.AlignRight
    }

    Component
    {
        id: listRow

        ListItem
        {
            height: yscale(62)

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
                    {
                        var result = mythUtils.findThemeFile(filePath + ".png");

                        if (result === "")
                            result = mythUtils.findThemeFile("images/grid_noimage.png");

                        return result;
                    }
                }
            }
            ListText
            {
                width: videoList.width - coverImage.width - xscale(20); height: xscale(50)
                x: coverImage.width + xscale(5)
                text: fileName
            }
        }
    }

    ButtonList
    {
        id: videoList
        x: xscale(25); y: yscale(65); width: xscale(1230); height: yscale(620)

        clip: true

        FolderListModel
        {
            id: folderModel
            folder: settings.videoPath
            nameFilters: ["*.mp4", "*.flv", "*.mp2", "*.wmv", "*.avi", "*.mkv", "*.mpg", "*.iso", "*.ISO", "*.mov", "*.webm"]
        }

        model: folderModel
        delegate: listRow

        Keys.onReturnPressed:
        {
            mediaModel.get(0).title = model.get(currentIndex, "filePath");
            mediaModel.get(0).url = "file://" + model.get(currentIndex, "filePath");

            if (model.get(currentIndex, "fileIsDir"))
            {
                if (model.get(currentIndex, "filePath").endsWith("/VIDEO_TS"))
                {
                    playDVD(model.get(currentIndex, "filePath"))
                }
                else
                    stack.push({item: Qt.resolvedUrl("VideosGridFolder.qml"), properties:{folder: model.get(currentIndex, "filePath")}});
            }
            else
            {
                if (model.get(currentIndex, "filePath").endsWith(".ISO") || model.get(currentIndex, "filePath").endsWith(".iso"))
                {
                    playDVD(model.get(currentIndex, "filePath"))
                }
                else
                {
                    playerSources.adhocList = mediaModel;
                    var item = stack.push({item: Qt.resolvedUrl("InternalPlayer.qml"), properties:{defaultFeedSource:  "Adhoc", defaultFilter:  "", defaultCurrentFeed: 0}});
                    returnSound.play();
                }
            }

            event.accepted = true;
            returnSound.play();
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
}