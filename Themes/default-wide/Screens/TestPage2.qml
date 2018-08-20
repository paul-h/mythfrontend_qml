import QtQuick 2.0
import QtQuick.Window 2.0
import QtQuick.Layouts 1.0
import QtQuick.Controls 1.0
import Base 1.0

BaseScreen
{
    defaultFocusItem: treeView

    Component.onCompleted:
    {
        showTitle(true, "Test Page 2");
        showTime(false);
        showTicker(false);
        screenBackground.muteAudio(true);

        treeView.addNode("All");
        treeView.addNode("Title");
        treeView.addNode("Type");
        treeView.addNode("Category");
        treeView.addNode("Year");
        treeView.addNode("Rating");

        // All
        treeView.addNode("0,Title 1");
        treeView.addNode("0,Title 2");
        treeView.addNode("0,Title 3");
        treeView.addNode("0,Title 4");
        treeView.addNode("0,Title 5");
        treeView.addNode("0,Title 6");
        treeView.addNode("0,Title 7");
        treeView.addNode("0,Title 8");
        treeView.addNode("0,Title 9");
        treeView.addNode("0,Title 10");
        treeView.addNode("0,Title 11");
        treeView.addNode("0,Title 12");

        // title
        treeView.addNode("1,All");
        treeView.addNode("1,Type");
        treeView.addNode("1,Category");
        treeView.addNode("1,Year");
        treeView.addNode("1,Rating");

        // title/Type
        treeView.addNode("1,1,All");
        treeView.addNode("1,1,Television");
        treeView.addNode("1,1,Films");

        // title/Type/All
        treeView.addNode("1,1,1,Title 1");
        treeView.addNode("1,1,1,Title 2");
        treeView.addNode("1,1,1,Title 3");
        treeView.addNode("1,1,1,Title 4");
        treeView.addNode("1,1,1,Title 5");
        treeView.addNode("1,1,1,Title 6");
        treeView.addNode("1,1,1,Title 7");
        treeView.addNode("1,1,1,Title 8");
        treeView.addNode("1,1,1,Title 9");
        treeView.addNode("1,1,1,Title 10");
        treeView.addNode("1,1,1,Title 11");
        treeView.addNode("1,1,1,Title 12");
        //treeView.setFocusedNode("0");
    }
/*
    ListModel
    {
        id: treeModel

        ListElement
        {
            itemTitle: "Christmas (6)"
            subNodes:
            [
                ListElement
                {
                    itemTitle: "Subitem1 title 1/1" 
                    subNodes:
                    [
                        ListElement
                        {
                            itemTitle: "Subitem2 title 1/1" 
                            subNodes:
                            [
                                ListElement
                                {
                                    itemTitle: "Subitem3 title 1"
                                },
                                ListElement
                                {
                                    itemTitle: "Subitem3 title 2" 
                                },
                                ListElement
                                {
                                    itemTitle: "Subitem3 title 3"
                                },
                                ListElement
                                {
                                    itemTitle: "Subitem3 title 4"
                                },
                                ListElement
                                {
                                    itemTitle: "Subitem3 title 5"
                                },
                                ListElement
                                {
                                    itemTitle: "Subitem3 title 6"
                                }
                            ]
                        },
                        ListElement
                        {
                            itemTitle: "Subitem2 title 2/1" 
                        },
                        ListElement
                        {
                            itemTitle: "Subitem2 title 3/1"
                        },
                        ListElement
                        {
                            itemTitle: "Subitem2 title 4/1"
                        },
                        ListElement
                        {
                            itemTitle: "Subitem2 title 5/1"
                        },
                        ListElement
                        {
                            itemTitle: "Subitem2 title 6/1"
                        }
                    ]
                },
                ListElement
                {
                    itemTitle: "Subitem1 title 2/1" 
                },
                ListElement
                {
                    itemTitle: "Subitem1 title 3/1"
                },
                ListElement
                {
                    itemTitle: "Subitem1 title 4/1"
                },
                ListElement
                {
                    itemTitle: "Subitem1 title 5/1"
                },
                ListElement
                {
                    itemTitle: "Subitem1 title 6/1"
                }
            ]
        }
        ListElement
        {
            itemTitle: "Classic Rock (2)"
            subNodes:
            [
                ListElement { itemTitle: "Subitem title 1/2" },
                ListElement { itemTitle: "Subitem title 2/2 long text long text long text long text long text long text long text" }
            ]
        }
        ListElement
        {
            itemTitle: "Pop (3)"
            subNodes:
            [
                ListElement
                {
                    itemTitle: "Pop title 1/3"
                },
                ListElement
                { 
                    itemTitle: "Pop title 2/3" 
                                        subNodes:
                    [
                        ListElement
                        {
                            itemTitle: "Pop Subitem title 1"
                            subNodes:
                            [
                                ListElement
                                {
                                    itemTitle: "Subitem for Pop Subitem title 1"
                                }
                            ]
                        },
                        ListElement
                        {
                            itemTitle: "Pop Subitem title 2"
                        },
                        ListElement
                        {
                            itemTitle: "Pop Subitem title 3"
                        },
                        ListElement
                        {
                            itemTitle: "Pop Subitem title 4"
                        },
                        ListElement
                        {
                            itemTitle: "Pop Subitem title 5"
                        },
                        ListElement
                        {
                            itemTitle: "Pop Subitem title 6"
                        },
                        ListElement
                        {
                            itemTitle: "Pop Subitem title 7"
                        },
                        ListElement
                        {
                            itemTitle: "Pop Subitem title 8"
                        },
                        ListElement
                        {
                            itemTitle: "Pop Subitem title 9"
                        },
                        ListElement
                        {
                            itemTitle: "Pop Subitem title 10"
                        }
                    ]

                },
                ListElement { itemTitle: "Pop title 3/3" }
            ]
        }
    }
*/
    Component.onDestruction:
    {
        screenBackground.muteAudio(false);
    }

    BaseBackground
    {
        x: xscale(50)
        y: yscale(100)
        width: xscale(1180)
        height: yscale(600)
    }

    InfoText
    {
        id: breadCrumb
        x: xscale(70)
        y: yscale(60)
        width: xscale(1140)
    }

    TreeButtonList
    {
        id: treeView
        x: xscale(70)
        y: xscale(120)
        width: xscale(1140)
        height: yscale(560)
        columns: 4
        spacing: xscale(10)
        //model: treeModel

        onNodeSelected:
        {
            breadCrumb.text = getActiveNodePath();
        }
    }
}
