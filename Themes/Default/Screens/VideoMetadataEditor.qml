import QtQuick 2.0
import Base 1.0
import Models 1.0
import mythqml.net 1.0
import "../../../Util.js" as Util

BaseScreen
{
    defaultFocusItem: titleEdit

    property string videoFilename
    property var metadataModel
    property int currentIndex: 0
    property int currentPage: 1

    signal saved()

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
        property string categories
        property string contentType
        property string inetref
        property string studio
        property string coverart
        property string fanart
        property string banner
        property string screenshot

        property string channum
        property string callsign
        property string startts
        property string releasedate
        property string runtime
        property string runtimesecs
    }

    Component.onCompleted:
    {
        showTitle(true, "Video Metadata Editor (Page 1)");
        showTime(false);
        showTicker(false);

        // save the metadata
        //metadata.id = metadataModel.get(currentIndex).Id
        metadata.title = checkedValue(metadataModel.get(currentIndex).title, "");
        metadata.subtitle = checkedValue(metadataModel.get(currentIndex).subtitle, "");
        metadata.description = checkedValue(metadataModel.get(currentIndex).description, "");
        metadata.season = checkedValue(metadataModel.get(currentIndex).season, "");
        metadata.episode = checkedValue(metadataModel.get(currentIndex).episode, "");
        metadata.tagline = checkedValue(metadataModel.get(currentIndex).tagline, "");
        metadata.categories = checkedValue(metadataModel.get(currentIndex).categories, "");
        metadata.contentType = checkedValue(metadataModel.get(currentIndex).contenttype, "");
        metadata.inetref = checkedValue(metadataModel.get(currentIndex).inetref, "");
        metadata.studio = checkedValue(metadataModel.get(currentIndex).studio, "");
        metadata.coverart = checkedValue(metadataModel.get(currentIndex).coverart, "");
        metadata.fanart = checkedValue(metadataModel.get(currentIndex).fanart, "");
        metadata.banner = checkedValue(metadataModel.get(currentIndex).banner, "");
        metadata.screenshot = checkedValue(metadataModel.get(currentIndex).screenshot, "");

        metadata.channum = checkedValue(metadataModel.get(currentIndex).channum, "");
        metadata.callsign = checkedValue(metadataModel.get(currentIndex).callsign, "");
        metadata.startts = checkedValue(metadataModel.get(currentIndex).startts, "");
        metadata.releasedate = checkedValue(metadataModel.get(currentIndex).releasedate, "");
        metadata.runtime = checkedValue(metadataModel.get(currentIndex).runtime, "");
        metadata.runtimesecs = checkedValue(metadataModel.get(currentIndex).runtimesecs, "");
    }

    Keys.onPressed:
    {
        event.accepted = true;

        if (event.key === Qt.Key_F1)
        {
            // RED - cancel
            returnSound.play();
            stack.pop();
        }
        else if (event.key === Qt.Key_F2)
        {
            // GREEN - save
            save();
            returnSound.play();
            stack.pop();
        }
        else if (event.key === Qt.Key_F3)
        {
            // YELLOW - previous page
            previousPage();
        }
        else if (event.key === Qt.Key_F4)
        {
            // BLUE - next page
            nextPage();
        }
        else
            event.accepted = false;
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
            KeyNavigation.down: prevButton;
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
            onEditingFinished: coverartImage.source = findVideoImage(videoFilename, text, "coverart");
        }

        Image
        {
            id: coverartImage
            x: xscale(1120); y: yscale(65); height: yscale(100); width: xscale(100)
            fillMode: Image.PreserveAspectFit
            source: findVideoImage(videoFilename, metadata.coverart, "coverart")
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
            onEditingFinished: fanartImage.source = findVideoImage(videoFilename, text, "fanart");
        }

        Image
        {
            id: fanartImage
            x: xscale(1120); y: yscale(175); width: xscale(100); height: yscale(100)
            fillMode: Image.PreserveAspectFit
            source: findVideoImage(videoFilename, metadata.fanart, "fanart")
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
            onEditingFinished: bannerImage.source = findVideoImage(videoFilename, text, "banner");
        }

        Image
        {
            id: bannerImage
            x: xscale(1120); y: yscale(285); height: yscale(100); width: xscale(100)
            fillMode: Image.PreserveAspectFit
            source: findVideoImage(videoFilename, metadata.banner, "banner")
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
            KeyNavigation.down: nextButton;
            onEditingFinished: screenshotImage.source = findVideoImage(videoFilename, text, "screenshot");
        }

        Image
        {
            id: screenshotImage
            fillMode: Image.PreserveAspectFit
            x: xscale(1120); y: yscale(395); height: yscale(100); width: xscale(100)
            source: findVideoImage(videoFilename, metadata.screenshot, "screenshot")
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
            text: "Categories:"
        }

        BaseEdit
        {
            id: categoriesEdit
            x: xscale(400); y: yscale(100)
            width: xscale(700)
            height: yscale(48)
            text: metadata.categories
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
            KeyNavigation.up: categoriesEdit;
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
            KeyNavigation.down: channumEdit;
        }

        LabelText
        {
            x: xscale(50); y: yscale(300)
            text: "Channel No.:"
        }

        BaseEdit
        {
            id: channumEdit
            x: xscale(400); y: yscale(300)
            width: xscale(700)
            height: yscale(48)
            text: metadata.channum
            KeyNavigation.up: typeEdit;
            KeyNavigation.down: callsignEdit;
        }

        LabelText
        {
            x: xscale(50); y: yscale(350)
            text: "Channel Callsign:"
        }

        BaseEdit
        {
            id: callsignEdit
            x: xscale(400); y: yscale(350)
            width: xscale(700)
            height: yscale(48)
            text: metadata.callsign
            KeyNavigation.up: channumEdit;
            KeyNavigation.down: starttsEdit;
        }

        LabelText
        {
            x: xscale(50); y: yscale(400)
            text: "Start Time:"
        }

        BaseEdit
        {
            id: starttsEdit
            x: xscale(400); y: yscale(400)
            width: xscale(700)
            height: yscale(48)
            text: metadata.startts
            KeyNavigation.up: callsignEdit;
            KeyNavigation.down: releasedateEdit;
        }

        LabelText
        {
            x: xscale(50); y: yscale(450)
            text: "Release Date:"
        }

        BaseEdit
        {
            id: releasedateEdit
            x: xscale(400); y: yscale(450)
            width: xscale(700)
            height: yscale(48)
            text: metadata.releasedate
            KeyNavigation.up: starttsEdit;
            KeyNavigation.down: runtimeEdit;
        }

        LabelText
        {
            x: xscale(50); y: yscale(500)
            text: "Run Time (Minutes):"
        }

        BaseEdit
        {
            id: runtimeEdit
            x: xscale(400); y: yscale(500)
            width: xscale(700)
            height: yscale(48)
            text: metadata.runtime
            KeyNavigation.up: releasedateEdit;
            KeyNavigation.down: runtimesecEdit;
        }

        LabelText
        {
            x: xscale(50); y: yscale(550)
            text: "Run Time (Seconds):"
        }

        BaseEdit
        {
            id: runtimesecEdit
            x: xscale(400); y: yscale(550)
            width: xscale(700)
            height: yscale(48)
            text: metadata.runtimesecs
            KeyNavigation.up: runtimeEdit;
            KeyNavigation.down: saveButton;
        }

    }

    BaseButton
    {
        id: prevButton;
        x: xscale(100); y: yscale(620);
        text: "Previous Page";
        KeyNavigation.up:
        {
            if (currentPage === 1)
                taglineEdit
            else if (currentPage === 2)
                screenshotEdit
            else if (currentPage === 3)
                runtimesecEdit
        }
        KeyNavigation.down:
        {
            if (currentPage === 1)
                titleEdit
            else if (currentPage === 2)
                coverartEdit
            else if (currentPage === 3)
                categoriesEdit
        }
        KeyNavigation.right: nextButton
        KeyNavigation.left: saveButton

        onClicked: previousPage()
    }

    BaseButton
    {
        id: nextButton;
        x: xscale(400); y: yscale(620);
        text: "Next Page";
        KeyNavigation.up:
        {
            if (currentPage === 1)
                taglineEdit
            else if (currentPage === 2)
                screenshotEdit
            else if (currentPage === 3)
                runtimesecEdit
        }
        KeyNavigation.down:
        {
            if (currentPage === 1)
                titleEdit
            else if (currentPage === 2)
                coverartEdit
            else if (currentPage === 3)
                categoriesEdit
        }
        KeyNavigation.right: saveButton
        KeyNavigation.left: prevButton
        onClicked: nextPage();
    }

    BaseButton
    {
        id: saveButton;
        x: xscale(900); y: yscale(620);
        text: "Save";
        KeyNavigation.up:
        {
            if (currentPage === 1)
                taglineEdit
            else if (currentPage === 2)
                screenshotEdit
            else if (currentPage === 3)
                runtimesecEdit
        }

        KeyNavigation.down:
        {
            if (currentPage === 1)
                titleEdit
            else if (currentPage === 2)
                coverartEdit
            else if (currentPage === 3)
                categoriesEdit
        }

        KeyNavigation.right: prevButton
        KeyNavigation.left: nextButton

        onClicked:
        {
            save();
            returnSound.play();
            stack.pop();
        }
    }

    Footer
    {
        id: footer
        redText: "Cancel"
        greenText: "Save"
        yellowText: "Previous Page"
        blueText: "Next Page"
    }

    function previousPage()
    {
        if (currentPage == 1)
            currentPage = 3;
        else
            currentPage--;

        switchPage();
    }

    function nextPage()
    {
        if (currentPage == 3)
            currentPage = 1;
        else
            currentPage++;

        switchPage();
    }

    function switchPage()
    {
        if (currentPage == 1)
        {
            page1.visible = true;
            page2.visible = false;
            page3.visible = false;
            titleEdit.focus = true;
            showTitle(true, "Video Metadata Editor (Page 1)");
            returnSound.play();
        }
        else if (currentPage == 2)
        {
            page1.visible = false;
            page2.visible = true;
            page3.visible = false;
            coverartEdit.focus = true;
            showTitle(true, "Video Metadata Editor (Page 2)");
            returnSound.play();
        }
        else if (currentPage == 3)
        {
            page1.visible = false;
            page2.visible = false;
            page3.visible = true;
            categoriesEdit.focus = true;
            showTitle(true, "Video Metadata Editor (Page 3)");
            returnSound.play();
        }
    }

    function save()
    {
        metadata.title = titleEdit.text;
        metadata.subtitle = subtitleEdit.text;
        metadata.description = descriptionEdit.text;
        metadata.season = seasonEdit.text;
        metadata.episode = episodeEdit.text;
        metadata.tagline = taglineEdit.text;
        metadata.categories = categoriesEdit.text;
        metadata.contentType = typeEdit.text;
        metadata.inetref = inetrefEdit.text;
        metadata.studio = studioEdit.text;
        metadata.coverart = coverartEdit.text;
        metadata.fanart = fanartEdit.text;
        metadata.banner = bannerEdit.text;
        metadata.screenshot = screenshotEdit.text;

        metadata.channum = channumEdit.text;
        metadata.callsign = callsignEdit.text;
        metadata.startts = starttsEdit.text;
        metadata.releasedate = releasedateEdit.text;
        metadata.runtime = runtimeEdit.text;
        metadata.runtimesecs = runtimesecEdit.text;

        var xmlFile = Util.removeExtension(videoFilename) + ".mxml";
        mythUtils.writeMetadataXML(xmlFile, metadata);

        saved();
    }

    function checkedValue(value, defaultValue)
    {
        if (value === undefined )
            return defaultValue;

        return value;
    }

