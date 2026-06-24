import QtQuick 2.0
import Qt.labs.folderlistmodel 2.1
import Base 1.0

BaseScreen
{
    id: root
    defaultFocusItem: image
    property FolderListModel folderModel
    property alias source: image.source
    property int currentIndex

    property bool _slideShow: false

    Component.onCompleted:
    {
        showTitle(false, "");
        showTime(false);
        showTicker(false);
        showVideo(false);
        updatePosition();

        slideShow.folder = folderModel.folder
    }

    Keys.onPressed:
    {
        event.accepted = true;

        if (event.key === Qt.Key_F1)
        {
            // red - previous image
            prevImage();
        }
        else if (event.key === Qt.Key_F2)
        {
            // green - next image
            nextImage();
        }
        else if (event.key === Qt.Key_F3 || event.key === Qt.Key_P)
        {
            // green - toggle slideshow
            _slideShow = !_slideShow;

            if (_slideShow)
                slideShow.currentIndex = currentIndex;
            else
            {
                currentIndex = slideShow.currentIndex;
                source = folderModel.get(currentIndex, "filePath");
                updatePosition();
            }
        }
        else
            event.accepted = false;
    }

    Rectangle
    {
        anchors.fill: parent
        color: "black"
    }

    Image
    {
        id: image
        anchors.fill: parent
        source: folderModel.get(currentIndex, "filePath");
        asynchronous: true
        fillMode: Image.PreserveAspectFit
        visible: !_slideShow
        Keys.onLeftPressed:
        {
            prevImage();
        }
        Keys.onRightPressed:
        {
            nextImage();
        }
    }

    SlideShow
    {
        id: slideShow
        anchors.fill: parent
        visible: _slideShow
        doShuffle: false
        doMove: false
        doZoom: false

        onImageChanged: { root.currentIndex = index; updatePosition(); }
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


