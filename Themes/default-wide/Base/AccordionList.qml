import QtQuick 2.0

// Accordion list
FocusScope
{
    id: root

    // Default width
    width: 360
    // Default height
    height: 640
    // Subitem expansion duration
    property int animationDuration: 1000
    // Subitem indentation
    property int indent: 20
    // Scrollbar width
    property int scrollBarWidth: 8
    // Background for list item
    property string bgImage: mythUtils.findThemeFile("images/list_item.png")
    // Background image for pressed list item
    property string bgImagePressed: mythUtils.findThemeFile("images/list_item_pressed.png")
    // Background image for active list item (currently not used)
    property string bgImageActive: mythUtils.findThemeFile("images/list_item_active.png")
    // Background image for subitem
    property string bgImageSubItem: mythUtils.findThemeFile("images/list_subitem.png")
    // Arrow indicator for item expansion
    property string arrow: mythUtils.findThemeFile("images/arrow.png")
    // Font properties for top level items
    property string headerItemFontName: "Helvetica"
    property int headerItemFontSize: 13
    property color headerItemFontColor: "magenta"
    // Font properties for  subitems
    property string subItemFontName: "Helvetica"
    property int subItemFontSize: headerItemFontSize - 3
    property color subItemFontColor: "green"

    signal itemClicked(string itemTitle, string subItemTitle)

    AccordionListModel
    {
        id: mainModel
    }

    ListView
    {
        id: listView
        anchors {fill: parent; margins: 0}
        model: mainModel
        delegate: listViewDelegate
        focus: true
        clip: true
        spacing: 3

        Keys.onReturnPressed: currentItem.expanded = !currentItem.expanded;
    }

    Component
    {
        id: listViewDelegate
        Item
        {
            id: delegate
            // Modify appearance from these properties
            property int itemHeight: 40
            property alias expandedItemCount: subItemRepeater.count

            // Flag to indicate if this delegate is expanded
            property bool expanded: false

            x: 0; y: 0;
            width: root.width
            height: headerItemRect.height + subItemsRect.height

            // Top level list item.
            AccordionListItem
            {
                id: headerItemRect
                x: 0; y: 0
                width: parent.width
                height: parent.itemHeight
                text: itemTitle
                onClicked: expanded = !expanded

                bgImage: root.bgImage
                bgImagePressed: root.bgImagePressed
                bgImageActive: root.bgImageActive
                fontName: root.headerItemFontName
                fontSize: root.headerItemFontSize
                fontColor: delegate.ListView.isCurrentItem ? "red" : "blue"
                fontBold: true

                // Arrow image indicating the state of expansion.
                Image 
                {
                    id: arrow
                    fillMode: "PreserveAspectFit"
                    height: parent.height*0.3
                    source: root.arrow
                    rotation: expanded ? 90 : 0
                    smooth: true
                    anchors
                    {
                        right: parent.right
                        verticalCenter: parent.verticalCenter
                        rightMargin: 10
                    }

                    Behavior on rotation
                    {
                        NumberAnimation { duration: 500; easing.type: Easing.InOutQuad }
                    }
                }
            }

            // Subitems are in a column whose height depends
            // on the expanded status. When not expandend, it is zero.
            Item
            {
                id: subItemsRect
                property int itemHeight: delegate.itemHeight

                y: headerItemRect.height
                width: parent.width
                height: expanded ? expandedItemCount * itemHeight : 0
                clip: true

                opacity: 1
                Behavior on height
                {
                    // Animate subitem expansion. After the final height is reached,
                    // ensure that it is visible to the user.
                    SequentialAnimation
                    {
                        NumberAnimation { duration: root.animationDuration; easing.type: Easing.InOutQuad }
                        //ScriptAction { script: ListView.view.positionViewAtIndex(index, ListView.Contain) }
                    }
                }

                Column
                {
                    width: parent.width

                    // Repeater creates each sub-ListItem using attributes
                    // from the model.
                    Repeater
                    {
                        id: subItemRepeater
                        model: attributes
                        width: subItemsRect.width

                        AccordionListItem
                        {
                            id: subListItem
                            width: delegate.width
                            height: subItemsRect.itemHeight
                            text: subItemTitle
                            bgImage: root.bgImageSubItem
                            fontName: root.subItemFontName
                            fontSize: root.subItemFontSize
                            fontColor: root.subItemFontColor
                            textIndent: root.indent
                            onClicked:
                            {
                                console.log("Clicked: " + itemTitle + "/" + subItemTitle)
                                itemClicked(itemTitle, subItemTitle)
                            }
                        }
                    }
                }
            }
        }
    }
}