//    function findImage(imageFilename, type)
//    {
//        console.log("looking for image: " + imageFilename + ", type is: " + type);

//        var defaultImage = mythUtils.findThemeFile("images/grid_noimage.png");

//        // if no filename given use a default icon
//        if (imageFilename === "")
//            return defaultImage;

//        // if we are given a local file try that
//        if (imageFilename.startsWith("file://"))
//        {
//            if (mythUtils.fileExists(imageFilename.replace("file://", "")))
//                return imageFilename;
//            else
//                return defaultImage;
//        }

//        // if we have an http URL use that
//        if (imageFilename.startsWith("http://") || imageFilename.startsWith("https://"))
//            return imageFilename;

//        // if we just have a filename it could be a local file or myth storage group image
//        var path = Util.getPath(videoFilename);
//        var fullPath = path + "/" + imageFilename;

//        console.log("only got file name so looking for local file: " + fullPath)
//        console.log("videoFilename: " + videoFilename + ", path: " + path)

//        if (mythUtils.fileExists(fullPath))
//            return fullPath;

//        // assume it must be a myth storage group image
//        if (type === "screenshot")
//            return settings.masterBackend + "Content/GetImageFile?StorageGroup=Screenshot&FileName=" + imageFilename

//        if (type === "banner")
//            return settings.masterBackend + "Content/GetImageFile?StorageGroup=Banner&FileName=" + imageFilename

//        if (type === "fanart")
//            return settings.masterBackend + "Content/GetImageFile?StorageGroup=Fanart&FileName=" + imageFilename

//        if (type === "coverart")
//            return settings.masterBackend + "Content/GetImageFile?StorageGroup=Coverart&FileName=" + imageFilename

//        // if we get here just use the default icon
//        return defaultImage;
//    }

}
