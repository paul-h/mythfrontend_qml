import QtQuick

//pragma Singleton

QtObject
{
    id: root

    // screen background
    property string   backgroundImage:  "background.png"

    property var backgroundVideo:
    ListModel
    {
        property string filename: "mythcenterng.mp4"
        property string md5: "7afa15cf46bf5b130e65af3363aa5ced"
        property double size: 124.9

        ListElement
        {
            url: "https://mythqml.net/downloads/themes/MythCenterNG/mythcenterng.mp4";
            size: 124.9
        }
    }

    property var backgroundSlideShow: undefined

    // main menu font
    property string menuFontFamily:     "Liberation Sans"
    property int    menuFontPixelSize:  30
    property bool   menuFontBold:       true
    property color  menuFontColor:      "white"
    property real   menuShadowAlpha:    100 / 255
    property color  menuShadowColor:    "#000000"
    property int    menuShadowXOffset:  2
    property int    menuShadowYOffset:  2

    // title text
    property string titleFontFamily:     "Liberation Sans"
    property int    titleFontPixelSize:  30
    property bool   titleFontBold:       true
    property color  titleFontColor:      "#00ff00"
    property real   titleShadowAlpha:    100 / 255
    property color  titleShadowColor:    "#000000"
    property int    titleShadowXOffset:  2
    property int    titleShadowYOffset:  2

    // label text
    property string labelFontFamily:     "Droid Sans"
    property int    labelFontPixelSize:  20
    property bool   labelFontBold:       true
    property color  labelFontColor:      "#ff00ff"
    property real   labelShadowAlpha:    100 / 255
    property color  labelShadowColor:    "#000000"
    property int    labelShadowXOffset:  1
    property int    labelShadowYOffset:  0

    // recording text
    property color  recordingFontColor: "#00ff00"

    // info text
    property string infoFontFamily:     "Liberation Sans"
    property int    infoFontPixelSize:  20
    property bool   infoFontBold:       false
    property color  infoFontColor:      "#ffffff"
    property real   infoShadowAlpha:    100 / 255
    property color  infoShadowColor:    "#000000"
    property int    infoShadowXOffset:  0
    property int    infoShadowYOffset:  0

    // clock text
    property string clockFontFamily:     "Liberation Sans"
    property int    clockFontPixelSize:  25
    property bool   clockFontBold:       false
    property color  clockFontColor:      "#00ff00"
    property real   clockShadowAlpha:    100 / 255
    property color  clockShadowColor:    "#000000"
    property int    clockShadowXOffset:  1
    property int    clockShadowYOffset:  1

    // base background
    property color bgColor:       "#000000"
    property real  bgOpacity:     120 / 255
    property color bgBorderColor: "#ffffffff"
    property int   bgBorderWidth: 2
    property int   bgRadius:      12

    // base dialog background
    property color bgDialogColor:       "#000020"
    property real  bgDialogOpacity:     230 / 255
    property color bgDialogBorderColor: "#aa00ff00"
    property int   bgDialogBorderWidth: 3
    property int   bgDialogRadius:      12

    // list view
    property color lvRowBackgroundNormal:          "#20000000"; // not selected or focused
    property color lvRowBackgroundFocused:         "#20000000"; // focused
    property color lvRowBackgroundSelected:        "#2000aa00"; // selected not focused
    property color lvRowBackgroundFocusedSelected: "#8000aa00"; // selected and focused

    property color lvRowTextNormal:          "#80ffffff"; // not selected or focused
    property color lvRowTextFocused:         "#a0ffffff"; // focused
    property color lvRowTextSelected:        "#80ffffff"; // selected not focused
    property color lvRowTextFocusedSelected: "#ffffffff"; // selected and focused

    property real  lvBackgroundOpacity:      1.0;
    property color lvBackgroundBorderColor:  "green";
    property int   lvBackgroundBorderWidth:  4;
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
    property string txFontFamily:                 "Liberation Sans"
    property int    txFontPixelSize:              20
    property bool   txFontBold:                   false
    property color  txTextColorNormal:            "#101010"
    property color  txTextColorFocused:           "#000000"
    property color  txTextBackgroundColorNormal:  "#a8ffffff"
    property color  txTextBackgroundColorFocused: "#c8ffffff"

    // ticker text
    property color tiTextColor:       "green"
    property color tiBackgroundColor: "#88101010"

    readonly property color colorDumb : "#FF00FF"; // magenta
    readonly property color colorNone : "transparent";

    // background gradients
    property color colorNormalStart: "#7800aa00"
    property color colorNormalStop:  "#78008800"

    property color colorFocusedStart: "#c800ff00"
    property color colorFocusedStop:  "#c800dd00"

    property color colorSelectedStart: "#c800ff00"
    property color colorSelectedStop:  "#c800dd00"

    property color colorFocusedSelectedStart: "#c800ff00"
    property color colorFocusedSelectedStop:  "#c800ff00"

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

    function generateGradient (template)
    {
        return template.createObject (_garbage_);
    }

    // not selected not focused
    function gradientNormal()
    {
        return generateGradient(templateGradientNormal);
    }

    // not selected has focus
    function gradientFocused()
    {
        return generateGradient(templateGradientFocused);
    }

    // is selected not focused
    function gradientSelected()
    {
        return generateGradient(templateGradientSelected);
    }

    // is selected has focus
    function gradientFocusedSelected()
    {
        return generateGradient (templateGradientFocusedSelected);
    }

    // disabled
    function gradientDisabled()
    {
        return generateGradient (templateGradientDisabled);
    }

    function gradientShaded (baseColorTop, baseColorBottom)
    {
        return templateGradientShaded.createObject (_garbage_, { "baseColorTop" : (baseColorTop || colorHighlight), "baseColorBottom" : (baseColorBottom || colorWindow), });
    }
}
