import QtQuick 2.0
import Base 1.0
import QtGraphicalEffects 1.12
import QmlVlc 0.1
import "../../../Models"
import mythqml.net 1.0

BaseDialog
{
    id: root

    property bool radioPlayerEnabled: false
    property bool themePlayerEnabled: false

    property var streamList: themeStreamList
    property var radioList: radioStreamList

    property alias volume: streamPlayer.volume
    property bool muteAudio: false

    property alias mrl: streamPlayer.mrl

    property string trackArtistTitle: ""
    property int trackStart: 0

    property bool _enabled: false
    property bool _wasPlaying: false
    property double savedPosition: 0.0

    title: "Radio Player"
    message: ""
    width: xscale(600)
    height: yscale(330)

    Component.onCompleted:
    {
        radioPlayerEnabled = (dbUtils.getSetting("RadioPlayerEnabled", settings.hostName, "true") == "true");
        themePlayerEnabled = (dbUtils.getSetting("ThemePlayerEnabled", settings.hostName, "true") == "true");
        _enabled = themePlayerEnabled;
    }

    Component.onDestruction:
    {
        streamPlayer.stop();
        dbUtils.setSetting("RadioPlayerEnabled", settings.hostName, radioPlayerEnabled);
        dbUtils.setSetting("ThemePlayerEnabled", settings.hostName, themePlayerEnabled);
    }

    onTrackArtistTitleChanged:
    {
         trackStart = streamPlayer.time;
    }

    ListModel
    {
        id: radioStreamList
        objectName: "radioStreamList"
        property int currentItem: 0
    }

    ListModel
    {
        id: themeStreamList
        objectName: "themeStreamList"
        property int currentItem: 0
    }

    ListModel
    {
        id: playedModel
    }

    VlcPlayer
    {
        id: streamPlayer

        onTimeChanged: if (trackArtistTitle != undefined && playedModel.get(0) !== undefined && trackArtistTitle === playedModel.get(0).trackArtistTitle) playedModel.get(0).length = time - trackStart;

        Component.onCompleted:
        {
            var vol = dbUtils.getSetting("RadioPlayerVolume", settings.hostName)
            if (vol !== undefined && vol !== "" && vol >= 0 && vol <= 100)
                volume = vol;
            else
                volume = 80;

            audio.mute = false;

            playlist.mode = VlcPlaylist.Loop;
        }

        Component.onDestruction:
        {

        }

        onPlayingChanged: muteTimer.start()

        onStateChanged:
        {
            if (state === VlcPlayer.NothingSpecial)
            {
                log.debug(Verbose.PLAYBACK, "streamPlayer state: Nothing Special - " + mrl);
                status.text = "Idle";
            }
            else if (state === VlcPlayer.Opening)
            {
                log.debug(Verbose.PLAYBACK, "streamPlayer state: Opening - " + mrl);
                status.text = "Opening";
            }
            else if (state === VlcPlayer.Buffering)
            {
                log.debug(Verbose.PLAYBACK, "streamPlayer state: Buffering - " + mrl);
                //status.text = "Buffering";
            }
            else if (state === VlcPlayer.Playing)
            {
                log.debug(Verbose.PLAYBACK, "streamPlayer state: Playing - " + mrl);
                muteTimer.start();
                status.text = "Playing";
                if (root.state !== "show" && streamList == radioStreamList)
                    showNotification("Playing audio stream.<br>" + streamList.get(streamList.currentItem).title);
            }
            else if (state === VlcPlayer.Paused)
            {
                log.debug(Verbose.PLAYBACK, "streamPlayer state: Paused - " + mrl);
                status.text = "Paused";
            }
            else if (state === VlcPlayer.Stopped)
            {
                log.debug(Verbose.PLAYBACK, "streamPlayer state: Stopped - " + mrl);
                status.text = "Stopped";
            }
            else if (state === VlcPlayer.Ended)
            {
                log.debug(Verbose.PLAYBACK, "streamPlayer state: Ended - " + mrl);
                status.text = "Ended";
            }
            else if (state === VlcPlayer.Error)
            {
                log.debug(Verbose.PLAYBACK, "streamPlayer state: Error - " + mrl);
                if (root.state !== "show")
                    showNotification("Failed to play audio stream.<br>" + streamList.get(streamList.currentItem).title);
                trackArtistTitle = "Error: Failed to play audio stream.";
                playlist.mode = VlcPlaylist.Normal;

            }
        }
    }

    Timer
    {
        id: muteTimer
        interval: 500; running: false; repeat: true
        onTriggered:
        {
            // keep checking the mute status until we get the result we want
            if (streamPlayer.audio.mute != -1)
            {
                if (streamPlayer.audio.mute != root.muteAudio)
                    streamPlayer.audio.mute = root.muteAudio;
                else
                    running = false;
            }
        }
    }

    Timer
    {
        interval: 1000; running: true; repeat: true
        onTriggered: if (trackArtistTitle != streamPlayer.mediaDescription.nowPlaying) trackArtistTitle = streamPlayer.mediaDescription.nowPlaying;
    }

    Keys.onPressed:
    {
        event.accepted = true;

        if (event.key === Qt.Key_F1)
        {
            // RED - previous feed
            root.previous();
        }
        else if (event.key === Qt.Key_F2)
        {
            // GREEN -- next feed
            root.next()
        }
        else if (event.key === Qt.Key_F3 || event.key === Qt.Key_P)
        {
            // YELLOW
            if (streamPlayer.state === 3) // playing
                streamPlayer.stop();
            else
            {
                if (streamPlayer.mrl != "")
                    streamPlayer.play();
            }
        }
        else if (event.key === Qt.Key_S)
        {
            // stop
            if (streamPlayer.state === 3) // playing
                streamPlayer.stop();
        }
        else if (event.key === Qt.Key_F4 || event.key === Qt.Key_F9)
        {
            //BLUE
            root.muteAudio = !root.muteAudio;
            streamPlayer.audio.mute = root.muteAudio;
        }
        else if (event.key === Qt.Key_F8)
        {
            root.state = "";
            root.cancelled();
        }
        else if (event.key === Qt.Key_BracketLeft || event.key === Qt.Key_BraceLeft)
        {
            // radio player volume down
            if (window.radioPlayerVolume > 0)
                window.radioPlayerVolume -= 1;

            dbUtils.setSetting("RadioPlayerVolume", settings.hostName, window.radioPlayerVolume);
            radioPlayerDialog.volume = window.radioPlayerVolume;
        }
        else if (event.key === Qt.Key_BracketRight || event.key === Qt.Key_BraceRight)
        {
            // radio player volume down
            if (window.radioPlayerVolume < 100)
                window.radioPlayerVolume += 1;

            dbUtils.setSetting("RadioPlayerVolume", settings.hostName, window.radioPlayerVolume);
            radioPlayerDialog.volume = window.radioPlayerVolume;
        }
        else
            event.accepted = false;
    }

    content: Item
    {
        anchors.fill: parent

        Image
        {
            id: icon
            x: xscale(5)
            y: yscale(0)
            width: xscale(150)
            height: yscale(150)
            source: mythUtils.findThemeFile("images/radio.png");
        }

        LabelText
        {
            id: streamTitle
            text: streamList.count > 0 ? streamList.get(streamList.currentItem).title : "No Radio Streams Found"
            x: xscale(160); y: yscale(0); width: parent.width - xscale(170);
        }

        InfoText
        {
            id: nowPlaying
            text: trackArtistTitle
            x: xscale(160); y: yscale(40); width: parent.width - xscale(170); height: yscale(50);
            multiline: true
        }

        Image
        {
            id: muteIcon
            x: xscale(160); y: yscale(110)
            width: xscale(30)
            height: yscale(30)
            source: root.muteAudio ? mythUtils.findThemeFile("images/mm_volume_muted.png") : mythUtils.findThemeFile("images/mm_volume.png")
        }

        LabelText
        {
            id: volumePercent
            x: xscale(200); y: yscale(110); width: xscale(156); height: yscale(35)
            text: streamPlayer.volume + "%";
            fontColor: "gray"
        }

        InfoText
        {
            id: status
            text: "Stopped"
            x: xscale(20); y: yscale(150); width: parent.width - xscale(40)
        }

        InfoText
        {
            id: position
            x: parent.width - xscale(220); y: yscale(150); width: xscale(200)
            fontColor: "gray"
            horizontalAlignment: Text.AlignRight
            text: streamList.count ? (streamList.currentItem + 1) + " of " + streamList.count : "0 of 0"
        }

        Row
        {
            x: xscale(25)
            y: yscale(200)
            spacing: 10

            ImageButton
            {
                id: onoff
                width: xscale(50)
                height: yscale(50)
                effectEnabled: false
                focus: true
                source: _enabled ? mythUtils.findThemeFile("images/player/on.png") : mythUtils.findThemeFile("images/player/off.png")
                KeyNavigation.right: previous
                KeyNavigation.left: record
                onClicked:
                {
                    _enabled = !_enabled;

                    streamList.objectName === "themeStreamList" ? themePlayerEnabled = _enabled : radioPlayerEnabled = _enabled;

                    if (_enabled)
                        root.play();
                    else
                        root.stop();
                }
            }

            ImageButton
            {
                id: previous
                width: xscale(50)
                height: yscale(50)
                source: mythUtils.findThemeFile("images/player/previoustrack.png")
                enabled: streamList.currentItem > 0 && _enabled
                KeyNavigation.right: rewind
                KeyNavigation.left: onoff
                onClicked: root.next()
            }

            ImageButton
            {
                id: rewind
                width: xscale(50)
                height: yscale(50)
                enabled: false
                source: mythUtils.findThemeFile("images/player/rewind.png")
                KeyNavigation.right: play
                KeyNavigation.left: previous
                onClicked: root.rewind()
            }

            ImageButton
            {
                id: play
                width: xscale(50)
                height: yscale(50)
                focus: true
                enabled: _enabled
                source: mythUtils.findThemeFile("images/player/play.png")
                KeyNavigation.right: pause
                KeyNavigation.left: rewind
                onClicked: root.play()
            }

            ImageButton
            {
                id: pause
                width: xscale(50)
                height: yscale(50)
                enabled: _enabled
                source: mythUtils.findThemeFile("images/player/pause.png")
                KeyNavigation.right: stop
                KeyNavigation.left: play
                onClicked: root.pause()
            }

            ImageButton
            {
                id: stop
                width: xscale(50)
                height: yscale(50)
                enabled: isPlaying() && _enabled
                source: mythUtils.findThemeFile("images/player/stop.png")
                KeyNavigation.right: fastforward
                KeyNavigation.left: pause
                onClicked: root.stop()
            }

            ImageButton
            {
                id: fastforward
                width: xscale(50)
                height: yscale(50)
                enabled: false
                source: mythUtils.findThemeFile("images/player/fastforward.png")
                KeyNavigation.right: next
                KeyNavigation.left: stop
                onClicked: root.fastforward()
            }

            ImageButton
            {
                id: next
                width: xscale(50)
                height: yscale(50)
                enabled: streamList.currentItem < streamList.count - 1 && _enabled
                source: mythUtils.findThemeFile("images/player/nexttrack.png")
                KeyNavigation.right: record
                KeyNavigation.left: fastforward
                onClicked: root.next()
            }

            ImageButton
            {
                id: record
                width: xscale(50)
                height: yscale(50)
                enabled: false
                source: mythUtils.findThemeFile("images/player/record.png")
                KeyNavigation.right: onoff
                KeyNavigation.left: next
                onClicked: root.record()
            }
        }
    }

    buttons: [ ]

    function switchStreamList(list)
    {
        if (list === "internal")
        {
            _enabled = radioPlayerEnabled;
            streamList = radioStreamList;
        }
        else if (list === "theme")
        {
            _enabled = themePlayerEnabled;
            streamList = themeStreamList;
        }
        else
            log.error(Verbose.GENERAL, "RadioPlayerDialog: switchStreamList() got bad list - " + list);
    }

    function previous()
    {
        streamList.currentItem--;

        if (streamList.currentItem < 0)
            streamList.currentItem = streamList.count - 1;

        streamPlayer.mrl = streamList.get(streamList.currentItem).url;
        streamPlayer.play();

        trackArtistTitle = "";
        icon.source = streamList.get(streamList.currentItem).logo;

        dbUtils.setSetting(settings.themeName + "RadioStream", settings.hostName, streamList.get(streamList.currentItem).title);
    }

    function next()
    {
        streamList.currentItem++;
        if (streamList.currentItem >= streamList.count)
            streamList.currentItem = 0;

        streamPlayer.mrl = streamList.get(streamList.currentItem).url;
        streamPlayer.play();

        trackArtistTitle = "";
        icon.source = streamList.get(streamList.currentItem).logo;

        dbUtils.setSetting(settings.themeName + "RadioStream", settings.hostName, streamList.get(streamList.currentItem).title);
    }

    function rewind()
    {

    }

    function fastforward()
    {

    }

    function play()
    {
        if (streamList.count === 0)
        {
            streamPlayer.stop();
            icon.source = mythUtils.findThemeFile("images/radio.png");
            trackArtistTitle = "";

            return;
        }

        streamPlayer.mrl = streamList.get(streamList.currentItem).url;
        trackArtistTitle = "";
        icon.source = streamList.get(streamList.currentItem).logo
        streamPlayer.play();
    }

    function stop()
    {
        streamPlayer.stop();
    }

    function pause()
    {
        streamPlayer.pause();
    }

    function record()
    {

    }

    function clearStreams()
    {
        streamList.clear();
    }

    function addStream(title, url, logo)
    {
        streamList.append({"title": title, "url": url, "logo": logo});
    }

    function playFirst()
    {
        onoff.focus = true;
        streamList.currentItem = 0;
        root.play();
    }

    function playStream(title)
    {
        streamList.currentItem = 0;

        for (var x = 0; x < streamList.count; x++)
        {
            if (title === streamList.get(x).title)
            {
                streamList.currentItem = x;
                break;
            }
        }

        root.play();
    }

    function isPlaying()
    {
        return streamPlayer.state === VlcPlayer.Playing;
    }

    function suspendPlayback()
    {
        if (isPlaying())
        {
            savedPosition = streamPlayer.position;
            _wasPlaying = true;
            root.stop();
        }
        else
            _wasPlaying = false;
    }

    function resumePlayback()
    {
        root.stop();

        switchStreamList("theme");

        if (_wasPlaying)
        {
            root.play();
            streamPlayer.position = savedPosition;
        }
    }

    function getMuted()
    {
        return root.muteAudio;
    }

    function setMute(mute)
    {
        root.muteAudio = mute;

        if (mute !== streamPlayer.audio.mute)
            streamPlayer.audio.mute = mute;
    }

    function toggleMute()
    {
        root.muteAudio = !root.muteAudio;

        streamPlayer.audio.mute = root.muteAudio;
    }
}
