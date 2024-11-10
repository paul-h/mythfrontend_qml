import QtQuick 2.0
import Models 1.0
import Qt.labs.folderlistmodel 2.15
import Base 1.0

BaseScreen
{
    defaultFocusItem: imageList
    property alias folder: folderModel.folder

    Component.onCompleted:
    {
        showTitle(false);
        setHelp("https://mythqml.net/help/image_browser.php#top");
        showTime(false);
        showTicker(false);
    }

    Image
    {
        id: backgroundImage
        anchors.fill: parent
        source: ''
        fillMode: Image.PreserveAspectFit
        asynchronous: true
    }

    BaseBackground
    {
        x: xscale(15); y: yscale(50); width: parent.width - xscale(30); height: yscale(655)
    }

    TitleText
    {
        id: title
        text: folderModel.folder
        width: _xscale(1100)
        visible : true
        elide: Text.ElideLeft
    }

    InfoText
    {
        x: _xscale(1150); y: yscale(5); width: _xscale(100);
        text: (imageList.currentIndex + 1) + " of " + imageList.model.count;
        horizontalAlignment: Text.AlignRight
    }

    Component
    {
        id: listRow

        ListItem
        {
            height: yscale(62)

            Image
            {
                id: thumbnail
                x: xscale(3); y: yscale(3); height: parent.height - xscale(6); width: height
                source: fileIsDir ? mythUtils.findThemeFile("images/directory.png") : filePath
                asynchronous: true
            }
            ListText
            {
                width:imageList.width; height: parent.height
                x: thumbnail.width + xscale(5)
                text: fileName
            }
        }
    }

    ButtonList
    {
        id: imageList
        x: xscale(25); y: yscale(65); width: parent.width - xscale(50); height: yscale(620)

        clip: true

        FolderListModel
        {
            id: folderModel
            folder: settings.picturePath
            nameFilters: ["*.jpg", "*.png", "*.JPG", "*.PNG"]
        }

        FolderListModel
        {
            id: childFolderModel
            folder: folderModel.get(imageList.currentIndex, "filePath")

            nameFilters: ["*.jpg", "*.png", "*.JPG", "*.PNG"]
            showDirs: false
            onStatusChanged:
            {
                if (status == FolderListModel.Ready)
                {
                    if (childFolderModel.count)
                        backgroundImage.source = childFolderModel.get(0, "filePath");
                    else
                        backgroundImage.source = "";
                }
           }
        }

        model: folderModel
        delegate: listRow

        Keys.onReturnPressed:
        {
            if (isPanel)
            {
                if (model.get(currentIndex, "fileIsDir"))
                    panelStack.push({item: Qt.resolvedUrl("IconView.qml"), properties:{folder: model.get(currentIndex, "filePath")}});
                else
                    panelStack.push({item: Qt.resolvedUrl("ImageView.qml"), properties:{folder: model.get(currentIndex, "filePath"), currentIndex: currentIndex, folderModel: model}});
            }
            else
            {
                if (model.get(currentIndex, "fileIsDir"))
                    stack.push({item: Qt.resolvedUrl("IconView.qml"), properties:{folder: model.get(currentIndex, "filePath")}});
                else
                    stack.push({item: Qt.resolvedUrl("ImageView.qml"), properties:{folder: model.get(currentIndex, "filePath"), currentIndex: currentIndex, folderModel: model}});
            }

            event.accepted = true;
            returnSound.play();
        }
    }
}
