import QtQuick 2.0
import QtQuick.Controls 1.4
import QtWebEngine 1.3
import Base 1.0

BaseScreen
{
    id: root
    defaultFocusItem: browser
    property alias url: browser.url
    property bool fullscreen: true

    Component.onCompleted:
    {
        showTitle(false, "");
        showTime(false);
        showTicker(false);
        pauseVideo(true);
        showVideo(false);

        showNotification("Use the RED button to exit the YouTube screen.")
    }

    Component.onDestruction:
    {
        pauseVideo(false);
    }

    Action
    {
        shortcut: "F1"
        onTriggered: if (stack.depth > 1) {stack.pop(); escapeSound.play();}
    }

    WebEngineView
    {
        id: browser
        x: 0
        y: 0
        width: parent.width
        height: parent.height
        url: "https://www.youtube.com/TV"
        settings.pluginsEnabled : true
        profile:  WebEngineProfile
                  {
                      storageName: "YouTube"
                      offTheRecord: false
                      httpCacheType: WebEngineProfile.DiskHttpCache
                      persistentCookiesPolicy: WebEngineProfile.AllowPersistentCookies
                      httpUserAgent: "Mozilla/5.0 (SMART-TV; Linux; Tizen 5.0) AppleWebKit/538.1 (KHTML, like Gecko) Version/5.0 NativeTVAds Safari/538.1"
                  }
    }
}
