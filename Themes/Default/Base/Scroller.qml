import QtQuick 2.5

Item
{
    id: root
    property alias model: itemsModel
    property int currentItem: -1

    anchors.bottom: parent.bottom
    clip: true

    ListModel
    {
        id: itemsModel
        onCountChanged:
        {
            if (currentItem >= count)
                currentItem = count;

            if (count > 0)
                animation.start();
        }
    }

    Rectangle
    {
        id: background
        color: theme.tiBackgroundColor
        anchors.fill: parent
    }

    Text
    {
        id: text2
        color: theme.tiTextColor
        font.pixelSize: xscale(25)
        width: parent.width - xscale(10)
        height: parent.height
        x: xscale(10);
        anchors.verticalCenter: parent.verticalCenter
        clip: false

        Component.onCompleted:
        {
            if (itemsModel && itemsModel.count)
            {
                text = itemsModel.get(root.currentItem).text
                animation.start()
            }
            else
                text = ""
        }

        SequentialAnimation
        {
            id: animation
            running: false

            OpacityAnimator
            {
                id: fadeinAnimation
                target: text2;
                from: 0
                to: 1
                duration: 2000
                loops: 1
                onFromChanged: restart()
            }

            NumberAnimation
            {
                id: scrollAnimation
                target: text2;
                property: "x"
                from: 0
                to: if (text2.contentWidth - text2.width > 0) - (text2.contentWidth - text2.width); else 0
                duration: if (text2.contentWidth - text2.width > 0) (text2.contentWidth - text2.width) * (10 * (1 / wmult)); else 5000
                loops: 1
                onFromChanged: restart()
            }

            OpacityAnimator
            {
                id: fadeoutAnimation
                target: text2;
                from: 1
                to: 0
                duration: 2000
                loops: 1
                onFromChanged: restart()
            }

            onStopped:
            {
                text2.x = 0;
                root.currentItem = root.currentItem + 1;
                if (root.currentItem >= itemsModel.count)
                    root.currentItem = 0;
                text2.text = itemsModel.get(root.currentItem).text
                pauseTimer.start();
            }
        }
    }

    Timer
    {
        id:pauseTimer
        interval: 3000; running: false; repeat: false
        onTriggered: animation.start();
    }
}
