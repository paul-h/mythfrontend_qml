import QtQuick
import Base 1.0

BaseScreen
{
    defaultFocusItem: idleText

    property int startTime: 0

    Component.onCompleted:
    {
        showTitle(true, "Idle Screen");
        showVideo(true);
        showTime(true);
        showTicker(true);
    }

    Keys.onPressed: {idleTimer.start(); escapeSound.play(); stack.pop();}

    Timer
    {
        id: countDownTimer
        interval: 1000; running: true; repeat: true
        onTriggered:
        {
            startTime++;
            if (startTime >= 120)
            {
                if (window.shutdownOnIdle)
                    shutdown();
                else
                    quit();
            }
            else
                countdownText.text = (window.shutdownOnIdle ? "Shutting down" : "Exiting") + " in " + (120 - startTime) + " seconds"
        }
    }

    Image
    {
        id: name
        y: yscale(100)
        width: xscale(150)
        height: yscale(150)
        source: mythUtils.findThemeFile(window.shutdownOnIdle ? "images/shutdown.png" : "images/close.png")
        anchors.horizontalCenter: parent.horizontalCenter
    }

    TitleText
    {
        id: idleText
        x: 0; width: parent.width
        y: yscale(250); height: yscale(100)
        text: "Been idle for " + window.idleTime + " minutes"
        horizontalAlignment: Text.AlignHCenter
        fontPixelSize: xscale(40)
    }

    InfoText
    {
        id: countdownText
        x: 0; width: parent.width
        y: yscale(350); height: yscale(100)
        text: "Shutting down in 2 minutes"
        horizontalAlignment: Text.AlignHCenter
        fontPixelSize: xscale(25)
    }

    LabelText
    {
        id: cancelText
        x: 0; width: parent.width
        y: yscale(450); height: yscale(100)
        text: "Press any key to cancel"
        horizontalAlignment: Text.AlignHCenter
        fontPixelSize: xscale(30)
    }
}
