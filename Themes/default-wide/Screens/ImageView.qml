import QtQuick 2.0
import "../../../Models"
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
    }

    Image
    {
        id: image
        anchors.fill: parent
        source: folderModel.get(currentIndex, "filePath");
        asynchronous: true
        Keys.onLeftPressed:
        {
            if (currentIndex > 0)
            {
                currentIndex -= 1;
                source = folderModel.get(currentIndex, "filePath");
            }
        }
        Keys.onRightPressed:
        {
            if (currentIndex < folderModel.count - 1)
            {
                currentIndex += 1;
                source = folderModel.get(currentIndex, "filePath");
            }
        }
    }
}


