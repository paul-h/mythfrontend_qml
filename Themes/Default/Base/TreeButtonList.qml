import QtQuick 2.0
import Base 1.0
import mythqml.net 1.0
import Models 1.0

FocusScope
{
    id: objRoot

    property int columns: 1
    property int spacing: 5

    property var sourceTree: undefined
    property string basePath: ""
    property var model: treeModel

    property var lists: [];

    property int currentIndex: 0
    property int currentLevel: 0

    // private properties
    property int _focusedList: 0
    property int _leftList: 0
    property string _savedPath: ""
    property string _savedPosition: ""

    signal nodeClicked(var node)
    signal nodeSelected(var node)
    signal posChanged(int level, int index, int count)

    Component.onCompleted:
    {
        lists.push(createList(0, model));
        lists[0].focus = true;
        _focusedList = 0;
    }

    onBasePathChanged:
    {
        model = getNodeFromPath(basePath);
        reset();
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

    Connections
    {
        target: sourceTree
        ignoreUnknownSignals: true

        function onBranchUpdateStarted(path)
        {
            // TODO check we are displaying the path
            _savedPosition = saveFocus();
        }

        function onBranchUpdateEnded(path)
        {
            if (_savedPosition != "")
            {
                restoreFocus();
            }
        }
    }

    ListModel
    {
        id: treeModel
    }

    Keys.onPressed:
    {
        var handled = false;

        if (event.key === Qt.Key_Left)
            handled = moveLeft();
        else if (event.key === Qt.Key_Right)
            handled = moveRight();

         event.accepted = handled;
    }

    Component
    {
        id: listItem
        ListItem
        {
            Image
            {
                id: iconImage
                x: xscale(5)
                y: yscale(4)
                width: (source == "") ? 0 : parent.height - yscale(8)
                height: width
                source:
                {
                    if (model.icon)
                        model.icon
                    else
                        ""
                }
                asynchronous: true
                onStatusChanged: if (status == Image.Error) source = mythUtils.findThemeFile("images/no_image.png")
            }

            ListText
            {
                x: iconImage.width + xscale(10); y: 0
                width: parent.width - iconImage.width - xscale(60)
                text: model.itemTitle
            }

            Image
            {
                id: arrowImage
                x: parent.width - xscale(30)
                y: (parent.height - yscale(20)) / 2
                width: xscale(20); height: yscale(20)
                source:
                {
                    if ((model.expanded !== undefined && !model.expanded) || (model.subNodes && model.subNodes.count))
                        mythUtils.findThemeFile("images/arrow.png")
                    else
                        ""
                }
            }

            AnimatedImage
            {
                id: checkImage
                x: parent.width - width - xscale(5)
                y: (parent.height - height) / 2
                width: xscale(30); height: yscale(30)
                source:
                {
                    if (model.checked)
                        mythUtils.findThemeFile("images/check.png")
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
        currentIndex = index;
        currentLevel = nodeID;

        var node = lists[nodeID].model.get(index);
        var path = getPathFromNode(node, true);

        if (path === "" || node === undefined)
            return;

        if (sourceTree !== undefined)
        {
            if (!node.expanded)
            {
                sourceTree.model.expandNode(path, node);

                if (node.subNodes.count === 0)
                {
                    node.subNodes.append({
                                             "parent": node, "itemTitle": "<No Results>", "itemData": "NoResult", "checked": false, "expanded": true, "icon": mythUtils.findThemeFile("images/no_result.jpg"),
                                             "subNodes": [], type: SourceTreeModel.NodeType.No_Result, "player": "", "url": "", "genre": ""
                                         })
                }
            }
        }

        var i;

        if (lists[nodeID].model === null || lists[nodeID].model === undefined ||  lists[nodeID].model.get(index) === undefined)
            return;

        if (nodeID === _focusedList)
        {
            objRoot.nodeSelected(lists[nodeID].model.get(index));
            objRoot.posChanged(nodeID, index, lists[nodeID].model.count);
        }

        if (nodeID === _focusedList && lists[nodeID].model.get(index).subNodes.count && nodeID >= lists.length - 1)
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

        if (list === null)
        {
            // Error Handling
            log.debug(Verbose.GUI, "TreeButtonList: createList - Error creating object");
        }
        else
        {
            list.nodeClicked.connect(nodeClickedHandler);
            list.nodeSelected.connect(nodeSelectedHandler);
        }

        return list;
    }

    function addNode(path, title, data, checked, icon)
    {
        if (checked === undefined)
            checked = false;

        if (icon === undefined)
            icon = "";

        var sData;

        if (data === undefined)
            sData = title;
        else if (typeof data === "number")
            sData = data.toString();
        else
            sData = data;

        if (path === "")
        {
            model.append({"itemTitle": title, "itemData": sData, "checked": checked, "icon": icon, "subNodes": []})
        }
        else
        {
            var szSplit = path.split(',')

            if (model.get(parseInt(szSplit[0])) === undefined)
            {
                log.error(Verbose.GUI, "TreeButtonList: addNode - Error: Given node does not exist!")
                return false
            }

            var node = model.get(parseInt(szSplit[0]))

            for (var i = 1; i < szSplit.length; ++i)
            {
                if (node.subNodes.get(parseInt(szSplit[i])) === undefined)
                {
                    log.error(Verbose.GUI, "TreeButtonList: addNode - Error: Given node does not exist !")
                    return false
                }
                node = node.subNodes.get(parseInt(szSplit[i]))
            }

            if (node.subNodes === undefined)
                node.subNodes = [];

            node.subNodes.append({"itemTitle": title, "itemData": sData, "checked": checked, "icon": icon, "subNodes": []})
        }

        return true
    }

    //FIXME: 
    function setFocusedNode(path)
    {
        for (var x = 0; x < lists.length; x++)
            lists[x].destroy();

        lists.length = 0;
        lists.push(createList(0, model));
        lists[0].focus = true;
        _focusedList = 0;
        nodeSelectedHandler(0, 0);

        if (path === "")
        {
            nodeSelectedHandler(0, 0);
            return;
        }

        var list = path.split(" ~ ");
        var node = model;
        var found = false;

        for (var x = 0; x < list.length; x++)
        {
            found = false;

            for (var y = 0; y < node.count; y++)
            {
                if (node.get(y).itemData == list[x])
                {
                    if (node.get(y).expanded !== undefined && node.get(y).expanded === false && (typeof node.expandNode === "function"))
                        node.expandNode(getPathFromNode(node.get(y), true), node.get(y))

                    node = node.get(y).subNodes;

                    lists[_focusedList].highlightMoveDuration = 0;
                    lists[_focusedList].currentIndex = y;
                    lists[_focusedList].highlightMoveDuration = 1500;

                    moveRight();

                    found = true;

                    break;
                }
            }

            if (!found)
            {
                lists[_focusedList].highlightMoveDuration = 0;
                lists[_focusedList].currentIndex = 0;
                lists[_focusedList].highlightMoveDuration = 1500;

                break;
            }
        }
    }

    function getNodeFromPath(path)
    {
        var list = path.split(" ~ ");
        var node = sourceTree.model;
        var found = false;

        for (var x = 0; x < list.length; x++)
        {
            found = false;

            for (var y = 0; y < node.count; y++)
            {
                if (node.get(y).itemData == list[x])
                {
                    if (node.get(y).expanded === false)
                        sourceTree.model.expandNode(getPathFromNode(node.get(y), true), node.get(y))

                    if (x < list.length - 1)
                        node = node.get(y).subNodes;

                    found = true;
                    break;
                }
            }

            if (!found)
                return undefined;
        }

        return node;
    }

    function saveFocus()
    {
        var result = "";

        for (var x = lists.length - 2; x >= 0; x--)
        {
            if (result != "")
                result =  lists[x].currentIndex + "~" + result;
            else
                result = lists[x].currentIndex;
        }

        return result;
    }

    function restoreFocus()
    {
        for (var x = 0; x < lists.length; x++)
            lists[x].destroy();

        lists.length = 0;
        lists.push(createList(0, model));
        lists[0].focus = true;
        _focusedList = 0;
        nodeSelectedHandler(0, 0);

        if (_savedPosition === "")
        {
            nodeSelectedHandler(0, 0);
            return;
        }

        var list = _savedPosition.split("~");
        var node = model;

        for (var y = 0; y < list.length; y++)
        {
            var index = list[y];

            if (index >= lists[y].model.count)
                index = lists[y].model.count - 1;

            if (node.get(index).expanded !== undefined && node.get(index).expanded === false && (typeof node.expandNode === "function"))
                node.expandNode(getPathFromNode(node.get(index), true), node.get(index))

            node = node.get(index).subNodes;

            lists[y].highlightMoveDuration = 0;
            lists[y].currentIndex = index;
            lists[y].highlightMoveDuration = 1500;

            moveRight();
        }
    }

    function getPathFromNode(node, useData)
    {
        if (!node)
            return "";

        var result = "";

        while (node != null)
        {
            if (result != "")
                result = (useData ? node.itemData : node.itemTitle) + " ~ " + result;
            else
                result = useData ? node.itemData : node.itemTitle;

            node = node.parent;
        }

        return result;
    }

    function resetModel()
    {
        model.clear();
        reset();
    }

    function reset()
    {
        for (var x = 0; x < lists.length; x++)
            lists[x].destroy();

        lists.length = 0;
        lists.push(createList(0, model));
        lists[0].focus = true;
        _focusedList = 0;
        nodeSelectedHandler(0, 0);
    }

    function getActiveNode()
    {
        return lists[_focusedList].model.get(lists[_focusedList].currentIndex);
    }

    function getActiveNodePath(useData, separator)
    {
        var result;

        if (separator === undefined)
            separator = " ~ ";

        if (lists.length == 0 ||  lists[0].model.get(lists[0].currentIndex) === undefined)
            return "";

        for (var i = 0; i <= _focusedList; i++)
        {
            var nodeText = (useData ? lists[i].model.get(lists[i].currentIndex).itemData : lists[i].model.get(lists[i].currentIndex).itemTitle);
            if (i > 0)
                result = result + separator + nodeText;
            else
                result = nodeText;
        }

        return result;
    }

    function moveLeft()
    {
        var listChanged = false;

        if (_focusedList > 0)
        {
            --_focusedList;
            lists[_focusedList].focus = true
            listChanged = true;
        }

        // make sure the list is visible
        if (_focusedList < _leftList)
        {
            _leftList = _focusedList;
            makeListVisible()
        }

        objRoot.nodeSelected(lists[_focusedList].model.get(lists[_focusedList].currentIndex));
        objRoot.posChanged(_focusedList, lists[_focusedList].currentIndex, lists[_focusedList].model.count);

        return listChanged;
    }

    function moveRight()
    {
        var listChanged = false;

        if (lists[_focusedList].model.get(lists[_focusedList].currentIndex).subNodes &&
            lists[_focusedList].model.get(lists[_focusedList].currentIndex).subNodes.count > 0)
        {
            ++_focusedList;
            lists[_focusedList].focus = true

            // create the subnode list if necessary
            if (_focusedList >= lists.length - 1)
            {
                // we need to add a new list for this node
                var currentIndex = lists[_focusedList].currentIndex > 0 ? lists[_focusedList].currentIndex : 0
                lists[_focusedList + 1] = createList(_focusedList + 1, lists[_focusedList].model.get(currentIndex).subNodes);
            }

            listChanged = true;
        }

        // make sure the list is visible
        if (_focusedList >=  _leftList + columns)
        {
            _leftList = _focusedList - columns + 1;
        }

        makeListVisible()

        objRoot.nodeSelectedHandler(lists[_focusedList].nodeID, lists[_focusedList].currentIndex);
        objRoot.posChanged(_focusedList, lists[_focusedList].currentIndex, lists[_focusedList].model.count);

        return listChanged;
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

    function scrollToPos(percent)
    {
        lists[_focusedList].highlightMoveDuration = 1500;
        lists[_focusedList].currentIndex = lists[_focusedList].model.count / (100 / percent);
    }

    function search(text)
    {
        for (var x = lists[_focusedList].currentIndex + 1; x < lists[_focusedList].model.count; x++)
        {
            if (lists[_focusedList].model.get(x).itemTitle.includes(text))
            {
                lists[_focusedList].highlightMoveDuration = 1500;
                lists[_focusedList].currentIndex = x;
                break;
            }
        }

    }
}
