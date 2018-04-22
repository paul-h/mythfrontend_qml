import QtQuick 2.7
import Base 1.0
import Dialogs 1.0
import RecordingsModel 1.0
import "../../../Models"

BaseScreen
{
    id: root

    property string filterTitle
    property string filterCategory
    property string filterRecGroup
    property bool dateSorterActive: true
    property bool showFanart: false

    defaultFocusItem: recordingList

    Component.onCompleted:
    {
        showTitle(true, "Watch Recordings");
        showTime(false);
        showTicker(false);
    }

    states: State
    {
            name: "filter"
            PropertyChanges { target: listBackground; x: 300 }
            PropertyChanges { target: recordingList; x: 310; KeyNavigation.left: titleEdit; KeyNavigation.right: titleEdit; }
            PropertyChanges { target: filterBackground; x: 10; visible: true; focus: true }
            PropertyChanges { target: titleEdit; focus: true }
    }

    transitions: Transition
    {
        from: ""; to: "filter"; reversible: true
        ParallelAnimation
        {
            NumberAnimation { target: listBackground; property: "x"; duration: 500; easing.type: Easing.InOutQuad }
            NumberAnimation { target: recordingList; property: "x"; duration: 500; easing.type: Easing.InOutQuad }
            NumberAnimation { target: filterBackground; property: "x"; duration: 500; easing.type: Easing.InOutQuad }
        }
    }

    Keys.onPressed:
    {
        if (event.key === Qt.Key_M)
        {
        }
        else if (event.key === Qt.Key_F1)
        {
            // RED
            if (root.state == "")
            {
                root.state = "filter";
                filterBackground.state = "";
                titleEdit.focus = true;
            }
            else
            {
                root.state = ""
                recordingList.focus = true;
            }
        }
        else if (event.key === Qt.Key_F2)
        {
            // GREEN
            filterDialog.filterTitle = root.filterTitle;
            filterDialog.filterCategory = root.filterCategory;
            filterDialog.filterRecGroup = root.filterRecGroup;
            filterDialog.show();
        }
        else if (event.key === Qt.Key_F3)
        {
            // YELLOW
            if (dateSorterActive)
                recordingsModel.sort = "Title,Season,Episode";
            else
                recordingsModel.sort = "StartTime";

            recordingsModel.reload();

            dateSorterActive = !dateSorterActive;

            sort.text = "Sort " + (dateSorterActive ? "(Date & Time)" : "(Season & Episode)")
        }
        else if (event.key === Qt.Key_F4)
        {
            //BLUE
            showFanart = !showFanart;
        }
    }

    Image
    {
        id: fanartImage
        x: xscale(0); y: yscale(0); width: xscale(1280); height: yscale(720)
        visible: root.showFanart
    }

    InfoText
    {
        x: xscale(1050); y: yscale(5); width: xscale(200);
        text: (recordingList.currentIndex + 1) + " of " + recordingsModel.totalAvailable;
        horizontalAlignment: Text.AlignRight
    }

    FocusScope
    {
        id: filterBackground
        x: xscale(-290); y: yscale(50); width: xscale(280); height: yscale(380)
        visible: false
        focus: false

        states:
        [
            State
            {
                name: ""
                PropertyChanges { target: flickable; contentY: 0 }
            },
            State
            {
                name: "title"
                PropertyChanges { target: flickable; contentY: 0 }
            },
            State
            {
                name: "category"
                PropertyChanges { target: flickable; contentY: titleLabel.height + titleEdit.height + yscale(15)}
            },
            State
            {
                name: "recgroup"
                PropertyChanges { target: flickable; contentY: titleLabel.height + titleEdit.height + categoryDropDown.height + yscale(20)}
            }
        ]

        BaseBackground
        {
            anchors.fill: parent
        }

        LabelText
        {
            x: xscale(5); y: yscale(5); width: parent.width - xscale(10);
            horizontalAlignment: Text.AlignHCenter
            text: "Recordings Filter"
        }

        Flickable
        {
            id: flickable
            x: xscale(5); y: yscale(50); width: parent.width - xscale(10); height: parent.height - yscale(50)
            clip: true

            Behavior on contentY {NumberAnimation {duration: 500; easing.type: Easing.InOutQuad}}

            Column
            {
                spacing: yscale(5)
                anchors.fill: parent

                move: Transition
                {
                    NumberAnimation { properties: "x,y,height"; duration: 500; easing.type: Easing.InOutQuad }
                }

                add: Transition
                {
                    NumberAnimation { properties: "x,y,height"; duration: 500; easing.type: Easing.InOutQuad }
                }

                InfoText
                {
                    id: titleLabel
                    x: 0; //y: yscale(35)
                    width: parent.width; height: yscale(30)
                    text: "Title"
                }

                BaseEdit
                {
                    id: titleEdit
                    x: 0;
                    width: parent.width;
                    height: 50
                    text: "";
                    focus: false
                    KeyNavigation.up: recGroupDropDown;
                    KeyNavigation.down: categoryDropDown;
                    onEditingFinished:  { filterBackground.state = ""; updateFilter(); }
                    onTextChanged: if (filterBackground.state != "title") filterBackground.state = "title"; //else filterBackground.state = "";
                }

                DropDown
                {
                    id: categoryDropDown
                    x: 0;
                    width: parent.width
                    height: 80
                    expandedHeight: 330
                    labelText: "Category"
                    model: ProgCategoryModel {}
                    onItemChanged: updateFilter();
                    onStateChanged: if (state == "expanded") filterBackground.state = "category"; else filterBackground.state = ""
                    KeyNavigation.down: recGroupDropDown;
                    KeyNavigation.up: titleEdit;
                }

                DropDown
                {
                    id: recGroupDropDown
                    x: 0;
                    width: parent.width
                    height: 50
                    expandedHeight: 330
                    labelText: "Recording Group"
                    model: RecGroupModel {}
                    onItemChanged: updateFilter();
                    onStateChanged: if (state == "expanded") filterBackground.state = "recgroup"; else filterBackground.state = ""
                    KeyNavigation.up: categoryDropDown
                    KeyNavigation.down: titleEdit
                }
            }
        }
    }

    BaseBackground
    {
        id: listBackground
        x: xscale(10); y: yscale(50); width: parent.width - x - xscale(10); height: yscale(380)
    }

    BaseBackground { x: xscale(10); y: yscale(445); width: parent.width - xscale(20); height: yscale(230) }

    Component
    {
        id: listRow

        ListItem
        {
            Image
            {
                id: coverImage
                x: xscale(13); y: yscale(3); height: parent.height - yscale(6); width: height
                source: if (Coverart)
                            settings.masterBackend + Coverart
                        else
                            mythUtils.findThemeFile("images/grid_noimage.png")
            }
            ListText
            {
                x: coverImage.width + xscale(20)
                width: xscale(670); height: yscale(50)
                text: if (Title) (SubTitle ? Title + ": " + SubTitle : Title); else ""
                fontColor: theme.labelFontColor
            }
            ListText
            {
                x: xscale(745)
                width: xscale(190); height: yscale(50)
                horizontalAlignment: Text.AlignRight
                text:
                {
                    if (Season != 0 || Episode != 0)
                        return "S:" + Season + " E:" + Episode;
                    else if (Airdate != "")
                        return Qt.formatDateTime(Airdate, "(yyyy)");
                    else
                        return ""
                }
            }
            ListText
            {
                x: coverImage.width + xscale(880)
                width: xscale(190); height: yscale(50)
                horizontalAlignment: Text.AlignRight
                text: Qt.formatDateTime(StartTime, "ddd dd/MM/yy")
            }
            ListText
            {
                x: coverImage.width + xscale(1075)
                width: xscale(80); height: yscale(50)
                horizontalAlignment: Text.AlignRight
                text: Qt.formatDateTime(StartTime, "hh:mm")
            }
            Image
            {
                id: recordingIcon
                x: xscale(1205); y: yscale(10); height: parent.height - yscale(20); width: height
                source: if (Status === "Recording") mythUtils.findThemeFile("images/record.png"); else ""
                SequentialAnimation
                {
                    running: (Status === "Recording")
                    loops: Animation.Infinite
                    NumberAnimation { target: recordingIcon; property: "opacity"; to: 0.5; duration: 1000 }
                    NumberAnimation { target: recordingIcon; property: "opacity"; to: 1.0; duration: 1000 }
                }
            }
        }
    }

    RecordingsModel
    {
        id: recordingsModel
        onTotalAvailableChanged:
        {
            recordingList.positionViewAtIndex(0, ListView.Beginning);
            recordingList.currentIndex = 0;
        }
        onDataChanged:
        {
            console.log("onDatachanged row: " + topLeft.row + ", currentIndex: " + recordingList.currentIndex);
            if (topLeft.row == recordingList.currentIndex)
                updateProgramDetails();
        }
    }

    ButtonList
    {
        id: recordingList
        x: xscale(20); y: yscale(65); width: parent.width - x - xscale(20); height: yscale(350)

        model: recordingsModel
        delegate: listRow

        Keys.onReturnPressed:
        {
            var hostname = model.get(currentIndex).HostName === settings.hostName ? "localhost" : model.get(currentIndex).HostName
            var filename = "myth://" + "type=recording:server=" + hostname + ":port=6543:filename=" + model.get(currentIndex).FileName;
            stack.push({item: Qt.resolvedUrl("InternalPlayer.qml"), properties:{source1: filename }});
            event.accepted = true;
            returnSound.play();
        }

        onCurrentIndexChanged: updateProgramDetails();
    }

    TitleText
    {
        id: title
        x: xscale(30); y: yscale(450)
        width: xscale(930); height: yscale(50)
    }

    Image
    {
        id: channelIcon
        x: xscale(365); y: yscale(510); width: xscale(30); height: yscale(30)
    }

    InfoText
    {
        id: channel
        x: xscale(400); y: yscale(500)
        width: xscale(900); height: yscale(50)
    }

    InfoText
    {
        id: startTime
        x: xscale(30); y: yscale(500)
        width: xscale(330); height: yscale(50)
    }

    InfoText
    {
        id: description
        x: xscale(30); y: yscale(540)
        width: xscale(900); height: yscale(100)
        multiline: true
    }

    InfoText
    {
        id: recordingStatus
        x: xscale(970); y: yscale(450)
        width: xscale(140); height: yscale(50)
        horizontalAlignment: Text.AlignRight
        fontColor: "red";
        text: "Recording"
        visible: false
    }

    InfoText
    {
        id: programCategory
        x: xscale(20); y: yscale(630); width: xscale(220)
        fontColor: "grey"
    }

    InfoText
    {
        id: programEpisode
        x: xscale(400); y: yscale(630); width: xscale(320)
        horizontalAlignment: Text.AlignHCenter
        fontColor: "grey"
    }

    InfoText
    {
        id: programFirstAired
        x: xscale(890); y: yscale(630); width: xscale(220)
        fontColor: "grey"
        horizontalAlignment: Text.AlignRight
    }

//     Image
//     {
//         id: bannerImage
//         x: xscale(300); y: yscale(480); height: yscale(60); width: 300
//         source:
//         {
//             if (recordingList.model.get(recordingList.currentIndex).Banner)
//                 settings.masterBackend + recordingList.model.get(recordingList.currentIndex).Banner
//             else
//                 ""
//         }
//     }

    Image
    {
        id: coverartImage
        x: xscale(1130); y: yscale(460); height: yscale(200); width: xscale(120)
    }

    Image
    {
        x: xscale(30); y: yscale(682); width: xscale(32); height: yscale(32)
        source: mythUtils.findThemeFile("images/red_bullet.png")
    }

    InfoText
    {
        x: xscale(65); y: yscale(682); width: xscale(250); height: yscale(32)
        text: "Options"
    }

    Image
    {
        x: xscale(350); y: yscale(682); width: xscale(32); height: yscale(32)
        source: mythUtils.findThemeFile("images/green_bullet.png")
    }

    InfoText
    {
        id: show
        x: xscale(385); y: yscale(682); width: xscale(250); height: yscale(32)
        text: "Show (All Recordings)"
    }

    Image
    {
        x: xscale(670); y: yscale(682); width: xscale(32); height: yscale(32)
        source: mythUtils.findThemeFile("images/yellow_bullet.png")
    }

    InfoText
    {
        id: sort
        x: xscale(705); y: yscale(682); width: xscale(250); height: yscale(32)
        text: "Sort (Time)"
    }

    Image
    {
        x: xscale(990); y: yscale(682); width: xscale(32); height: yscale(32)
        source: mythUtils.findThemeFile("images/blue_bullet.png")
    }

    InfoText
    {
        x: xscale(1025); y: yscale(682); width: xscale(250); height: yscale(32)
        text: "Info"
    }

    RecordingFilterDialog
    {
        id: filterDialog

        title: "Filter Recordings"
        message: ""

        model: recordingsModel

        width: xscale(600); height: yscale(500)

        onAccepted:
        {
            recordingList.focus = true;
            updateFilter();
        }
        onCancelled:
        {
            recordingList.focus = true;
        }
    }

    function updateFilter()
    {
        recordingsModel.titleRegExp = titleEdit.text;
        recordingsModel.category = categoryDropDown.editText;
        recordingsModel.recGroup = recGroupDropDown.editText;
        recordingsModel.reload();

        if (recordingsModel.titleRegExp == "" && recordingsModel.category == "" && recordingsModel.recGroup == "")
            show.text = "Show (All Recordings)";
        else
            show.text = "Show (Filtered Recordings)";
    }

    function updateProgramDetails()
    {
        // title and subtitle
        var progtitle = recordingList.model.get(recordingList.currentIndex).Title;
        var subtitle = recordingList.model.get(recordingList.currentIndex).SubTitle;
        var result = "";

        if (progtitle != undefined && progtitle.length > 0)
            result = progtitle;

        if (subtitle != undefined && subtitle.length > 0)
            result += " - " + subtitle;

        title.text = result;

        // description
        if (recordingList.model.get(recordingList.currentIndex).Description != undefined)
            description.text = recordingList.model.get(recordingList.currentIndex).Description
        else
            description.text = ""

        // recording
        recordingStatus.visible = (recordingList.model.get(recordingList.currentIndex).Status == "Recording");

        // start time
        startTime.text = Qt.formatDateTime(recordingList.model.get(recordingList.currentIndex).StartTime, "ddd dd MMM yyyy hh:mm")

        // category
        if (recordingList.model.get(recordingList.currentIndex).Category != undefined)
            programCategory.text = recordingList.model.get(recordingList.currentIndex).Category
        else
            programCategory.text = ""

        // channel
        channel.text = recordingList.model.get(recordingList.currentIndex).ChanNum + " - " + recordingList.model.get(recordingList.currentIndex).CallSign + " - " + recordingList.model.get(recordingList.currentIndex).ChannelName

        // channel icon
        if (recordingList.model.get(recordingList.currentIndex).IconURL)
            channelIcon.source = settings.masterBackend + recordingList.model.get(recordingList.currentIndex).IconURL
        else
            channelIcon.source = ""

        // season and episode
        var season = recordingList.model.get(recordingList.currentIndex).Season
        var episode = recordingList.model.get(recordingList.currentIndex).Episode
        var total = recordingList.model.get(recordingList.currentIndex).TotalEpisodes
        var res = ""

        if (season > 0)
            res = "Season: " + season + " ";
        if (episode > 0)
        {
            res += " Episode: " + episode;

            if (total > 0)
                res += "/" + total;
        }

        programEpisode.text = res;

        // first aired
        if (recordingList.model.get(recordingList.currentIndex).Airdate != undefined)
            programFirstAired.text = "First Aired: " + Qt.formatDateTime(recordingList.model.get(recordingList.currentIndex).Airdate, "dd/MM/yyyy");
        else
            programFirstAired.text = ""

        // fan art
        if (recordingList.model.get(recordingList.currentIndex).Fanart)
            fanartImage.source = settings.masterBackend + recordingList.model.get(recordingList.currentIndex).Fanart
        else
            fanartImage.source =  ""

        // cover art
        if (recordingList.model.get(recordingList.currentIndex).Coverart)
            coverartImage.source = settings.masterBackend + recordingList.model.get(recordingList.currentIndex).Coverart
        else
            coverartImage.source = mythUtils.findThemeFile("images/grid_noimage.png")
    }
}
