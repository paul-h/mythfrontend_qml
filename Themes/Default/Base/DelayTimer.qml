import QtQuick

Item
{
    property var callback: undefined
    property alias interval: delayTimer.interval

    Timer
    {
        id: delayTimer
        repeat: false
    }

    function delay(delayTime, cb)
    {
        if (callback !== undefined)
            delayTimer.triggered.disconnect(callback);

        delayTimer.interval = delayTime;
        delayTimer.triggered.connect(cb);
        delayTimer.start();
    }
}
