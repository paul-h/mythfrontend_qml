import QtQuick 2.0
import Qt.labs.folderlistmodel 2.1
import Base 1.0

BaseScreen
{
    defaultFocusItem: image
    property FolderListModel folderModel
    property alias source: image.source
    property int currentIndex

    Component.onCompleted:
    {
        showTitle(false, "");
        showTime(false);
        showTicker(false);
        updatePosition();
    }

    Keys.onPressed:
    {
        if (event.key === Qt.Key_F1)
        {
            // red - previous image
            prevImage();
            event.accepted = true;
        }
        else if (event.key === Qt.Key_F2)
        {
            // green - next image
            nextImage();
            event.accepted = true;
        }
    }

    Image
    {
        id: image
        anchors.fill: parent
        source: folderModel.get(currentIndex, "filePath");
        asynchronous: true
        Keys.onLeftPressed:
        {
            prevImage();
        }
        Keys.onRightPressed:
        {
            nextImage();
        }
    }

    Item
    {
        id: positionPanel
        x: parent.width - xscale(220)
        y: yscale(20)
        width: xscale(200)
        height: yscale(50)

        Rectangle
        {
            anchors.fill: parent
            color: "black"
            opacity: 0.4
        }

        InfoText
        {
            id: positionText
            anchors.fill: parent
            horizontalAlignment: Text.AlignHCenter
        }
    }

    function prevImage()
    {
        if (currentIndex > 0)
        {
            currentIndex -= 1;
            source = folderModel.get(currentIndex, "filePath");
            downSound.play();
            updatePosition();
        }
        else
        {
            errorSound.play();
        }
    }

    function nextImage()
    {
        if (currentIndex < folderModel.count - 1)
        {
            currentIndex += 1;
            source = folderModel.get(currentIndex, "filePath");
            upSound.play();
            updatePosition();
        }
        else
        {
            errorSound.play();
        }
    }

    function updatePosition()
    {
        positionText.text = (currentIndex + 1) + " of " + folderModel.count;
    }

}


