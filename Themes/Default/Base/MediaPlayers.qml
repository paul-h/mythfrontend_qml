import QtQuick 2.10
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.0
import QtWebEngine 1.5
import QtQuick.XmlListModel 2.0
import Base 1.0
import Process 1.0
import Models 1.0
import QtAV 1.5
import SortFilterProxyModel 0.2
import mythqml.net 1.0
import MDKPlayer 1.0

import "../../../Util.js" as Util

FocusScope
{
    id: root

    property alias feed: feedSource

    property int streamlinkPort: Util.randomIntFromRange(4000, 65536)
    property string commandlog

    // one of Internal, VLC, MDK, QtAV, WebBrowser, YouTube, YouTubeTV, RailCam, StreamLink, StreamBuffer, Tivo
    property string player: ""
    property var videoPlayer: undefined

    property bool showBorder: true
    property bool muteAudio: false
    property bool showRailcamApproach: false
    property bool showRailcamDiagram: false

    // private properties
    property int _mediaStatus: MediaPlayers.MediaStatus.Unknown
    property int _playbackStatus: MediaPlayers.PlaybackStatus.Stopped
    property bool _playbackStarted: false
    property double _wmult: width / 1280
    property double _hmult: height / 720
    property int _browserIndex: 1
    property int _fillMode: MediaPlayers.FillMode.Stretch

    signal playbackEnded()
    signal activeFeedChanged()

    Component.onDestruction:
    {
        if (videoPlayer !== undefined)
            videoPlayer.destroy();
    }

    enum MediaStatus
    {
        Unknown,
        NoMedia,
        Invalid,
        Loading,
        Loaded,
        Buffering,
        Buffered,
        Ended
    }

    enum PlaybackStatus
    {
        Stopped,
        Paused,
        Playing
    }

    enum FillMode
    {
        Stretch,
        PreserveAspectFit,
        PreserveAspectCrop
    }

    function _xscale(x)
    {
        return x * _wmult
    }

    function _yscale(y)
    {
        return y * _hmult
    }

    Timer
    {
        id: updateTimer
        interval: 1000; repeat: true
        running: (feedSource.feedName === "Live TV")
        onTriggered:
        {
            // update now/next program once per minute at 00 seconds
            var now = new Date(Date.now());
            if (now.getSeconds() === 0)
                 getNowNext();
            else
                updateTimeIndicator();
        }
    }

    ProgramListModel
    {
        id: guideModel
        startTime:
        {
            var now = new Date();
            var now2 = new Date(Date.now() + (now.getTimezoneOffset() * 60 * 1000));
            return Qt.formatDateTime(now2, "yyyy-MM-ddThh:mm:ss");
        }
        endTime:
        {
            var now = new Date();
            var now2 = new Date(Date.now() + (now.getTimezoneOffset() * 60 * 1000));
            now2.setDate(now2.getDate() + 1);
            return Qt.formatDateTime(now2, "yyyy-MM-ddThh:mm:ss");
        }

        onStatusChanged: if (status == XmlListModel.Ready) updateNowNext()
    }

    FeedSource
    {
        id: feedSource
        objectName: parent.objectName

        Component.onCompleted: getNowNext();
    }

    Process
    {
        id: streamLinkProcess
        onFinished:
        {
            if (exitStatus == Process.NormalExit)
            {
                //stack.pop();
            }
        }
    }

    Connections
    {
        target: playerSources.zmCameraList
        function onMonitorStatus(monitorId, status)
        {
            if (feedSource.feedName === "ZoneMinder Cameras")
            {
                if (feedSource.feedList.get(feedSource.currentFeed).id === monitorId)
                {
                    statusText.text = status;
                    statusText.state = status;
                }
            }
        }
    }

    Timer
    {
        id: checkProcessTimer
        interval: 1000; running: false; repeat: true
        onTriggered:
        {
            if (player === "StreamLink")
            {
                commandlog = streamLinkProcess.readAllStandardOutput();
                if (commandlog.includes("No playable streams found on this URL"))
                {
                    showMessage("No playable streams found!", settings.osdTimeoutMedium);
                    checkProcessTimer.stop();
                }
                else if (commandlog.includes("Starting server, access with one of:"))
                {
                    checkProcessTimer.stop();
                    videoPlayer.visible = true;
                    switchURL("http://127.0.1.1:" + streamlinkPort + "/");
                }
            }
            else
            {
                // player must be StreamBuffer

                commandlog = streamLinkProcess.readAllStandardError();
                if (commandlog.includes("Invalid data found when processing input"))
                {
                    showMessage("No playable streams found!", settings.osdTimeoutMedium);
                    checkProcessTimer.stop();
                }
                else if (commandlog.includes("Press [q] to stop, [?] for help"))
                {
                    checkProcessTimer.stop();
                    videoPlayer.visible = true;
                    delay(5000, root.playStream);
                }
            }
         }
    }

    DelayTimer
    {
        id: tabDelay
    }

    DelayTimer
    {
        id: returnDelay
    }

    Rectangle
    {
        id: playerRect
        anchors.fill: parent
        focus: true
        color: "black"
        radius: theme.bgRadius
    }

    WebEngineProfile
    {
        id: youtubeWebProfile
        storageName: "YouTube_" + objectName
        offTheRecord: false
        httpCacheType: WebEngineProfile.DiskHttpCache
        persistentCookiesPolicy: WebEngineProfile.AllowPersistentCookies
        httpUserAgent: "Mozilla/5.0 (SMART-TV; Linux; Tizen 5.0) AppleWebKit/538.1 (KHTML, like Gecko) Version/5.0 NativeTVAds Safari/538.1"
    }

    WebEngineProfile
    {
        id: mythqmlWebProfile
        storageName: "MythQML_" + objectName
        offTheRecord: false
        httpCacheType: WebEngineProfile.DiskHttpCache
        persistentCookiesPolicy: WebEngineProfile.AllowPersistentCookies
        //httpUserAgent: "Mozilla/5.0 (SMART-TV; Linux; Tizen 5.0) AppleWebKit/538.1 (KHTML, like Gecko) Version/5.0 NativeTVAds Safari/538.1"
    }

    ListModel
    {
        id: browserURLList

        property int currentIndex: 0
    }

    ListModel
    {
        id: radioFeedList

        property int currentIndex: 0
    }

    RailcamModel
    {
        id: railcamModel
        mediaPlayer: root

        onMiniDiagramImageChanged: mediaPlayer.updateRailCamMiniDiagram(railcamImageFilename)
     }

    InfoText
    {
        id: statusText
        x: parent. width - xscale(10) - width
        y: yscale(0)
        width: xscale(150)
        height: yscale(30)
        horizontalAlignment: Text.AlignRight
        visible: state === "Pre Alarm" || state === "Alert" || state === "Alarm"

        states:
        [
            State
            {
                name: "Idle"
                PropertyChanges { target: statusText; fontColor: "white" }
            },
            State
            {
                name: "Pre Alarm"
                PropertyChanges { target: statusText; fontColor: "yellow" }
            },
            State
            {
                name: "Alert"
                PropertyChanges { target: statusText; fontColor: "orange" }
            },
            State
            {
                name: "Alarm"
                PropertyChanges { target: statusText; fontColor: "red" }
            },
            State
            {
                name: "Tape"
                PropertyChanges { target: statusText; fontColor: "green" }
            },
            State
            {
                name: "Unknown"
                PropertyChanges { target: statusText; fontColor: "white" }
            }
        ]
    }

    Item
    {
        id: railcamMiniDiagram
        property bool hasDiagram: true
        property alias source: diagram.source

        x: 0
        y: (parent.height / 2) - railcamApproaching.height - yscale(10)
        width: parent.width
        height: parent.height / 2
        visible: false

        Image
        {
            id: diagram

            x: _xscale(100)
            y: 0
            width: parent.width - _xscale(200)
            height: parent.height
            verticalAlignment: Image.AlignBottom
            opacity: 0.9
            visible: railcamMiniDiagram.hasDiagram
            cache: false
            fillMode: Image.PreserveAspectFit
            source: ""
        }

        Rectangle
        {
            id: noDiagrams
            x: (parent.width / 2) - _xscale(300)
            y: parent.height / 2
            width: _xscale(600)
            height: parent.height / 2
            color: "#000000"
            opacity: 0.75
            visible: !railcamMiniDiagram.hasDiagram

            InfoText
            {
                anchors.fill: parent
                horizontalAlignment: Text.AlignHCenter
                multiline: true
                text: "This RailCam webcam does not provide any realtime diagrams"
            }
        }

        Tracer{}
    }

    Item
    {
        id: railcamApproaching

        property bool hasData: true

        x: showBorder ? xscale(5) : 0
        y: parent.height - _yscale(50) - (showBorder ? yscale(5) : 0)
        width: parent.width - (showBorder ? xscale(10) : 0)
        height: _yscale(50)
        visible: false

        Rectangle
        {
            anchors.fill: parent
            color: "#000000"
            opacity: 0.75
        }

        InfoText
        {
            id: noAproachingData
            anchors.fill: parent
            horizontalAlignment: Text.AlignHCenter
            visible: !railcamApproaching.hasData
            text: "This RailCam webcam does not provide any live data"
        }

        Item
        {
            anchors.fill: parent
            visible: railcamApproaching.hasData

            Image
            {
                x: _xscale(5)
                y: _yscale(5)
                width: _xscale(40)
                height: _yscale(40)
                horizontalAlignment: Image.AlignHCenter
                verticalAlignment: Image.AlignVCenter
                fillMode: Image.PreserveAspectFit
                source: railcamModel.approachLeftList.count === 0 ?  mythUtils.findThemeFile("images/grey_rewind.png") : mythUtils.findThemeFile("images/rewind.png")
            }

            InfoText
            {
                x: _xscale(50)
                y: _yscale(5)
                width: _xscale(200)
                height: _yscale(40)
                fontPixelSize: _xscale(20)
                text: "Nothing in-range"
                visible: (railcamModel.approachLeftList.count === 0)
            }

            Image
            {
                x: parent.width - _xscale(45)
                y: _yscale(5)
                width: _xscale(40)
                height: _yscale(40)
                horizontalAlignment: Image.AlignHCenter
                verticalAlignment: Image.AlignVCenter
                fillMode: Image.PreserveAspectFit
                source: railcamModel.approachRightList.count === 0 ?  mythUtils.findThemeFile("images/grey_fastforward.png") :mythUtils.findThemeFile("images/fastforward.png")
            }

            InfoText
            {
                x: parent.width - _xscale(250)
                y: _yscale(5)
                width: _xscale(200)
                height: _yscale(40)
                horizontalAlignment: Text.AlignRight
                fontPixelSize: _xscale(20)
                text: "Nothing in-range"
                visible: (railcamModel.approachRightList.count === 0)
            }

            Component
            {
                id: listRow

                Item
                {
                    width: _xscale(180); height: leftList.height

                    // background
                    Rectangle
                    {
                        anchors.fill: parent
                        color: "#000000"
                        opacity: 0.5
                        border.color: "grey"
                        border.width: _xscale(2)
                        radius: _xscale(5)
                    }

                    // signal
                    Rectangle
                    {
                        x: _xscale(5)
                        y: _yscale(8)
                        width: _xscale(14)
                        height: parent.height - _yscale(14)
                        color: "#000000"
                        opacity: 1.0
                        border.color: "white"
                        border.width: _xscale(1)
                        radius: _xscale(5)

                        Rectangle
                        {
                            x: _xscale(3)
                            y: _yscale(4)
                            width: _xscale(8)
                            height: width
                            radius: width / 2
                            color:
                            {
                                if (status == "Passing")
                                    return "green"
                                else if (status == "Passed")
                                    return "red"
                                else if (status == "At Platform")
                                    return "black"
                                else if (status == "Waiting")
                                    return "Orange"
                                else if (status == "Approaching")
                                {
                                    if (approach_ind === "<1" || approach_ind === ">1")
                                        return "yellow"
                                    else
                                        return "black"
                                }
                            }
                        }

                        Rectangle
                        {
                            x: _xscale(3)
                            y: _yscale(14)
                            width: _xscale(8)
                            height: width
                            radius: width / 2
                            color:
                            {
                                if (status == "Passing")
                                    return "black"
                                else if (status == "Passed")
                                    return "black"
                                else if (status == "At Platform")
                                    return "white"
                                else if (status == "Waiting")
                                    return "Orange"
                                else if (status == "Approaching")
                                    return "yellow"
                            }
                        }
                    }

                    InfoText
                    {
                        x: _xscale(23)
                        y: 0
                        width: _xscale(60)
                        height: parent.height
                        text: headcode
                        fontPixelSize: _xscale(20)
                        horizontalAlignment: Text.AlignHCenter
                        fontColor:
                        {
                            if (status == "Passing")
                                return "Green"
                            else if (status == "Approaching")
                                return "Yellow"
                            else if (status == "Passed")
                                return "red"
                            else if (status == "Waiting")
                                return "Orange"
                            else
                                return "white"
                        }
                    }

                    InfoText
                    {
                        x: _xscale(85)
                        y: 0
                        width: _xscale(100)
                        height: parent.height
                        text: status
                        fontColor: "white"
                        fontPixelSize: _xscale(16)
                    }
                }
            }

            ListView
            {
                id: leftList
                x: _xscale(55)
                y: _yscale(5)
                width: (parent.width / 2) - _xscale(60)
                height: _yscale(40)
                spacing: _xscale(5)
                orientation: ListView.Horizontal
                clip: true
                delegate: listRow
                model: railcamModel.approachLeftList
                Tracer {}
            }

            ListView
            {
                id: rightList
                x: (parent.width / 2) + _xscale(5)
                y: _yscale(5)
                width: (parent.width / 2) - _xscale(60)
                height: _yscale(40)
                spacing: _xscale(5)
                orientation: ListView.Horizontal
                layoutDirection: Qt.RightToLeft
                clip: true
                delegate: listRow
                model: railcamModel.approachRightList
                Tracer {}
            }
        }
    }

    Rectangle
    {
        id: playerBorder
        anchors.fill: parent
        focus: true
        color: "transparent"
        border.color: root.focus ? theme.lvBackgroundBorderColor : theme.bgBorderColor
        border.width: root.showBorder ? xscale(5) : 0
        radius: theme.bgRadius
    }

    Timer
    {
        id: infoTimer
        interval: settings.osdTimeoutMedium; running: false; repeat: false
        onTriggered: { infoPanel.visible = false; updateRailcamApproach(); }
    }

    BaseBackground
    {
        id: infoPanel
        x: xscale(10);
        y: parent.height - ((feedSource.feedName === "Live TV") ? _yscale(330) : _yscale(160)) - yscale(10);
        width: parent.width - xscale(20);
        height: (feedSource.feedName === "Live TV") ? _yscale(330) : _yscale(160)

        visible: false

        Image
        {
            id: icon
            x: _xscale(10)
            y: _yscale(10)
            width: _xscale(100)
            height: _yscale(100)

            onStatusChanged: if (status == Image.Error) source = mythUtils.findThemeFile("images/grid_noimage.png")
        }

        TitleText
        {
            id: title
            x: icon.width + _xscale(15)
            y: _yscale(5)
            width: parent.width - currFeed.width - icon.width - _xscale(25)
            height: _yscale(50)
            fontPixelSize: (_xscale(24) + _yscale(24)) / 2

            verticalAlignment: Text.AlignTop
        }

        Item
        {
            id: nowNextInfo

            x: 0
            y: _yscale(110)
            width: parent.width
            height: parent.height - y

            visible: (feedSource.feedName === "Live TV")

            RichText
            {
                id: programTitle
                x: _xscale(30)
                y: 0
                width: _xscale(700)
                height: _yscale(25)
                labelFontPixelSize: (_xscale(16) + _yscale(16)) / 2
                infoFontPixelSize: (_xscale(16) + _yscale(16)) / 2
                label: "Now: "
            }

            InfoText
            {
                id: programDesc
                x: _xscale(30); y: _yscale(45)
                width: parent.width - _xscale(60); height: _yscale(75)
                verticalAlignment: Text.AlignTop
                fontPixelSize: (_xscale(14) + _yscale(14)) / 2
                multiline: true
            }

            InfoText
            {
                id: programStatus
                x: parent.width - _xscale(296); y: _yscale(150); width: _xscale(266); height: _yscale(25)
                horizontalAlignment: Text.AlignRight
                fontColor: if (text === "Recording") "red"; else theme.infoFontColor;
                fontPixelSize: (_xscale(16) + _yscale(16)) / 2
            }

            InfoText
            {
                id: programCategory
                x: xscale(20); y: _yscale(150); width: _xscale(220); height: _yscale(25)
                fontColor: "grey"
                fontPixelSize: (_xscale(16) + _yscale(16)) / 2
            }

            InfoText
            {
                id: programEpisode
                x: _xscale(315); y: _yscale(150); width: _xscale(320); height: _yscale(25)
                horizontalAlignment: Text.AlignHCenter
                fontColor: "grey"
                fontPixelSize: (_xscale(16) + _yscale(16)) / 2
            }

            InfoText
            {
                id: programFirstAired
                x: _xscale(650); y: _yscale(150); width: _xscale(280); height: _yscale(25)
                fontColor: "grey"
                horizontalAlignment: Text.AlignRight
                fontPixelSize: (_xscale(16) + _yscale(16)) / 2
            }

            InfoText
            {
                id: programLength
                x: parent.width - _xscale(120); y: 0; width: _xscale(90)
                height: _yscale(25)
                fontColor: "grey"
                horizontalAlignment: Text.AlignRight
                fontPixelSize: (_xscale(16) + _yscale(16)) / 2
            }

            RichText
            {
                id: programNext
                x: _xscale(30)
                y: _yscale(106)
                width: _xscale(910)
                height: _yscale(25)
                label: "Next: "
                labelFontPixelSize: (_xscale(16) + _yscale(16)) / 2
                infoFontPixelSize: (_xscale(16) + _yscale(16)) / 2
            }

            Item
            {
                id: timeIndictor

                property int position: 0
                property int length: 100

                x: programLength.x -_xscale(120)
                y: _yscale(8)
                width: _xscale(100)
                height: yscale(8)

                Rectangle
                {
                    anchors.fill: parent
                    color: "white"
                }

                Rectangle
                {
                    x: 0; y: 0; height: parent.height;
                    width: (parent.width / timeIndictor.length) * timeIndictor.position
                    color: "red"
                }
            }

            Image
            {
                id: recordingIcon
                x: _xscale(900); y: _yscale(130); width: xscale(32); height: yscale(32)
                source: mythUtils.findThemeFile("images/recording.png")
                visible: (guideModel.count > 0 && guideModel.get(0).RecordingStatus === "Recording")
            }
        }

        InfoText
        {
            id: pos
            x: _xscale(55) + icon.width
            y: _yscale(50)
            width: _xscale(400)
            height: _yscale(50)
            fontPixelSize: (_xscale(16) + _yscale(16)) / 2
            text:
            {
                if (player === "VLC" || player === "QTAV" || player === "YOUTUBE" || player === "MDK")
                    return "Position: " + Util.milliSecondsToString(videoPlayer.getPosition()) + " / " + Util.milliSecondsToString(videoPlayer.getDuration())
                else
                    return "Position: N/A"
            }
        }

        InfoText
        {
            id: timeLeft
            x: parent.width - width - _xscale(15);
            y: _yscale(50)
            width: _xscale(240)
            height: _yscale(50)
            fontPixelSize: (_xscale(16) + _yscale(16)) / 2
            text:
            {
                if (player === "VLC" || player === "QTAV" || player === "YOUTUBE" || player === "MDK")
                    return Util.milliSecondsToString(videoPlayer.getDuration() - videoPlayer.getPosition())
                else
                    "Remaining : N/A"
            }

            horizontalAlignment: Text.AlignRight
        }

        InfoText
        {
            id: currFeed
            x: parent.width - width - _xscale(15)
            y: _yscale(0)
            width: _xscale(240)
            height: _yscale(50)
            fontPixelSize: (_xscale(16) + _yscale(16)) / 2
            text: feedSource.currentFeed + 1 + " of " + feedSource.feedCount + " (" + feedSource.feedName + ")"

            horizontalAlignment: Text.AlignRight
        }

        InfoText
        {
            id: currPlayer
            x: parent.width - width - _xscale(15)
            y: _yscale(24)
            width: _xscale(240)
            height: _yscale(50)
            fontPixelSize: (_xscale(16) + _yscale(16)) / 2
            text: player;

            horizontalAlignment: Text.AlignRight
        }

        Footer
        {
            id: footer
            x: root._xscale(5)
            y: parent.height - root._yscale(38)
            width: parent.width - root._xscale(10)
            height: root._yscale(32)

            redText: "Previous"
            greenText: "Next"
            yellowText:
            {
                "Show Web Pages";
            }
            blueText:
            {
                if (player === "RailCam")
                    "Show RailCam Info";
                else
                    "";
            }

            Tracer {}
       }


        RowLayout
        {
            id: toolbar
            opacity: .55
            spacing: _xscale(10)
            x: _xscale(15) + icon.width
            y: _yscale(70)
            width: parent.width - _xscale(25) - icon.width
            height: _yscale(50)
            anchors.bottomMargin: spacing
            anchors.leftMargin: spacing * _xscale(1.5)
            anchors.rightMargin: spacing * _xscale(1.5)
            Behavior on anchors.bottomMargin { PropertyAnimation { duration: 250} }
            Rectangle
            {
                height: _yscale(25)
                width: height
                radius: width * _xscale(0.25)
                color: 'black'
                border.width: _xscale(1)
                border.color: 'white'
                Image
                {
                    source:  _playbackStatus === MediaPlayers.PlaybackStatus.Playing ? mythUtils.findThemeFile("images/player/play.png") : (_playbackStatus === MediaPlayers.PlaybackStatus.Paused ? mythUtils.findThemeFile("images/player/pause.png") : mythUtils.findThemeFile("images/player/stop.png"))
                    anchors.fill: parent
                }
            }
            Rectangle
            {
                Layout.fillWidth: true
                height: _yscale(10)
                color: 'transparent'
                border.width: _xscale(1)
                border.color: 'white'
                Rectangle
                {
                    width:
                    {
                        var position = 1;

                        if (player === "VLC" || player === "QTAV" || player === "YOUTUBE" || player === "MDK")
                            position = videoPlayer.getPosition() / videoPlayer.getDuration();

                        return (parent.width - anchors.leftMargin - anchors.rightMargin) * position;
                    }
                    color: 'blue'
                    anchors.margins: _xscale(2)
                    anchors.top: parent.top
                    anchors.left: parent.left
                    anchors.bottom: parent.bottom
                }
            }
        }
    }

    BaseBackground
    {
        id: browsePanel
        x: xscale(10);
        y: parent.height - _yscale(160) - yscale(10);
        opacity: 0.75
        width: parent.width - xscale(20);
        height: _yscale(160)

        visible: false

        Image
        {
            id: b_icon
            x: _xscale(10)
            y: _yscale(10)
            width: _xscale(100)
            height: _yscale(100)

            onStatusChanged: if (status == Image.Error) source = mythUtils.findThemeFile("images/grid_noimage.png")
        }

        TitleText
        {
            id: b_title
            x: b_icon.width + _xscale(15)
            y: _yscale(5)
            width: parent.width - b_currFeed.width - b_icon.width - _xscale(25)
            height: _yscale(50)
            fontPixelSize: (_xscale(24) + _yscale(24)) / 2
            verticalAlignment: Text.AlignTop
        }

        InfoText
        {
            id: b_currFeed
            x: parent.width - width - _xscale(15)
            y: _yscale(0)
            width: _xscale(240)
            height: _yscale(50)
            fontPixelSize: (_xscale(16) + _yscale(16)) / 2
            text: _browserIndex + 1 + " of " + feedSource.feedCount + " (" + feedSource.feedName + ")"

            horizontalAlignment: Text.AlignRight
        }

        InfoText
        {
            id: b_description
            x: b_icon.width + _xscale(15)
            y: _yscale(32)
            width: parent.width - b_currFeed.width - b_icon.width - _xscale(25)
            height: _yscale(60)
            verticalAlignment: Text.AlignTop
            multiline: true
            fontPixelSize: _xscale(13)
        }

        InfoText
        {
            id: b_category
            x: b_icon.width + _xscale(15)
            y: _yscale(75);
            width: parent.width - b_currFeed.width - b_icon.width - _xscale(25)
            fontColor: "grey"
        }

        Footer
        {
            id: b_footer
            x: root._xscale(5)
            y: parent.height - root._yscale(38)
            width: parent.width - root._xscale(10)
            height: root._yscale(32)

            redText: "Previous"
            greenText: "Next"
            yellowText:
            {
                "Show Web Pages";
            }
            blueText:
            {
                if (player === "RailCam")
                    "Show RailCam Info";
                else
                    "";
            }
        }
    }

    BusyIndicator
    {
        id: busyIndicator
        x: (parent.width / 2) - (width / 2)
        y: (parent.height / 2) - (height / 2)
        running: visible
        visible: false
    }

    InfoText
    {
        id: busyText
        x: (parent.width / 2) - (width / 2)
        y: busyIndicator.y + busyIndicator.height + yscale(10)
        visible: false
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        fontPixelSize: (_xscale(20) + _yscale(20)) / 2
        text: "Loading..."
    }

    Timer
    {
        id: messageTimer
        interval: 6000; running: false; repeat: false
        onTriggered: messagePanel.visible = false;
    }

    BaseBackground
    {
        id: messagePanel
        x: _xscale(100); y: _yscale(120); width: _xscale(400); height: _yscale(110)
        visible: false

        InfoText
        {
            id: messageText
            anchors.fill: parent
            horizontalAlignment: Text.AlignHCenter
            fontPixelSize: (_xscale(20) + _yscale(20)) / 2
        }
    }

    function isPlaying()
    {
        return _playbackStarted;
    }

    function showMessage(message, timeOut)
    {
        if (!timeOut)
            timeOut = settings.osdTimeoutMedium;

        if (message !== "")
        {
            messageText.text = message;
            messagePanel.visible = true;
            messageTimer.interval = timeOut
            messageTimer.restart();
        }
        else
        {
            messageText.text = message;
            messagePanel.visible = false;
            messageTimer.stop();
        }
    }

    function mediaStatusChanged(mediaStatus)
    {
        if (mediaStatus === _mediaStatus)
            return;

        _mediaStatus = mediaStatus;

       log.debug(Verbose.PLAYBACK, "MediaPlayers: mediaStatus: " + mediaStatus + " for source: " + feedSource.feedList.get(feedSource.currentFeed).url);

        if (mediaStatus === MediaPlayers.MediaStatus.NoMedia)
        {
            showMessage("No Media!!", settings.osdTimeoutMedium);
        }
        else if (mediaStatus === MediaPlayers.MediaStatus.Invalid)
        {
            busyIndicator.visible = false;
            busyText.visible = true;
            busyText.text = "Cannot play this file";
        }
        else if (mediaStatus === MediaPlayers.MediaStatus.Ended)
        {
            // playback ended
            busyIndicator.visible = false;
            busyText.visible = false;
            root.playbackEnded();
        }
        else if (mediaStatus === MediaPlayers.MediaStatus.Buffered)
        {
            // playback started
            busyIndicator.visible = false;
            busyText.visible = false;
        }
        else if (mediaStatus === MediaPlayers.MediaStatus.Loading)
        {
            busyIndicator.visible = true;
            busyText.visible = true;
            busyText.text = "Loading..."
        }
        else if (mediaStatus === MediaPlayers.MediaStatus.Loaded)
        {
            busyIndicator.visible = false;
            busyText.visible = false;
            busyText.text = "";
        }
        else if (mediaStatus === MediaPlayers.MediaStatus.Buffering)
        {
            busyIndicator.visible = true;
            busyText.visible = true;
            busyText.text = "Buffering...";
        }
        else
        {
            busyIndicator.visible = false;
            busyText.visible = false;
            busyText.text = "";
        }
    }

    function playbackStatusChanged(playbackStatus)
    {
        if (playbackStatus === _playbackStatus)
            return;

        _playbackStatus = playbackStatus;

        log.debug(Verbose.PLAYBACK, "MediaPlayers: playbackStatus: " + playbackStatus + " for source: " + feedSource.feedList.get(feedSource.currentFeed).url);

        if (playbackStatus === MediaPlayers.PlaybackStatus.Stopped)
        {

        }
        else if (playbackStatus === MediaPlayers.PlaybackStatus.Playing)
        {
            showMessage("", 0)
        }
        else if (playbackStatus === MediaPlayers.PlaybackStatus.Paused)
        {

        }
    }

    function switchPlayer(newPlayer)
    {
        streamLinkProcess.stop();
        checkProcessTimer.running = false;
        streamLinkProcess.waitForFinished();

        if (player === "WebBrowser" || player === "RailCam" || player === "YouTubeTV")
            videoPlayer.url = "about:blank";
        else
        {
            if (videoPlayer !== undefined)
                videoPlayer.stop();
        }

        activeFeedChanged();
        showMessage("", 0);

        // we always need to restart the StreamLink/StreamBuffer process even if it is already running
        if (newPlayer === "StreamLink" || newPlayer === "StreamBuffer")
        {
            videoPlayer.visible = false;

            commandlog = "";

            var url = feedSource.feedList.get(feedSource.currentFeed).url;
            var command = "";
            var parameters = ""
            if (newPlayer === "StreamLink")
            {
                var pluginPath = settings.sharePath.replace("file://", "") + "qml/Streamlink/plugins/"
                // also search for plugins in the streamlink directory in the same location as the webcams list file
                pluginPath += "," + Util.getPath(settings.webcamListFile.replace("file://", "")) + "/streamlink";

                command = "streamlink"
                parameters = ["--plugin-dirs", pluginPath, "--player-external-http", "--player-external-http-port", streamlinkPort, url, "best"]


            }
            else
            {
                // player is "StreamBuffer"
                var outputFilename = settings.configPath + "stream.ts";

                // delete any old stream.ts file
                mythUtils.removeFile(outputFilename);

                command = "ffmpeg"
                parameters = ["-re", "-t", "7200", "-i", url, "-c", "copy", outputFilename];
            }

            // run the command
            streamLinkProcess.start(command, parameters);

            // start the timer to check the log
            checkProcessTimer.running = true;

            root.player = newPlayer;

            showMessage("Starting Streamer. Please Wait....", settings.osdTimeoutLong)
            return;
        }

        if (newPlayer === root.player)
            return;

        // if the player is Internal we can use any of VLC, QtAV or MDK players
        if (newPlayer === "Internal")
        {
            newPlayer = dbUtils.getSetting("InternalPlayer", settings.hostName, "VLC");
            log.info(Verbose.PLAYBACK, "MediaPlayers: switchPlayer -  using " + newPlayer + " for the Internal player");
        }

        if (newPlayer === "VLC")
        {
            createVLCPlayer();
        }
        else if (newPlayer === "FFMPEG" || newPlayer === "QtAV")
        {
            createQtAVPlayer();
        }
        else if (newPlayer === "MDK")
        {
            createMDKPlayer();
        }
        else if (newPlayer === "TIVO")
        {
            createTivoPlayer();
        }
        else if (newPlayer === "WebBrowser" || newPlayer === "RailCam")
        {
            createWebPlayer();
        }
        else if (newPlayer === "YouTube")
        {
            // this uses the embedded YouTube player
            createYoutubePlayer();
        }
        else if (newPlayer === "YouTubeTV")
        {
            // this uses the YouTube TV web player
            createWebPlayer();
        }
        else
        {
            log.error(Verbose.PLAYBACK, "MediaPlayers: switchPlayer - Got unknown player '" + newPlayer + "'");
            return;
        }

        root.player = newPlayer;
    }

    function switchURL(newURL)
    {
        log.debug(Verbose.PLAYBACK, "MediaPlayers: switchURL -  " + newURL);

        if (!feedSource.feedList.get(feedSource.currentFeed))
            title.text = "";
        else if (feedSource.feedList.get(feedSource.currentFeed).title !== undefined)
            title.text = feedSource.feedList.get(feedSource.currentFeed).title;
        else if (feedSource.feedList.get(feedSource.currentFeed).url !== undefined)
            title.text = feedSource.feedList.get(feedSource.currentFeed).url;
        else
            title.text = "";

        if (feedSource.feedName == "ZoneMinder Cameras")
            newURL += "&connkey=" + Util.randomIntFromRange(0, 999999);

        if (root.player === "VLC" || root.player === "Internal")
        {
            videoPlayer.source = newURL;
        }
        else if (root.player === "FFMPEG" || root.player === "QtAV")
        {
            videoPlayer.stop();
            videoPlayer.source = newURL;
            // we have to fake a loading signal because QtAV does not send one
            mediaStatusChanged(MediaPlayers.MediaStatus.Loading);
        }
        else if (root.player === "WebBrowser" || root.player === "RailCam")
        {
            videoPlayer.profile = mythqmlWebProfile;
            videoPlayer.url = newURL;
        }
        else if (root.player === "YouTubeTV")
        {
            videoPlayer.profile = youtubeWebProfile;
            videoPlayer.url = newURL;
        }
        else if (root.player === "YouTube")
        {
            var videoID = "''";
            var pos = newURL.indexOf("=");
            if (pos > 0)
                    videoID = "'" + newURL.slice(pos + 1, pos + 12) + "'";

            videoPlayer.source = videoID;
        }
        else if (root.player === "StreamLink" || root.player === "StreamBuffer")
        {
            videoPlayer.source = newURL;
            videoPlayer.play();
        }
        else if (root.player === "MDK")
        {
            videoPlayer.source = newURL;
        }
        else if (root.player === "TIVO")
        {
            //tivoPlayer.source = newURL;
            videoPlayer.changeChannel(newURL);
        }
        else
        {
            log.error(Verbose.PLAYBACK, "MediaPlayers: switchURL - Unknown player '" + root.player + "'");
            return;
        }
    }

    function startPlayback()
    {
        if (feedSource.feedList === undefined ||
                feedSource.feedList.get(feedSource.currentFeed).player === undefined ||
                feedSource.feedList.get(feedSource.currentFeed).url === undefined)
            return;

        var newPlayer = feedSource.feedList.get(feedSource.currentFeed).player;
        switchPlayer(newPlayer);

        if (newPlayer !== "StreamLink" && newPlayer !== "StreamBuffer")
        {
            var newURL = feedSource.feedList.get(feedSource.currentFeed).url;
            switchURL(newURL);
        }

        _playbackStarted = true;

        updateOSD();
    }

    function play(forceRestart)
    {
        if (forceRestart || !_playbackStarted)
            startPlayback();
        else
            videoPlayer.play();
    }

    function stop()
    {
        streamLinkProcess.stop();
        checkProcessTimer.running = false;
        streamLinkProcess.waitForFinished();

        if (player === "VLC" || player === "QTAV" || player === "YOUTUBE" || player === "MDK"|| player === "TIVO")
            videoPlayer.stop();
        else if (videoPlayer === "BROWSER")
            videoPlayer.url = "about:blank";
    }

    function togglePaused()
    {
        videoPlayer.togglePaused();
    }

    function toggleOnline()
    {
        if (feedSource.feedName === "Webcams")
        {
            var id = feedSource.feedList.sourceModel.get(feedSource.currentFeed).id;
            var index = feedSource.feedList.sourceModel.findById(id);

            if (index != -1)
                feedSource.feedList.sourceModel.get(index).offline = !feedSource.feedList.sourceModel.get(index).offline;
        }
    }

    function toggleMute()
    {
        root.muteAudio = !root.muteAudio;

        videoPlayer.setMute(root.muteAudio);

        showMessage("Mute: " + (root.muteAudio ? "On" : "Off"), settings.osdTimeoutMedium);
    }

    function changeVolume(amount)
    {

        videoPlayer.changeVolume(amount);

        dbUtils.setSetting("Video" + objectName.replace(" ", "") + "Volume", settings.hostName, videoPlayer.getVolume());
    }

    function getVolume()
    {
        return videoPlayer.getVolume();
    }

    function setVolume(volume)
    {
        videoPlayer.setVolume(volume);
    }

    function toggleFillMode()
    {
        if (_fillMode === MediaPlayers.FillMode.Stretch)
            _fillMode = MediaPlayers.FillMode.PreserveAspectFit;
        else if (_fillMode === MediaPlayers.FillMode.PreserveAspectFit)
            _fillMode = MediaPlayers.FillMode.PreserveAspectCrop;
        else if (_fillMode === MediaPlayers.FillMode.PreserveAspectCrop)
            _fillMode = MediaPlayers.FillMode.Stretch;

        setFillMode(_fillMode);
    }

    function setFillMode(mode)
    {
        if (player === "VLC" || player === "QTAV" || player === "YOUTUBE" || player === "MDK"|| player === "TIVO")
            videoPlayer.setFillMode(mode);
    }

    function skipBack(time)
    {
        if (player === "VLC" || player === "QTAV" || player === "YOUTUBE" || player === "MDK"|| player === "TIVO")
            videoPlayer.skipBack(time);
    }

    function skipForward(time)
    {
        if (player === "VLC" || player === "QTAV" || player === "YOUTUBE" || player === "MDK"|| player === "TIVO")
            videoPlayer.skipForward(time);
    }

    function toggleInterlacer()
    {
        if (player === "VLC" || player === "QTAV" || player === "MDK"|| player === "TIVO")
            videoPlayer.toggleInterlacer();
    }

    function toggleInfo()
    {
        if (!infoPanel.visible && !browsePanel.visible)
            showInfo(false);
        else if (infoPanel.visible && !browsePanel.visible)
            showFeedBrowser();
        else
        {
            hideInfo();
            hideFeedBrowser();
        }
    }

    function showInfo(restart)
    {
        if (browsePanel.visible)
            return;

        // don't show the info panel if it's to small to see
        if (infoPanel.width < 400)
            return;

        if (restart)
        {
            // restart the timer
            infoPanel.visible = true;
            infoTimer.restart();
        }
        else
        {
            if (infoPanel.visible)
                infoPanel.visible = false;
            else
            {
                infoPanel.visible = true;
                infoTimer.start();
            }
        }

        updateRailcamApproach();
    }

    function hideInfo()
    {
        infoPanel.visible = false;
        infoTimer.stop();
    }

    function showFeedBrowser()
    {
        _browserIndex = feedSource.currentFeed;
        hideInfo();
        updateBrowserFeed();
        browsePanel.visible = true;
    }

    function showingFeedBrowser()
    {
        return browsePanel.visible
    }

    function previousBrowserFeed()
    {
        _browserIndex--;

        if (_browserIndex < 0)
            _browserIndex = feedSource.feedList.count - 1;

        updateBrowserFeed();
    }

    function nextBrowserFeed()
    {
        _browserIndex++;

        if (_browserIndex >= feedSource.feedList.count)
            _browserIndex = 0;

        updateBrowserFeed();
    }

    function updateBrowserFeed()
    {
        if (!feedSource.feedList.get(_browserIndex))
            b_icon.source = mythUtils.findThemeFile("images/grid_noimage.png");
        else
            b_icon.source = getIconURL(feedSource.feedList.get(_browserIndex).icon);

        if (!feedSource.feedList.get(_browserIndex))
            b_title.text = "";
        else if (feedSource.feedList.get(_browserIndex).title !== undefined)
            b_title.text = feedSource.feedList.get(_browserIndex).title
        else if (feedSource.feedList.get(_browserIndex).url !== undefined)
            b_title.text = feedSource.feedList.get(_browserIndex).url
        else
            b_title.text = ""

        if (!feedSource.feedList.get(_browserIndex))
            b_category.text = "";
        else
            b_category.text = feedSource.feedList.get(_browserIndex).categories

        if (!feedSource.feedList.get(_browserIndex))
            b_description.text = "";
        else
            b_description.text = feedSource.feedList.get(_browserIndex).description

    }

    function hideFeedBrowser()
    {
        browsePanel.visible = false;
    }

    function selectFeedBrowser()
    {
        goToFeed(_browserIndex);
    }

    function goToFeed(feedIndex)
    {
        stop();
        feedSource.currentFeed = feedIndex;
        play(true);
        updateOSD();
        showInfo(true);
    }

    function nextFeed()
    {
        if (feedSource.feedName === "Advent Calendar")
            return;

        stop();

        if (feedSource.currentFeed === feedSource.feedCount - 1)
        {
            feedSource.currentFeed = 0;
        }
        else
            feedSource.currentFeed++;

        play(true);

        updateOSD();

        showInfo(true);
    }

    function previousFeed()
    {
        if (feedSource.feedName === "Advent Calendar")
            return;

        stop();

        if (feedSource.currentFeed === 0)
        {
            feedSource.currentFeed = feedSource.feedList.count - 1;
        }
        else
            feedSource.currentFeed--;

        play(true);

        updateOSD();

        showInfo(true);
    }

    function getLink(linktype)
    {
        if (!feedSource.feedList.get(feedSource.currentFeed).links || feedSource.feedList.get(feedSource.currentFeed).links === "")
            return undefined;

        var links = feedSource.feedList.get(feedSource.currentFeed).links.split("\n");

        for (var x = 0; x < links.length; x++)
        {
            if (links[x].startsWith(linktype))
            {
                return links[x].substring(linktype.length + 1, links[x].length);
            }
        }

        return undefined;
    }

    function getBrowserURL(o)
    {
        if (browserURLList.count === 0)
            return false;

        o.title = browserURLList.get(browserURLList.currentIndex).title;
        o.url = browserURLList.get(browserURLList.currentIndex).url;
        o.width = browserURLList.get(browserURLList.currentIndex).width;
        o.zoom = browserURLList.get(browserURLList.currentIndex).zoom;

        return true;
    }

    function getBrowserURLList()
    {
        return browserURLList;
    }

    function updateBrowserURLList()
    {
        browserURLList.clear();

        // add any RailCam Train Times
        var url = "https://railcam.uk/rcdata/RCData2_detail.php?r=S&hc={HEADCODE}&td={AREACODE}&vip=Y";

        var headCode = ""
        var areaCode = ""

        for (var x = 0; x < railcamModel.trainList.count; x++)
        {
            headCode = railcamModel.trainList.get(x).headcode;
            areaCode = railcamModel.trainList.get(x).buid.substring(0,2);

            if (headCode === "" || areaCode === "")
                continue;

            var actualURL = url.replace("{HEADCODE}", headCode).replace("{AREACODE}", areaCode);

             browserURLList.append({"title": "Train Times for " + headCode, "url": actualURL, "width" : 515, "zoom": 0.75});
        }

        // add YouTube chat
        url = getLink("youtube_chat");
        if (url !== undefined)
            browserURLList.append({"title": "YouTube Chat", "url": url, "width" : 350, "zoom": 1.0});

        // add RailCam chat
        url = getLink("railcam_chat");
        if (url !== undefined)
            browserURLList.append({"title": "RailCam Chat", "url": url, "width" : 400, "zoom": 1.0});

        // add website
        for (var y = 0; y < 10; y++)
        {
            url = getLink("website" + y);
            if (url !== undefined)
            {
                var list = url.split("|");
                if (list.length === 4)
                {
                    var title = list[0];
                    var width = parseInt(list[1]);
                    var zoom = parseFloat(list[2]);
                    var actualurl = list[3];
                    browserURLList.append({"title": title, "url": actualurl, "width" : width, "zoom": zoom});
                }
                else
                    browserURLList.append({"title": "Website", "url": url, "width" : 500, "zoom": 0.8});
            }
        }

        // if a RailCam feed add 'On The Camera Today/Tomorrow' webpages
        if (player === "RailCam")
        {
            browserURLList.append({"title": "RailCam - On the cameras today", "url": "http://news.railcam.uk/index.php/category/today/", "width" : 500, "zoom": 1.0});
            browserURLList.append({"title": "RailCam - On the cameras tomorrow", "url": "http://news.railcam.uk/index.php/category/tomorrow/", "width" : 500, "zoom": 1.0});
        }

        // if the feed is LiveTV see if we can find any info for the current program
        if (feedSource.feedName === "Live TV" && guideModel.count > 0)
        {
            var searchTitle = guideModel.get(0).Title;
            browserURLList.append({"title": "IMDb", "url": "https://www.imdb.com/find?q=" + searchTitle, "width" : 500, "zoom": 1.0});
            browserURLList.append({"title": "Rotten Tomatoes", "url": "https://www.rottentomatoes.com/search?search=" + searchTitle, "width" : 500, "zoom": 1.0});
        }

        // TODO add other web urls here
    }

    // update radio feeds
    function getRadioFeed(o)
    {
        if (radioFeedList.count === 0)
            return false;

        o.title = radioFeedList.get(radioFeedList.currentIndex).title;
        o.url = radioFeedList.get(radioFeedList.currentIndex).url;

        return true;
    }

    function getRadioFeedList()
    {
        return radioFeedList;
    }

    function updateRadioFeedList()
    {
        radioFeedList.clear();

        // add radio feed
        for (var y = 0; y < 10; y++)
        {
            var link = getLink("radio_feed" + y);
            if (link !== undefined)
            {
                var list = link.split("|");
                if (list.length >= 2)
                {
                    var title = list[0];
                    var url = list[1];
                    var logo = mythUtils.findThemeFile("images/radio.png");

                    if (list.length === 3)
                        logo = list[2];

                    radioFeedList.append({"title": title, "url": url, "logo": logo});
                }
            }
        }
    }

    function updateRailCamMiniDiagram(url)
    {
        railcamMiniDiagram.source = "";
        railcamMiniDiagram.source = url;
    }

    function updateRailcamApproach()
    {
        if (infoPanel.visible || player !== "RailCam")
        {
            railcamApproaching.visible = false;
            railcamMiniDiagram.visible = false;
        }
        else
        {
            railcamApproaching.hasData = (getLink("railcam_approach") !== undefined);
            railcamMiniDiagram.hasDiagram = (getLink("railcam_minidiagram") !== undefined);

            railcamApproaching.visible = showRailcamApproach;
            railcamMiniDiagram.visible = showRailcamDiagram;
        }
    }

    function nextURL()
    {
        browserURLList.currentIndex++

        if (browserURLList.currentIndex >= browserURLList.count)
            browserURLList.currentIndex = 0;
    }

    function previousURL()
    {
        browserURLList.currentIndex--;

        if (browserURLList.currentIndex < 0)
            browserURLList.currentIndex = browserURLList.count - 1;
    }

    function updateOSD()
    {
        // update title
        if (!feedSource.feedList.get(feedSource.currentFeed))
            title.text = "";
        else if (feedSource.feedList.get(feedSource.currentFeed).title !== undefined)
            title.text =  feedSource.feedList.get(feedSource.currentFeed).title
        else if (feedSource.feedList.get(feedSource.currentFeed).url !== undefined)
            title.text = feedSource.feedList.get(feedSource.currentFeed).url
        else
            title.text = ""

        // update icon
        if (!feedSource.feedList.get(feedSource.currentFeed))
            icon.source = mythUtils.findThemeFile("images/grid_noimage.png");
        else
            icon.source = getIconURL(feedSource.feedList.get(feedSource.currentFeed).icon);

        if (feedSource.feedName === "Live TV")
            getNowNext();
    }

    function getIconURL(iconURL)
    {
        if (iconURL && iconURL !== "")
        {
            if (iconURL.startsWith("file://") || iconURL.startsWith("http://") || iconURL.startsWith("https://"))
                return iconURL;
            else
            {
                // try to get the icon from the same URL the webcam list was loaded from
                var url = playerSources.webcamList.webcamList.get(feedSource.webcamListIndex).url
                var r = /[^\/]*$/;
                url = url.replace(r, '');
                return url + iconURL;
            }
        }

        return ""
    }

    // delayed callback function
    function playStream()
    {
        switchURL(settings.configPath + "stream.ts")
    }

    function sendTab()
    {
        mythUtils.sendKeyEvent(window, Qt.Key_Tab);
    }

    function sendReturn()
    {
        mythUtils.sendKeyEvent(window, Qt.Key_Return);
    }

    function getNowNext()
    {
        // get now/next program
        var now = new Date();
        var now2 = new Date(Date.now() + (now.getTimezoneOffset() * 60 * 1000));

        // work around a MythTV services API bug
        if (now2.getSeconds() === 0)
            now2.setSeconds(1);

        guideModel.startTime = Qt.formatDateTime(now2, "yyyy-MM-ddThh:mm:ss");

        now2.setDate(now2.getDate() + 1);
        guideModel.endTime = Qt.formatDateTime(now2, "yyyy-MM-ddThh:mm:ss");
        if (feedSource.feedList.get(feedSource.currentFeed))
            guideModel.chanId =  feedSource.feedList.get(feedSource.currentFeed).ChanId != undefined ? feedSource.feedList.get(feedSource.currentFeed).ChanId : -1;
        guideModel.load();
    }

    function updateNowNext()
    {
        if (guideModel.count > 0)
        {
            // update the timeIndictor
            var dtStart = Date.parse(guideModel.get(0).StartTime);
            var dtEnd = Date.parse(guideModel.get(0).EndTime);
            var dtNow = Date.now();

            var position = dtNow - dtStart;
            var length = dtEnd - dtStart;

            timeIndictor.position = position;
            timeIndictor.length = length;

            var startDate = new Date(dtStart);
            var endDate = new Date(dtEnd);

            programTitle.info = guideModel.get(0).Title + " (" + startDate.toLocaleTimeString(Qt.locale(), "hh:mm") + " - " + endDate.toLocaleTimeString(Qt.locale(), "hh:mm") + ")";

            programLength.text = length / 60000 + " mins";

            if (guideModel.get(0).SubTitle !== "")
               programDesc.text = "\"" + guideModel.get(0).SubTitle + "\"  " + guideModel.get(0).Description
            else
               programDesc.text = guideModel.get(0).Description

            var state = guideModel.get(0).RecordingStatus;
            if (state === "Unknown")
                programStatus.text = "Not Recording";
            else
                programStatus.text = guideModel.get(0).RecordingStatus

            programCategory.text = guideModel.get(0).Category

            var season = guideModel.get(0).Season
            var episode = guideModel.get(0).Episode
            var total = guideModel.get(0).TotalEpisodes
            var res = ""

            if (season > 0)
                res = "Season: " + season + " ";
            if (episode > 0)
            {
                res += " Episode: " + episode;

                if (total > 0)
                    res += "/" + total;
            }

            programEpisode.text = res;

            if (guideModel.get(0).AirDate !== undefined)
                programFirstAired.text = "First Aired: " + Qt.formatDateTime(guideModel.get(0).AirDate, "dd/MM/yyyy");
            else
                programFirstAired.text = ""

            // update next program
            startDate = new Date(Date.parse(guideModel.get(1).StartTime));
            endDate = new Date(Date.parse(guideModel.get(1).EndTime));
            programNext.info = guideModel.get(1).Title + " (" + startDate.toLocaleTimeString(Qt.locale(), "hh:mm") + " - " + endDate.toLocaleTimeString(Qt.locale(), "hh:mm") + ")";
        }
        else
        {
            programTitle.info = "No guide data available for this channel"
            programDesc.text = "N/A"
            programStatus.text = "N/A";
            programCategory.text = "Unknown"
            programEpisode.text = "";
            programFirstAired.text = ""
            programLength.text = ""
            programNext.info = ""

            timeIndictor.position = 0;
            timeIndictor.length = 100;

        }
    }

    function updateTimeIndicator()
    {
        if (guideModel.count > 0)
        {
            var dtStart = Date.parse(guideModel.get(0).StartTime);
            var dtEnd = Date.parse(guideModel.get(0).EndTime);
            var dtNow = Date.now();

            var position = dtNow - dtStart;
            var length = dtEnd - dtStart;

            timeIndictor.position = position;
            timeIndictor.length = length;
        }
    }

    function createWebPlayer()
    {
        var player = createPlayer(playerRect, mythUtils.findThemeFile("Base/VideoPlayerWeb.qml"),
                                  {
                                      "id": "webPlayer",
                                      "anchors.fill" : playerRect,
                                      "anchors.margins" : playerBorder.border.width,
                                      "audioMuted" : false,
                                      "profile" : youtubeWebProfile
                                  });

        if (player === undefined)
        {
            log.error(Verbose.GUI, "createWebPlayer: failed to create Web player");
        }

        return player;
    }

    function createYoutubePlayer()
    {
        var player = createPlayer(playerRect, mythUtils.findThemeFile("Base/VideoPlayerYT.qml"),
                                  {
                                    "id" : "youtubePlayer",
                                    "anchors.fill" : playerRect,
                                    "anchors.margins" : playerBorder.border.width
                                  });

        if (player === undefined)
        {
            log.error(Verbose.GUI, "createQmlVLCPlayer: failed to create Youtube player");
        }

        player.showMessage.connect(root.showMessage);
        player.mediaStatusChanged.connect(root.mediaStatusChanged);
        player.playbackStatusChanged.connect(root.playbackStatusChanged);

        return player;
    }

    function createVLCPlayer()
    {
        var player = createPlayer(playerRect, mythUtils.findThemeFile("Base/VideoPlayerQmlVLC.qml"),
                                  {
                                    "id" : "vlcPlayer",
                                    "anchors.fill" : playerRect,
                                    "anchors.margins" : playerBorder.border.width
                                  });

        if (player === undefined)
        {
            log.error(Verbose.GUI, "createQmlVLCPlayer: failed to create QmlVLC player");
        }

        player.showMessage.connect(root.showMessage);
        player.mediaStatusChanged.connect(root.mediaStatusChanged);
        player.playbackStatusChanged.connect(root.playbackStatusChanged);

        return player;
    }

    function createQtAVPlayer()
    {
        var player = createPlayer(playerRect, mythUtils.findThemeFile("Base/VideoPlayerQtAV.qml"),
                                  {
                                    "id" : "qtAVPlayer",
                                    "anchors.fill" : playerRect,
                                    "anchors.margins" : playerBorder.border.width,
                                    "fillMode": VideoOutput.PreserveAspectFit
                                  });

        if (player === undefined)
        {
            log.error(Verbose.GUI, "createQtAVPlayer: failed to create QtAV player");
        }

        player.showMessage.connect(root.showMessage);
        player.mediaStatusChanged.connect(root.mediaStatusChanged);
        player.playbackStatusChanged.connect(root.playbackStatusChanged);

        return player;
    }

    function createMDKPlayer()
    {
        var player = createPlayer(playerRect, mythUtils.findThemeFile("Base/VideoPlayerMDK.qml"),
                                  {
                                    "id" : "mdkPlayer",
                                    "anchors.fill" : playerRect,
                                    "anchors.margins" : playerBorder.border.width
                                  });

        if (player === undefined)
        {
            log.error(Verbose.GUI, "createMDKPlayer: failed to create Tivo player");
        }

        player.showMessage.connect(root.showMessage);
        player.mediaStatusChanged.connect(root.mediaStatusChanged);
        player.playbackStatusChanged.connect(root.playbackStatusChanged);

        return player;
    }

    function createTivoPlayer()
    {
        var player = createPlayer(playerRect, mythUtils.findThemeFile("Base/VideoPlayerTivo.qml"),
                                  {
                                    "id" : "tivoPlayer",
                                    "anchors.fill" : root,
                                    "anchors.margins" : playerBorder.border.width
                                  });

        if (player === undefined)
        {
            log.error(Verbose.GUI, "createTivoPlayer: failed to create Tivo player");
        }

        player.showMessage.connect(root.showMessage);
        player.mediaStatusChanged.connect(root.mediaStatusChanged);
        player.playbackStatusChanged.connect(root.playbackStatusChanged);

        return player;
    }

    function createPlayer(parent, source, properties)
    {
        var muted = false;
        var volume = dbUtils.getSetting("Video" + objectName.replace(" ", "") + "Volume", settings.hostName, "100");

        // sanity check the volume
        if (volume < 0 || volume > 100)
            volume = 100;

        if (videoPlayer !== undefined)
        {
            muted = videoPlayer.getMute();
            volume = videoPlayer.getVolume();

            videoPlayer.destroy();
            videoPlayer = undefined;
        }

        var component = Qt.createComponent(source);

        if (component.status === Component.Error)
        {
            log.error(Verbose.GUI, "createPlayer: componant creation failed with error: " + component.errorString());
            return undefined;
        }

        if (component.status === Component.Ready)
        {
            var object = component.createObject(parent, properties);
            videoPlayer = object;

            videoPlayer.setMute(muted);
            videoPlayer.setVolume(volume);

            return object;
        }
        else
        {
            log.error(Verbose.GUI, "createThemedMenu: component not ready");
        }

        return undefined;
    }
}
