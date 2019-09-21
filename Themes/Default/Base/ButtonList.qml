import QtQuick 2.0

ListView
{
    id: root
    x: xscale(100); y: yscale(100); width: xscale(1000); height: yscale(500)

    focus: false
    clip: true
    model: {}
    delegate: {}
    highlight: ListHighlight {}

    signal itemClicked(int index);
    signal itemSelected(int index);

    // for TreeButtonList
    property int nodeID: 0
    signal nodeClicked(int nodeID, int index);
    signal nodeSelected(int nodeID, int index);

    Keys.onPressed:
    {
        var rowCount = currentItem ? height / currentItem.height : 0;

        if (event.key === Qt.Key_PageDown)
        {
            currentIndex = currentIndex + rowCount >= count ? count - 1 : currentIndex + rowCount;
            event.accepted = true;
        }
        else if (event.key === Qt.Key_PageUp)
        {
            currentIndex = currentIndex - rowCount < 0 ? 0 : currentIndex - rowCount;
            event.accepted = true;
        }
    }

    Keys.onReturnPressed:
    {
        returnSound.play();
        itemClicked(currentIndex);
        nodeClicked(nodeID, currentIndex);
    }

    onCurrentItemChanged: { itemSelected(currentIndex); nodeSelected(nodeID, currentIndex); }
}
