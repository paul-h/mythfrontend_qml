import QtQuick 2.0
import Base 1.0
import "../../../Models"

BaseScreen
{
    defaultFocusItem: titleEdit

    property var videosModel
    property int currentIndex
    property int currentPage: 1

    QtObject
    {
        id: metadata
        property string id
        property string title
        property string subtitle
        property string description
        property string season
        property string episode
        property string tagline
        property string genres
        property string contentType
        property string inetref
        property string studio
        property string coverart
        property string fanart
        property string banner
        property string screenshot
    }

    Component.onCompleted:
    {
        showTitle(true, "Video Metadata Editor (Page 1)");
        showTime(false);
        showTicker(false);

        // save the metadata
        metadata.id = videosModel.get(currentIndex).Id
        metadata.title = videosModel.get(currentIndex).Title
        metadata.subtitle = videosModel.get(currentIndex).SubTitle
        metadata.description = videosModel.get(currentIndex).Description
        metadata.season = videosModel.get(currentIndex).Season
        metadata.episode = videosModel.get(currentIndex).Episode
        metadata.tagline = videosModel.get(currentIndex).Tagline
        metadata.genres = videosModel.get(currentIndex).Genre
        metadata.contentType = videosModel.get(currentIndex).ContentType
        metadata.inetref = videosModel.get(currentIndex).Inetref
        metadata.studio = videosModel.get(currentIndex).Studio
        metadata.coverart = videosModel.get(currentIndex).Coverart
        metadata.fanart = videosModel.get(currentIndex).Fanart
        metadata.banner = videosModel.get(currentIndex).Banner
        metadata.screenshot = videosModel.get(currentIndex).Screenshot
    }

    // page 1
    Item
    {
        id: page1
        anchors.fill: parent
        visible: true

        LabelText
        {
            x: xscale(48); y: yscale(100)
            text: "Title:"
        }

        BaseEdit
        {
            id: titleEdit
            x: xscale(400); y: yscale(100)
            width: xscale(700)
            height: yscale(48)
            text: metadata.title
            KeyNavigation.up: saveButton
            KeyNavigation.down: subtitleEdit
        }

        LabelText
        {
            x: xscale(50); y: yscale(150)
            text: "Subtitle:"
        }

        BaseEdit
        {
            id: subtitleEdit
            x: xscale(400); y: yscale(150)
            width: xscale(700)
            height: yscale(48)
            text: metadata.subtitle
            KeyNavigation.up: titleEdit;
            KeyNavigation.down: seasonEdit;
        }

        LabelText
        {
            x: xscale(50); y: yscale(200)
            text: "Season:"
        }

        BaseEdit
        {
            id: seasonEdit
            x: xscale(400); y: yscale(200)
            width: xscale(100)
            height: yscale(48)
            text: metadata.season
            KeyNavigation.up: subtitleEdit;
            KeyNavigation.down: descriptionEdit;
            KeyNavigation.right: episodeEdit;
        }

        LabelText
        {
            x: xscale(700); y: yscale(200)
            text: "Episode:"
        }

        BaseEdit
        {
            id: episodeEdit
            x: xscale(1000); y: yscale(200)
            width: xscale(100)
            height: yscale(48)
            text: metadata.episode
            KeyNavigation.up: subtitleEdit;
            KeyNavigation.down: descriptionEdit;
            KeyNavigation.left: seasonEdit;
        }

        LabelText
        {
            x: xscale(50); y: yscale(250)
            text: "Description:"
        }

        BaseMultilineEdit
        {
            id: descriptionEdit
            x: xscale(400); y: yscale(250)
            width: xscale(700)
            height: yscale(280)
            text: metadata.description
            KeyNavigation.up: seasonEdit;
            KeyNavigation.down: taglineEdit;
        }

        LabelText
        {
            x: xscale(50); y: yscale(550)
            text: "Tagline:"
        }

        BaseEdit
        {
            id:taglineEdit
            x: xscale(400); y: yscale(550)
            width: xscale(700)
            height: yscale(48)
            text: metadata.tagline
            KeyNavigation.up: descriptionEdit;
            KeyNavigation.down: prevButton1;
        }

        BaseButton
        {
            id: prevButton1;
            x: xscale(100); y: yscale(630);
            text: "<< Page 3";
            KeyNavigation.up: taglineEdit
            KeyNavigation.down: nextButton1
            onClicked:
            {
                page3.visible = true
                page1.visible = false
                genreEdit.focus = true
                showTitle(true, "Video Metadata Editor (Page 3)");
                returnSound.play();
            }
        }

        BaseButton
        {
            id: nextButton1;
            x: xscale(600); y: yscale(630);
            text: "Page 2 >>";
            KeyNavigation.up: prevButton1
            KeyNavigation.down: saveButton
            onClicked:
            {
                page2.visible = true
                page1.visible = false
                coverartEdit.focus = true
                showTitle(true, "Video Metadata Editor (Page 2)");
                returnSound.play();
            }
        }
    }

    // page 2
    Item
    {
        id: page2
        anchors.fill: parent
        visible: false

        LabelText
        {
            x: xscale(50); y: yscale(90)
            text: "Coverart:"
        }

        BaseEdit
        {
            id: coverartEdit
            x: xscale(400); y: yscale(90)
            width: xscale(700)
            height: yscale(50)
            text: metadata.coverart
            KeyNavigation.up: saveButton;
            KeyNavigation.down: fanartEdit;
        }

        Image
        {
            id: coverartImage
            x: xscale(1120); y: yscale(65); height: yscale(100); width: xscale(100)
            fillMode: Image.PreserveAspectFit
            source:
            {
                if (metadata.coverart)
                    settings.masterBackend + "Content/GetImageFile?StorageGroup=Coverart&FileName=" + metadata.coverart
                    else
                        mythUtils.findThemeFile("images/grid_noimage.png")
            }
        }

        LabelText
        {
            x: xscale(50); y: yscale(200)
            text: "Fanart:"
        }

        BaseEdit
        {
            id: fanartEdit
            x: xscale(400); y: yscale(200)
            width: xscale(700)
            height: yscale(50)
            text: metadata.fanart
            KeyNavigation.up: coverartEdit;
            KeyNavigation.down: bannerEdit;
        }

        Image
        {
            id: fanartImage
            x: xscale(1120); y: yscale(175); width: xscale(100); height: yscale(100)
            fillMode: Image.PreserveAspectFit
            source:
            {
                if (metadata.fanart)
                    settings.masterBackend + "Content/GetImageFile?StorageGroup=Fanart&FileName=" + metadata.fanart
                    else
                        mythUtils.findThemeFile("images/grid_noimage.png")
            }
        }

        LabelText
        {
            x: xscale(50); y: yscale(310)
            text: "Banner:"
        }

        BaseEdit
        {
            id: bannerEdit
            x: xscale(400); y: yscale(310)
            width: xscale(700)
            height: yscale(50)
            text: metadata.banner
            KeyNavigation.up: fanartEdit;
            KeyNavigation.down: screenshotEdit;
        }

        Image
        {
            id: bannerImage
            x: xscale(1120); y: yscale(285); height: yscale(100); width: xscale(100)
            fillMode: Image.PreserveAspectFit
            source:
            {
                if (metadata.banner)
                    settings.masterBackend + "Content/GetImageFile?StorageGroup=Banner&FileName=" + metadata.banner
                    else
                        mythUtils.findThemeFile("images/grid_noimage.png")
            }
        }

        LabelText
        {
            x: xscale(50); y: yscale(420)
            text: "Screenshot:"
        }

        BaseEdit
        {
            id: screenshotEdit
            x: xscale(400); y: yscale(420)
            width: xscale(700)
            height: yscale(50)
            text: metadata.screenshot
            KeyNavigation.up: bannerEdit;
            KeyNavigation.down: nextButton2;
        }

        Image
        {
            id: screenshotImage
            fillMode: Image.PreserveAspectFit
            x: xscale(1120); y: yscale(395); height: yscale(100); width: xscale(100)
            source:
            {
                if (metadata.screenshot)
                    settings.masterBackend + "Content/GetImageFile?StorageGroup=Banner&FileName=" + metadata.screenshot
                    else
                        mythUtils.findThemeFile("images/grid_noimage.png")
            }
        }

        BaseButton
        {
            id: prevButton2;
            x: xscale(100); y: yscale(630);
            text: "<< Page 1";
            KeyNavigation.up: screenshotEdit
            KeyNavigation.down: nextButton2
            onClicked:
            {
                page2.visible = false
                page1.visible = true
                titleEdit.focus = true
                showTitle(true, "Video Metadata Editor (Page 1)");
                returnSound.play();
            }
        }

        BaseButton
        {
            id: nextButton2;
            x: xscale(600); y: yscale(630);
            text: "Page 3 >>";
            KeyNavigation.up: prevButton2
            KeyNavigation.down: saveButton
            onClicked:
            {
                page2.visible = false
                page3.visible = true
                genreEdit.focus = true
                showTitle(true, "Video Metadata Editor (Page 3)");
                returnSound.play();
            }
        }
    }

    // page 3
    Item
    {
        id: page3
        anchors.fill: parent
        visible: false

        LabelText
        {
            x: xscale(50); y: yscale(100)
            height: yscale(48)
            text: "Genres:"
        }

        BaseEdit
        {
            id: genreEdit
            x: xscale(400); y: yscale(100)
            width: xscale(700)
            height: yscale(48)
            text: metadata.genres
            KeyNavigation.up: saveButton;
            KeyNavigation.down: studioEdit;
        }

        LabelText
        {
            x: xscale(50); y: yscale(150)
            text: "Studio:"
        }

        BaseEdit
        {
            id: studioEdit
            x: xscale(400); y: yscale(150)
            width: xscale(700)
            height: yscale(48)
            text: metadata.studio
            KeyNavigation.up: genreEdit;
            KeyNavigation.down: inetrefEdit;
        }

        LabelText
        {
            x: xscale(50); y: yscale(200)
            text: "Inetref:"
        }

        BaseEdit
        {
            id: inetrefEdit
            x: xscale(400); y: yscale(200)
            width: xscale(700)
            height: yscale(48)
            text: metadata.inetref
            KeyNavigation.up: studioEdit;
            KeyNavigation.down: typeEdit;
        }

        LabelText
        {
            x: xscale(50); y: yscale(250)
            text: "Content Type:"
        }

        BaseEdit
        {
            id: typeEdit
            x: xscale(400); y: yscale(250)
            width: xscale(700)
            height: yscale(48)
            text: metadata.contentType
            KeyNavigation.up: inetrefEdit;
            KeyNavigation.down: saveButton;
        }

        BaseButton
        {
            id: prevButton3;
            x: xscale(100); y: yscale(630);
            text: "<< Page 2";
            KeyNavigation.up: typeEdit
            KeyNavigation.down: nextButton3
            onClicked:
            {
                page3.visible = false
                page2.visible = true
                coverartEdit.focus = true
                showTitle(true, "Video Metadata Editor (Page 2)");
                returnSound.play();
            }
        }

        BaseButton
        {
            id: nextButton3;
            x: xscale(600); y: yscale(630);
            text: "Page 1 >>";
            KeyNavigation.up: prevButton3
            KeyNavigation.down: saveButton
            KeyNavigation.left: prevButton3
            KeyNavigation.right: saveButton
            onClicked:
            {
                page3.visible = false
                page1.visible = true
                titleEdit.focus = true
                showTitle(true, "Video Metadata Editor (Page 1)");
                returnSound.play();
            }
        }

    }

    BaseButton
    {
        id: saveButton;
        x: xscale(900); y: yscale(630);
        text: "Save";
        KeyNavigation.up:
        {
            if (page1.visible)
                taglineEdit;
            else if (page2.visible)
                screenshotEdit;
            else if (page3.visible)
                inetrefEdit;
            else
                titleEdit
        }

        KeyNavigation.down:
        {
            if (page1.visible)
                titleEdit;
            else if (page2.visible)
                coverartEdit;
            else if (page3.visible)
                genreEdit;
            else
                titleEdit
        }

        onClicked:
        {
            console.log("save button pressed");
            updateVideoMetadata();
            returnSound.play();
            stack.pop();
        }
    }

    function updateVideoMetadata()
    {
        var http = new XMLHttpRequest();
        var url = settings.masterBackend + "Video/UpdateVideoMetadata";
        var params = "Id=%1".arg(videosModel.get(currentIndex).Id)

        // only update the metadata that has actually changed

        // page 1
        if (titleEdit.text != videosModel.get(currentIndex).Title)
            params += "&Title=%1".arg(titleEdit.text);

        if (subtitleEdit.text != videosModel.get(currentIndex).SubTitle)
            params += "&SubTitle=%1".arg(subtitleEdit.text);

        if (seasonEdit.text != videosModel.get(currentIndex).Season)
            params += "&Season=%1".arg(seasonEdit.text);

        if (episodeEdit.text != videosModel.get(currentIndex).Episode)
            params += "&Episode=%1".arg(episodeEdit.text);

        if (descriptionEdit.text != videosModel.get(currentIndex).Description)
            params += "&Description=%1".arg(descriptionEdit.text);

        if (taglineEdit.text != videosModel.get(currentIndex).Tagline)
            params += "&TagLine=%1".arg(taglineEdit.text);

        // page 2
        if (coverartEdit.text != videosModel.get(currentIndex).Coverart)
            params += "&Coverart=%1".arg(coverartEdit.text);

        if (fanartEdit.text != videosModel.get(currentIndex).Fanart)
            params += "&Fanart=%1".arg(fanartEdit.text);

        if (bannerEdit.text != videosModel.get(currentIndex).Banner)
            params += "&Banner=%1".arg(bannerEdit.text);

        if (screenshotEdit.text != videosModel.get(currentIndex).Screenshot)
            params += "&Screenshot=%1".arg(screenshotEdit.text);

        // page 3
        if (genreEdit.text != videosModel.get(currentIndex).Genre)
            params += "&Genres=%1".arg(genreEdit.text);

        if (studioEdit.text != videosModel.get(currentIndex).Studio)
            params += "&Studio=%1".arg(studioEdit.text);

        if (inetrefEdit.text != videosModel.get(currentIndex).Inetref)
            params += "&Inetref=%1".arg(inetrefEdit.text);

        if (typeEdit.text != videosModel.get(currentIndex).ContentType)
            params += "&ContentType=%1".arg(typeEdit.text);

        http.open("POST", url, true);

        // Send the proper header information along with the request
        http.setRequestHeader("Content-type", "application/x-www-form-urlencoded");
        http.setRequestHeader("Content-length", params.length);
        http.setRequestHeader("Connection", "close");

        http.onreadystatechange = function()
        { // Call a function when the state changes
            if (http.readyState == 4)
            {
                if (http.status == 200)
                {
                    console.log("ok")
                }
                else
                {
                    console.log("error: " + http.status)
                }
            }
        }

        http.send(params);
    }
}
