import QtQuick 2.7

FocusScope
{
    id: root

    property var model: ListModel {}
    property var rowModels: []
    property int currentIndex: -1
    property int rows: 6
    property int columns: 10
    property bool showPosition: true

    signal itemClicked(int row, int col);
    signal itemSelected(int row, int col);

    x: 20
    y: 60
    width: parent.width - xscale(40)
    height: parent.height - yscale(80)

    onCurrentIndexChanged: itemSelected(pageList.currentIndex, root.currentIndex);

    Component
    {
        id: pageDelegate

        Item
        {
            id: row1
            objectName: "row1"

            property alias list: rowList

            width: parent.width
            height: pageList.height / root.rows

            LabelText
            {
                id: title1
                x: 0
                width: xscale(600)
                text: title
            }

            InfoText
            {
                id: pos
                x: parent.width - xscale(200)
                visible: root.showPosition
                width: xscale(200)
                text: (rowList.currentIndex + 1) + " of " + rowList.model.count
                fontColor: "light grey"
                horizontalAlignment: Text.AlignRight
            }

            Component
            {
                id: rowHighlight
                Rectangle
                {
                    width: ListView.view ? ListView.view.width / root.columns: row1.width / root.columns
                    height: yscale(50)
                    color: index === pageList.currentIndex ? theme.lvRowBackgroundFocusedSelected : "#00000000"
                    border.color: index === pageList.currentIndex ? theme.lvBackgroundBorderColor : "#00000000"
                    border.width: xscale(theme.lvBackgroundBorderWidth)
                    radius: xscale(theme.lvBackgroundBorderRadius)
                }
            }

            ButtonList
            {
                id: rowList
                model: rowModels[index]
                delegate: rowDelegate
                x: 0
                y: title1.height
                width: parent.width
                height: parent.height - title1.height
                orientation: ListView.Horizontal
                spacing: 5
                highlight: rowHighlight

                onCurrentIndexChanged: root.currentIndex = currentIndex
            }
        }
    }

    Component
    {
        id: rowDelegate

        Item
        {
            width: ((ListView.view ? ListView.view.width : 0) - xscale(25)) / root.columns
            height: ListView.view.height

            Rectangle
            {
                anchors.fill: parent
                color: "#30000000"
            }

            Image
            {
                x: xscale(5)
                y: yscale(5)
                width: parent.width - xscale(10)
                height: parent.height - labelText.height - yscale(5)
                source: getIconURL(icon)
                fillMode: Image.PreserveAspectFit
                horizontalAlignment: Image.AlignHCenter
                onStatusChanged: if (status == Image.Error) source = mythUtils.findThemeFile("images/no_image.png")
            }

            InfoText
            {
                id: labelText
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.bottom:  parent.bottom
                height: yscale(30)
                text: title
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignBottom
            }
        }
    }

    Item
    {
        anchors.fill: parent
        clip: true

        ListView
        {
            id: pageList
            property int pos: 0
            focus: true
            anchors.fill: parent
            model: root.model
            delegate: pageDelegate

            Keys.onRightPressed:
            {
                if (currentItem.list.currentIndex < currentItem.list.count - 1)
                    currentItem.list.currentIndex++;
            }
            Keys.onLeftPressed:
            {
                if (currentItem.list.currentIndex > 0)
                    currentItem.list.currentIndex--;
            }

            Keys.onReturnPressed:
            {
                returnSound.play();
                itemClicked(currentIndex, root.currentIndex);
            }

            onCurrentIndexChanged: itemSelected(pageList.currentIndex, root.currentIndex);
        }
    }

    function getIconURL(iconURL)
    {
        if (iconURL)
        {
            if (iconURL.startsWith("file://") || iconURL.startsWith("http://") || iconURL.startsWith("https://"))
                return iconURL;
            else
            {
                // try to get the icon from the same URL the webcam list was loaded from
                var url = playerSources.webcamList.webcamList.get(0).url
                var r = /[^\/]*$/;
                url = url.replace(r, '');
                return url + iconURL;
            }
        }

        return mythUtils.findThemeFile("images/no_image.png")
    }
}
