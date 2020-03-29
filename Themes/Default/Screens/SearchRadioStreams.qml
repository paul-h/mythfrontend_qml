import QtQuick 2.0
import Models 1.0
import Base 1.0
import Dialogs 1.0
import SortFilterProxyModel 0.2
import QmlVlc 0.1

BaseScreen
{
    id: root

    property string filterBroadcaster
    property string filterChannel
    property string filterGenre
    property string sorter: "broadcaster"

    property VlcPlayer player

    defaultFocusItem: streamList

    Component.onCompleted:
    {
        showTitle(true, "Search Radio Streams");
        showTime(false);
        showTicker(false);
    }

    property list<QtObject> broadcasterSorter:
    [
        RoleSorter { roleName: "broadcaster" },
        RoleSorter { roleName: "channel" }
    ]

    property list<QtObject> genreSorter:
    [
        RoleSorter { roleName: "genre" },
        RoleSorter { roleName: "broadcaster" },
        RoleSorter { roleName: "channel" }
    ]

    property list<QtObject> countrySorter:
    [
        RoleSorter { roleName: "country" },
        RoleSorter { roleName: "broadcaster" },
        RoleSorter { roleName: "channel" }
    ]

    property list<QtObject> languageSorter:
    [
        RoleSorter { roleName: "language" },
        RoleSorter { roleName: "broadcaster" },
        RoleSorter { roleName: "channel" }
    ]

    SortFilterProxyModel
    {
        id: streamsProxyModel
        //sourceModel: RadioStreamModel {}
        sourceModel: radioStreamsDBModel

        filters:
        [
            AllOf
            {
                RegExpFilter
                {
                    roleName: "broadcaster"
                    pattern: filterBroadcaster
                    caseSensitivity: Qt.CaseInsensitive
                }
                RegExpFilter
                {
                    roleName: "channel"
                    pattern: filterChannel
                    caseSensitivity: Qt.CaseInsensitive
                }
                RegExpFilter
                {
                    roleName: "genre"
                    pattern: filterGenre
                    caseSensitivity: Qt.CaseInsensitive
                }
            }
        ]
        //sorters: broadcasterSorter
    }

    Keys.onPressed:
    {
        if (event.key === Qt.Key_M)
        {
        }
        else if (event.key === Qt.Key_F1)
        {
            // RED
            if (sorter === "broadcaster")
            {
                sorter = "genre";
                streamsProxyModel.sorters = genreSorter;
                footer.redText = "Sort (Genre)";
            }
            else if (sorter === "genre")
            {
                sorter = "country"
                streamsProxyModel.sorters = countrySorter;
                footer.redText = "Sort (Country)";
            }
            else if (sorter === "country")
            {
                sorter = "language"
                streamsProxyModel.sorters = languageSorter;
                footer.redText = "Sort (Language)";
            }
            else
            {
                sorter = "broadcaster"
                streamsProxyModel.sorters = broadcasterSorter;
                footer.redText = "Sort (Broadcaster)";
            }
        }
        else if (event.key === Qt.Key_F2)
        {
            // GREEN
            filterDialog.filterBroadcaster = root.filterBroadcaster;
            filterDialog.filterChannel = root.filterChannel;
            filterDialog.filterGenre = root.filterGenre;
            filterDialog.show();
        }
        else if (event.key === Qt.Key_F3)
        {
            // YELLOW

            event.accepted = true;
            returnSound.play();
        }
        else if (event.key === Qt.Key_F4)
        {
            //BLUE

            player.toggleMute();
            event.accepted = true;
            returnSound.play();
        }
    }
//    Image
//    {
//        id: fanartImage
//        x: xscale(0); y: yscale(0); width: xscale(1280); height: yscale(720)
//        source:
//        {
//            if (videoList.model.get(videoList.currentIndex).Fanart)
//                settings.masterBackend + videoList.model.get(videoList.currentIndex).Fanart
//            else
//                ""
//        }
//    }

    InfoText
    {
        x: xscale(1050); y: yscale(5); width: xscale(200);
        text: (streamList.currentIndex + 1) + " of " + streamsProxyModel.count;
        horizontalAlignment: Text.AlignRight
    }

    BaseBackground
    {
        x: xscale(15); y: yscale(50); width: xscale(1250); height: yscale(400)
    }

    BaseBackground { x: xscale(10); y: yscale(465); width: parent.width - xscale(20); height: yscale(210) }

    Component
    {
        id: listRow

        ListItem
        {
            Image
            {
                id: coverImage
                x: xscale(13); y: yscale(3); height: parent.height - yscale(6); width: height
                source: if (logourl)
                            logourl
                        else
                            mythUtils.findThemeFile("images/grid_noimage.png")
            }
            ListText
            {
                x: coverImage.width + xscale(20)
                width: xscale(600); height: yscale(50)
                text: broadcaster ? broadcaster + " - " + channel : channel
                fontColor: theme.labelFontColor
            }
            ListText
            {
                x: coverImage.width + xscale(625)
                width: xscale(250); height: yscale(50)
                horizontalAlignment: Text.AlignRight
                text: genre
            }
            ListText
            {
                x: coverImage.width + xscale(880)
                width: xscale(300); height: yscale(50)
                horizontalAlignment: Text.AlignRight
                text: country + " - " + language
            }
        }
    }

    ButtonList
    {
        id: streamList
        x: xscale(20); y: yscale(65); width: xscale(1240); height: yscale(360)

        clip: true
        model: streamsProxyModel
        delegate: listRow

        Keys.onPressed:
        {
            if (event.key === Qt.Key_S)
            {
                //if (dateSorterActive)
                //    recordingsProxyModel.sorters = episodeSorter;
                //else
                //    recordingsProxyModel.sorters = dateSorter

                //dateSorterActive = !dateSorterActive;
            }
        }

        Keys.onReturnPressed:
        {
            player.mrl = streamList.model.get(streamList.currentIndex).url1;
        }
    }

    TitleText
    {
        x: xscale(30); y: yscale(465)
        width: xscale(1120); height: yscale(50)
        text:
        {
            if (streamList.model.get(streamList.currentIndex).broadcaster !== "")
                streamList.model.get(streamList.currentIndex).broadcaster + " - " + streamList.model.get(streamList.currentIndex).channel
            else
                streamList.model.get(streamList.currentIndex).channel
        }
    }

    Image
    {
        id: streamImage
        x: xscale(1170); y: yscale(475); width: xscale(90); height: yscale(90)
        source:
        {
            if (streamList.model.get(streamList.currentIndex).logourl)
                streamList.model.get(streamList.currentIndex).logourl
            else
                ""
        }
    }

    InfoText
    {
        x: xscale(30); y: yscale(520)
        width: xscale(340); height: yscale(50)
        text: streamList.model.get(streamList.currentIndex).genre
    }

    Image
    {
        id: countryImage
        x: xscale(370); y: yscale(520); width: xscale(50); height: yscale(50)
        source:
        {
            if (streamList.model.get(streamList.currentIndex).country)
                "http://www.radiosure.com/rsdbms/flags/" + streamList.model.get(streamList.currentIndex).country + ".png";
            else
                ""
        }
    }

    InfoText
    {
        x: xscale(420); y: yscale(520)
        width: xscale(730); height: yscale(50)
        text: streamList.model.get(streamList.currentIndex).country + " - " + streamList.model.get(streamList.currentIndex).language
    }

    InfoText
    {
        x: xscale(30); y: yscale(570)
        width: xscale(1200); height: yscale(100)
        text: streamList.model.get(streamList.currentIndex).description
        multiline: true
    }

    Footer
    {
        id: footer
        redText: "Sort (Broadcaster)"
        greenText: "Filter"
        yellowText: "Add"
        blueText: "Mute"
    }


    StreamFilterDialog
    {
        id: filterDialog

        title: "Filter Streams"
        message: ""

        streamsModel: streamsProxyModel.sourceModel

        width: 600; height: 500

        onAccepted:
        {
            streamList.focus = true;

            root.filterBroadcaster = filterBroadcaster;
            root.filterChannel = filterChannel;
            root.filterGenre = filterGenre;
        }
        onCancelled:
        {
            streamList.focus = true;
        }
    }
}


