import QtQuick 2.0
import Base 1.0

FocusScope
{
    id: objRoot

    property int columns: 1
    property int spacing: 5

    property var model: treeModel

    property var lists: [];

    // private properties
    property int _focusedList: 0
    property int _leftList: 0

    signal nodeClicked(var node)
    signal nodeSelected(var node)

    Component.onCompleted:
    {
        lists.push(createList(0, model));
        lists[0].focus = true;
        _focusedList = 0;
        nodeSelectedHandler(0, 0);
    }

    onWidthChanged:
    {
        var listWidth = (width - (columns - 1) * spacing) / columns
        var x = 0;

        for (var i = 0; i < lists.length; i++)
        {
            var list = lists[i];
            list.x = x;
            list.width = listWidth;
            x = x + listWidth + spacing;
        }
    }

    onHeightChanged:
    {
        for (var i = 0; i < lists.length; i++)
        {
            var list = lists[i];
            list.height = height
        }
    }

    x: xscale(50)
    y: yscale(50)
    width: xscale(600)
    height: yscale(600)

    ListModel
    {
        id: treeModel
    }

    Keys.onPressed:
    {
        if (event.key === Qt.Key_Left)
            moveLeft();
        else if (event.key === Qt.Key_Right)
            moveRight();
    }

    Component
    {
        id: listItem
        ListItem
        {
            ListText
            {
                x: xscale(20); y: 0
                width: parent.width - xscale(60)
                text: model.itemTitle
            }

            Image
            {
                id: channelImage
                x: parent.width - xscale(30)
                y: (parent.height - yscale(20)) / 2
                width: xscale(20); height: yscale(20)
                source:
                {
                    if (model.subNodes && model.subNodes.count)
                        mythUtils.findThemeFile("images/arrow.png")
                    else
                        ""
                }
            }
        }
    }

    function nodeClickedHandler(nodeID, index)
    {
        objRoot.nodeClicked(lists[nodeID].model.get(index));
    }

    function nodeSelectedHandler(nodeID, index)
    {
        var i;

        if (lists[nodeID].model === null || lists[nodeID].model === undefined ||  lists[nodeID].model.get(index) === undefined)
            return;

        if (nodeID == _focusedList)
            objRoot.nodeSelected(lists[nodeID].model.get(index));

        if (nodeID == _focusedList && lists[nodeID].model.get(index).subNodes.count && nodeID >= lists.length - 1)
        {
            // we need to add a new list for this node
            lists[nodeID + 1] = createList(nodeID + 1, lists[nodeID].model.get(index).subNodes);
            makeListVisible();
            return;
        }

        if (nodeID < lists.length - 1)
        {
            if (lists[nodeID].model.get(index).subNodes.count)
            {
                lists[nodeID + 1].model = lists[nodeID].model.get(index).subNodes;
            }
            else
            {
                for (i = nodeID + 1; i < lists.length; i++)
                    lists[i].model = undefined;
            }
        }
    }

    function createList(index, model)
    {
        var listWidth = (width - (columns - 1) * spacing) / columns
        var component = Qt.createComponent("ButtonList.qml");
        var list = component.createObject(objRoot, {"id": "list" + index,
                                                "nodeID": index,
                                                "x": (listWidth * index) + (spacing * index),
                                                "y": 0,
                                                "width": listWidth,
                                                "height": height,
                                                "spacing": 3,
                                                "model": model,
                                                "delegate":  listItem});

        if (list == null)
        {
            // Error Handling
            console.log("Error creating object");
        }
        else
        {
            list.nodeClicked.connect(nodeClickedHandler);
            list.nodeSelected.connect(nodeSelectedHandler);
        }

        return list;
    }

    function addNode(path, title, data)
    {
        if (path === "")
        {
            objRoot.model.append({"itemTitle": title, "itemData": data, "subNodes": []})
        }
        else
        {
            var szSplit = path.split(',')

            if (objRoot.model.get(parseInt(szSplit[0])) === undefined)
            {
                console.log("Error - Given node does not exist !")
                return false
            }

            var node = treeModel.get(parseInt(szSplit[0]))

            for (var i = 1; i < szSplit.length; ++i)
            {
                if (node.subNodes.get(parseInt(szSplit[i])) === undefined)
                {
                    console.log("Error - Given node does not exist !")
                    return false
                }
                node = node.subNodes.get(parseInt(szSplit[i]))
            }

            if (node.subNodes == undefined)
                node.subNodes = [];

            node.subNodes.append({"itemTitle": title, "itemData": data, "subNodes": []})
        }
    }

    //FIXME: 
    function setFocusedNode(path)
    {
        for (var i = 0; i < lists.length; i++)
        {
            lists[i].focus = false;
            lists[i].currentIndex = 0;
        }

        lists[0].focus = true;
        _focusedList = 0;
        _leftList = 0;
        makeListVisible()
        nodeSelectedHandler(0, 0);

        /*
        var szSplit = path.split(',')
        var node = treeModel.get(parseInt(szSplit[0]))

        if (node === undefined)
        {
            console.log("Error - Given node does not exist !")
            return
        }

        for (var i = 1; i < szSplit.length; ++i)
        {
            if (node.subNode.get(parseInt(szSplit[i])) === undefined)
            {
                console.log("Error - Given node does not exist !")
                return
            }
            node = node.subNode.get(parseInt(szSplit[i]))
        }
        */
    }

    function reset()
    {
        model.clear();

        for (var x = 0; x < lists.length; x++)
            lists[x].destroy();

        lists.length = 0;
        lists.push(createList(0, model));
        lists[0].focus = true;
        _focusedList = 0;
        nodeSelectedHandler(0, 0);
    }

    function getActiveNodePath()
    {
        var result;

        if (lists.length == 0 ||  lists[0].model.get(lists[0].currentIndex) === undefined)
            return "";

        for (var i = 0; i <= _focusedList; i++)
        {
            if (i > 0)
                result = result + " ~ " + lists[i].model.get(lists[i].currentIndex).itemTitle;
            else
                result = lists[i].model.get(lists[i].currentIndex).itemTitle
        }

        return result;
    }

    function moveLeft()
    {
        if (_focusedList > 0)
        {
            --_focusedList;
            lists[_focusedList].focus = true
        }

        // make sure the list is visible
        if (_focusedList < _leftList)
        {
            _leftList = _focusedList;
            makeListVisible()
        }

        objRoot.nodeSelected(lists[_focusedList].model.get(lists[_focusedList].currentIndex));
    }

    function moveRight()
    {
        if (lists[_focusedList].model.get(lists[_focusedList].currentIndex).subNodes &&
            lists[_focusedList].model.get(lists[_focusedList].currentIndex).subNodes.count > 0)
        {
            ++_focusedList;
            lists[_focusedList].focus = true

            // create the subnode list if necessary
            if (_focusedList >= lists.length - 1)
            {
                // we need to add a new list for this node
                lists[_focusedList + 1] = createList(_focusedList + 1, lists[_focusedList].model.get(lists[_focusedList].currentIndex).subNodes);
            }
        }

        // make sure the list is visible
        if (_focusedList >=  _leftList + columns)
        {
            _leftList = _focusedList - columns + 1;
        }

        makeListVisible()

        objRoot.nodeSelected(lists[_focusedList].model.get(lists[_focusedList].currentIndex));
    }

    function makeListVisible()
    {
        var i;
        var x = 0;

        // make any lists to the left invisible
        for (i = 0; i < _leftList; i++)
        {
            if (lists[i])
                lists[i].visible = false;
        }

        // move any visible list into view
        for (i = _leftList; i < _leftList + columns; i++)
        {
            if (lists[i])
            {
                lists[i].visible = true;
                lists[i].x = x;

                x = x + lists[i].width + spacing;
            }
        }

        // make any list to the right invisible
        for (i = _leftList + columns; i < lists.length; i++)
        {
            if (lists[i])
                lists[i].visible = false;
        }
    }
}
