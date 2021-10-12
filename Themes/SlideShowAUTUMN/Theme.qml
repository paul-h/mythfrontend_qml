import QtQuick 2.0

//pragma Singleton

QtObject
{
    id: root

    // screen background
    property string backgroundImage: "background.png"
    property var    backgroundVideo:  undefined

    property var    backgroundSlideShow:
    ListModel
    {
        property string filename: "Autumn.tar.gz"
        property string md5: "0f4a669b4697fb99dd822ee0908b6aa9"
        property double size: 539.0

        ListElement
        {
            url: "https://mythqml.net/downloads/themes/SlideShowAUTUMN/Autumn.tar.gz.part01";
            size: 25.0
        }
        ListElement
        {
            url: "https://mythqml.net/downloads/themes/SlideShowAUTUMN/Autumn.tar.gz.part02";
            size: 25.0
        }
        ListElement
        {
            url: "https://mythqml.net/downloads/themes/SlideShowAUTUMN/Autumn.tar.gz.part03";
            size: 25.0
        }
        ListElement
        {
            url: "https://mythqml.net/downloads/themes/SlideShowAUTUMN/Autumn.tar.gz.part04";
            size: 25.0
        }
        ListElement
        {
            url: "https://mythqml.net/downloads/themes/SlideShowAUTUMN/Autumn.tar.gz.part05";
            size: 25.0
        }
        ListElement
        {
            url: "https://mythqml.net/downloads/themes/SlideShowAUTUMN/Autumn.tar.gz.part06";
            size: 25.0
        }
        ListElement
        {
            url: "https://mythqml.net/downloads/themes/SlideShowAUTUMN/Autumn.tar.gz.part07";
            size: 25.0
        }
        ListElement
        {
            url: "https://mythqml.net/downloads/themes/SlideShowAUTUMN/Autumn.tar.gz.part08";
            size: 25.0
        }
        ListElement
        {
            url: "https://mythqml.net/downloads/themes/SlideShowAUTUMN/Autumn.tar.gz.part09";
            size: 25.0
        }
        ListElement
        {
            url: "https://mythqml.net/downloads/themes/SlideShowAUTUMN/Autumn.tar.gz.part10";
            size: 25.0
        }
        ListElement
        {
            url: "https://mythqml.net/downloads/themes/SlideShowAUTUMN/Autumn.tar.gz.part11";
            size: 25.0
        }
        ListElement
        {
            url: "https://mythqml.net/downloads/themes/SlideShowAUTUMN/Autumn.tar.gz.part12";
            size: 25.0
        }
        ListElement
        {
            url: "https://mythqml.net/downloads/themes/SlideShowAUTUMN/Autumn.tar.gz.part13";
            size: 25.0
        }
        ListElement
        {
            url: "https://mythqml.net/downloads/themes/SlideShowAUTUMN/Autumn.tar.gz.part14";
            size: 25.0
        }
        ListElement
        {
            url: "https://mythqml.net/downloads/themes/SlideShowAUTUMN/Autumn.tar.gz.part15";
            size: 25.0
        }
        ListElement
        {
            url: "https://mythqml.net/downloads/themes/SlideShowAUTUMN/Autumn.tar.gz.part16";
            size: 25.0
        }
        ListElement
        {
            url: "https://mythqml.net/downloads/themes/SlideShowAUTUMN/Autumn.tar.gz.part17";
            size: 25.0
        }
        ListElement
        {
            url: "https://mythqml.net/downloads/themes/SlideShowAUTUMN/Autumn.tar.gz.part18";
            size: 25.0
        }
        ListElement
        {
            url: "https://mythqml.net/downloads/themes/SlideShowAUTUMN/Autumn.tar.gz.part19";
            size: 25.0
        }
        ListElement
        {
            url: "https://mythqml.net/downloads/themes/SlideShowAUTUMN/Autumn.tar.gz.part20";
            size: 25.0
        }
        ListElement
        {
            url: "https://mythqml.net/downloads/themes/SlideShowAUTUMN/Autumn.tar.gz.part21";
            size: 25.0
        }
        ListElement
        {
            url: "https://mythqml.net/downloads/themes/SlideShowAUTUMN/Autumn.tar.gz.part22";
            size: 14.0
        }
    }

    // radio stream list
    property ListModel radioStreams:
    ListModel
    {
        ListElement
        {
            title: "Soothing Nature";
            url: "soothing_nature.mp3";
            logo: "snapshot101.png"
        }
        ListElement
        {
            title: "Relaxing Autumn";
            url: "relaxing_autumn.webm";
            logo: "snapshot102.png"
        }
        ListElement
        {
            title: "Classical Autumn";
            url: "classical_autumn.mp3";
            logo: "snapshot103.png"
        }
        ListElement
        {
            title: "Piano Autumn";
            url: "piano_autumn.webm";
            logo: "snapshot104.png"
        }
    }

    // main menu font
    property string menuFontFamily:     "Liberation Sans"
    property int    menuFontPixelSize:  30
    property bool   menuFontBold:       true
    property color  menuFontColor:      "orange"
    property real   menuShadowAlpha:    100 / 255
    property color  menuShadowColor:    "#000000"
    property int    menuShadowXOffset:  2
    property int    menuShadowYOffset:  2

    // title text
    property string titleFontFamily:     "Liberation Sans"
    property int    titleFontPixelSize:  30
    property bool   titleFontBold:       true
    property color  titleFontColor:      "orangered"
    property real   titleShadowAlpha:    120 / 255
    property color  titleShadowColor:    "#000000"
    property int    titleShadowXOffset:  2
    property int    titleShadowYOffset:  2

    // label text
    property string labelFontFamily:     "Droid Sans"
    property int    labelFontPixelSize:  20
    property bool   labelFontBold:       true
    property color  labelFontColor:      "#7d280b"
    property real   labelShadowAlpha:    100 / 255
    property color  labelShadowColor:    "#000000"
    property int    labelShadowXOffset:  2
    property int    labelShadowYOffset:  2

    // recording text
    property color  recordingFontColor: "#00ff00"

    // info text
    property string infoFontFamily:     "Liberation Sans"
    property int    infoFontPixelSize:  20
    property bool   infoFontBold:       false
    property color  infoFontColor:      "gold"
    property real   infoShadowAlpha:    100 / 255
    property color  infoShadowColor:    "#000000"
    property int    infoShadowXOffset:  0
    property int    infoShadowYOffset:  0

    // clock text
    property string clockFontFamily:     "Liberation Sans"
    property int    clockFontPixelSize:  25
    property bool   clockFontBold:       false
    property color  clockFontColor:      "gold"
    property real   clockShadowAlpha:    100 / 255
    property color  clockShadowColor:    "#000000"
    property int    clockShadowXOffset:  1
    property int    clockShadowYOffset:  1

    // base background
    property color bgColor:       "#000000"
    property real  bgOpacity:     120 / 255
    property color bgBorderColor: "gold"
    property int   bgBorderWidth: 2
    property int   bgRadius:      12

    // base dialog background
    property color bgDialogColor:       "#000020"
    property real  bgDialogOpacity:     230 / 255
    property color bgDialogBorderColor: "#aaffa500"
    property int   bgDialogBorderWidth: 3
    property int   bgDialogRadius:      12

    // list view
    property color lvRowBackgroundNormal:          "#20000000"; // not selected or focused
    property color lvRowBackgroundFocused:         "#20000000"; // focused
    property color lvRowBackgroundSelected:        "#20cc7000"; // selected not focused
    property color lvRowBackgroundFocusedSelected: "#80cc7000"; // selected and focused

    property color lvRowTextNormal:          "#80ffa500"; // not selected or focused
    property color lvRowTextFocused:         "#a0ffa500"; // focused
    property color lvRowTextSelected:        "#80ffa500"; // selected not focused
    property color lvRowTextFocusedSelected: "#ffffa500"; // selected and focused

    property real  lvBackgroundOpacity:      1.0;
    property color lvBackgroundBorderColor:  "orangered";
    property int   lvBackgroundBorderWidth:  3;
    property int   lvBackgroundBorderRadius: 10;

    // button
    property int   btBorderWidth: 3
    property int   btBorderRadius: 4

    property color btBorderColorNormal:          "#888888"
    property color btBorderColorFocused:         "#aaaaaa"
    property color btBorderColorSelected:        "#dddddd"
    property color btBorderColorFocusedSelected: "#ffffff"
    property color btBorderColorDisabled:        "#aaaaaa"

    property color btTextColorNormal:          "#888888"
    property color btTextColorFocused:         "#aaaaaa"
    property color btTextColorSelected:        "#dddddd"
    property color btTextColorFocusedSelected: "#ffffff"
    property color btTextColorDisabled:        "#888888"

    // text edit
    property color txTextColorNormal:            "#101010"
    property color txTextColorFocused:           "#000000"
    property color txTextBackgroundColorNormal:  "#a8ffffff"
    property color txTextBackgroundColorFocused: "#c8ffffff"

    // ticker text
    property color tiTextColor:       "orange"
    property color tiBackgroundColor: "#88101010"

    readonly property color colorDumb : "#FF00FF"; // magenta
    readonly property color colorNone : "transparent";

    // background gradients
    property color colorNormalStart: "#78aa5000"
    property color colorNormalStop:  "#78883000"

    property color colorFocusedStart: "#c8ffa500"
    property color colorFocusedStop:  "#c8dd9300"

    property color colorSelectedStart: "#c8ffa500"
    property color colorSelectedStop:  "#c8dd9300"

    property color colorFocusedSelectedStart: "#c8ffa500"
    property color colorFocusedSelectedStop:  "#c8ffa500"

    property color colorDisabledStart: "#80cccccc"
    property color colorDisabledStop:  "#80111111"

    property Component templateGradientNormal :
    Component
    {
        Gradient
        {
            id: autogradient;
            property color baseColorTop : colorNormalStart;
            property color baseColorBottom : colorNormalStop;
            GradientStop
            {
                color: autogradient.baseColorTop;
                position: 0.0;
            }
            GradientStop
            {
                color: autogradient.baseColorBottom;
                position: 1.0;
            }
        }
    }

    property Component templateGradientFocused :
    Component
    {
        Gradient
        {
            id: autogradient;
            property color baseColorTop : colorFocusedStart;
            property color baseColorBottom : colorFocusedStop;
            GradientStop
            {
                color: autogradient.baseColorTop;
                position: 0.0;
            }
            GradientStop
            {
                color: autogradient.baseColorBottom;
                position: 1.0;
            }
        }
    }

    property Component templateGradientSelected :
    Component
    {
        Gradient
        {
            id: autogradient;
            property color baseColorTop : colorSelectedStart;
            property color baseColorBottom : colorSelectedStop;
            GradientStop
            {
                color: autogradient.baseColorTop;
                position: 0.0;
            }
            GradientStop
            {
                color: autogradient.baseColorBottom;
                position: 1.0;
            }
        }
    }

    property Component templateGradientFocusedSelected :
    Component
    {
        Gradient
        {
            id: autogradient;
            property color baseColorTop : colorFocusedSelectedStart;
            property color baseColorBottom : colorFocusedSelectedStop;
            GradientStop
            {
                color: autogradient.baseColorTop;
                position: 0.0;
            }
            GradientStop
            {
                color: autogradient.baseColorBottom;
                position: 1.0;
            }
        }
    }

    property Component templateGradientDisabled :
    Component
    {
        Gradient
        {
            id: autogradient;
            property color baseColorTop : colorDisabledStart;
            property color baseColorBottom : colorDisabledStop;
            GradientStop
            {
                color: autogradient.baseColorTop;
                position: 0.0;
            }
            GradientStop
            {
                color: autogradient.baseColorBottom;
                position: 1.0;
            }
        }
    }

    property Component templateGradientShaded :
    Component
    {
        Gradient
        {
            id: autogradient;
            property color baseColorTop : colorDumb;
            property color baseColorBottom : colorDumb;
            GradientStop
            {
                color: autogradient.baseColorTop;
                position: 0.0;
            }
            GradientStop
            {
                color: autogradient.baseColorBottom;
                position: 1.0;
            }
        }
    }

    property Item _garbage_ : Item { }

    function generateGradient (template, baseColor)
    {
        return template.createObject (_garbage_, { "baseColor" : baseColor });
    }

    // not selected not focused
    function gradientNormal(baseColorTop, baseColorBottom)
    {
        return generateGradient(templateGradientNormal, baseColorTop, baseColorBottom);
    }

    // not selected has focus
    function gradientFocused(baseColorTop, baseColorBottom)
    {
        return generateGradient(templateGradientFocused, baseColorTop, baseColorBottom);
    }

    // is selected not focused
    function gradientSelected(baseColorTop, baseColorBottom)
    {
        return generateGradient(templateGradientSelected, baseColorTop, baseColorBottom);
    }

    // is selected has focus
    function gradientFocusedSelected(baseColorTop, baseColorBottom)
    {
        return generateGradient (templateGradientFocusedSelected, baseColorTop, baseColorBottom);
    }

    // disabled
    function gradientDisabled (baseColorTop, baseColorBottom)
    {
        return generateGradient (templateGradientDisabled, baseColorTop, baseColorBottom);
    }

    function gradientShaded (baseColorTop, baseColorBottom)
    {
        return templateGradientShaded.createObject (_garbage_, { "baseColorTop" : (baseColorTop || colorHighlight), "baseColorBottom" : (baseColorBottom || colorWindow), });
    }
}
