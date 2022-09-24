import QtQuick 2.0
import QtWebEngine 1.3

Item
{
    id: root

    property alias url: webPlayer.url
    property alias profile: webPlayer.profile

    // private properties
    property int _volume: 100

    anchors.fill: parent

    WebEngineView
    {
        id: webPlayer
        anchors.fill: parent
//        anchors.margins: playerBorder.border.width
        settings.pluginsEnabled: true
        settings.javascriptEnabled: true
        settings.javascriptCanOpenWindows: true
        audioMuted: false;

        Component.onCompleted: settings.playbackRequiresUserGesture = false;

        onNewViewRequested:
        {
            var website = request.requestedUrl.toString();
            var zoom = zoomFactor;
            if (isPanel)
                panelStack.push({item: mythUtils.findThemeFile("Screens/WebBrowser.qml"), properties:{url: website, zoomFactor: zoom}});
            else
                stack.push({item: mythUtils.findThemeFile("Screens/WebBrowser.qml"), properties:{url: website, zoomFactor: zoom}});
        }
        onFullScreenRequested: request.accept();
        onNavigationRequested: request.action = WebEngineNavigationRequest.AcceptRequest;
//        profile: youtubeWebProfile

        onLoadingChanged:
        {
            if (loadRequest.status === WebEngineLoadRequest.LoadSucceededStatus)
            {
                var feedurl = loadRequest.url.toString();

                if (feedurl !== "")
                {
                    // hack to defeat Chrome's Web Audio autoplay policy
                    if (feedurl.includes("railcam.co.uk"))
                    {
                        runJavaScript("document.getElementsByClassName(\"drawer-icon media-control-icon\")[0].click();");
                    }
                    else if (feedurl.includes("www.youtube.com/tv#/watch/video/control"))
                    {
                        // hack to make sure non embeddable Youtube videos start playing automatically in the TV player
                        tabDelay.delay(1750, sendTab);
                        returnDelay.delay(1900, sendReturn);
                    }
                }
            }
        }
    }

    // most of these are NOOP for now
    function play()
    {
    }

    function stop()
    {
        webPlayer.url = "about:blank";
    }

    function togglePause()
    {
    }

    function getPosition()
    {
        return 0;
    }

    function getDuration()
    {
        return 0;
    }

    function getMute()
    {
        return webPlayer.audioMuted;
    }

    function toggleMute()
    {
        webPlayer.audioMuted = !webPlayer.audioMuted;
        webPlayer.triggerWebAction(WebEngineView.ToggleMediaMute);
    }

    function setMute(mute)
    {
        webPlayer.audioMuted = mute;
        webPlayer.triggerWebAction(WebEngineView.ToggleMediaMute);
    }

    function changeVolume(amount)
    {
        root._volume = amount;
    }

    function getVolume()
    {
        return root._volume;
    }

    function setVolume(volume)
    {
        console.log("VideoWebPlayer setVolumn: " + volume);
        root._volume = volume;
    }

}
