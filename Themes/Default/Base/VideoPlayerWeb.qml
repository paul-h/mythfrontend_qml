import QtQuick
import QtWebEngine

Item
{
    id: root

    property alias url: webPlayer.url
    property alias profile: webPlayer.profile

    // private properties
    property int _volume: 100

    WebEngineView
    {
        id: webPlayer
        anchors.fill: parent
        settings.pluginsEnabled: true
        settings.javascriptEnabled: true
        settings.javascriptCanOpenWindows: true
        audioMuted: false;

        Component.onCompleted: settings.playbackRequiresUserGesture = false;

        onNewWindowRequested: request =>
        {
            var website = request.requestedUrl.toString();
            var zoom = zoomFactor;
            if (isPanel)
                panelStack.push({item: mythUtils.findThemeFile("Screens/WebBrowser.qml"), properties:{url: website, zoomFactor: zoom}});
            else
                stack.push({item: mythUtils.findThemeFile("Screens/WebBrowser.qml"), properties:{url: website, zoomFactor: zoom}});
        }
        onFullScreenRequested: request => request.accept();
        onNavigationRequested: request => request.action = WebEngineNavigationRequest.AcceptRequest;

        onLoadingChanged: loadingInfo =>
        {
            if (loadingInfo.status === WebEngineView.LoadSucceededStatus)
            {
                var feedurl = loadingInfo.url.toString();

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

    function skipBack(time)
    {
    }

    function skipForward(time)
    {
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
    }

    function setMute(mute)
    {
        webPlayer.audioMuted = mute;
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
        root._volume = volume;
    }

}
