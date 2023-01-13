import QtQuick 2.0

//pragma Singleton

QtObject
{
    id: root

    // screen background
    property string backgroundImage: "background.png"
    property var    backgroundVideo:  undefined
    property bool   backgroundSnow: false

    property var    backgroundSlideShow:
    ListModel
    {
        property double version: 1.0
        property string filename: "Halloween.tar.gz"
        property string md5: "78fc4ed838b753c3b90344a7330b1116"
        property double size: 37.8

        ListElement
        {
            url: "https://mythqml.net/downloads/themes/SlideShowHALLOWEEN/Halloween.tar.gz.part01";
            size: 25.0
        }
        ListElement
        {
            url: "https://mythqml.net/downloads/themes/SlideShowHALLOWEEN/Halloween.tar.gz.part02";
            size: 12.8
        }
    }

    // radio stream list
    property ListModel radioStreams:
    ListModel
    {
        ListElement
        {
            title: "Halloween Village";
            url: "Halloween_Village.mp3";
            logo: "snapshot056.png"
        }
        ListElement
        {
            title: "Haunted House";
            url: "Haunted_House.mp3";
            logo: "snapshot055.png"
        }
    }

    // main menu font
    property string menuFontFamily:     "Liberation Sans"
    property int    menuFontPixelSize:  30
    property bool   menuFontBold:       true
    property color  menuFontColor:      "orange"
    property real   menuShadowAlpha:    100 / 255
    property color  menuShadowColor:    "#000000"
    property int    menuShadowXOffset:  3
    property int    menuShadowYOffset:  3

    // title text
    property string titleFontFamily:     "Liberation Sans"
    property int    titleFontPixelSize:  30
    property bool   titleFontBold:       true
    property color  titleFontColor:      "purple"
    property real   titleShadowAlpha:    100 / 255
    property color  titleShadowColor:    "#000000"
    property int    titleShadowXOffset:  3
    property int    titleShadowYOffset:  3

    // label text
    property string labelFontFamily:     "Droid Sans"
    property int    labelFontPixelSize:  20
    property bool   labelFontBold:       true
    property color  labelFontColor:      "purple"
    property real   labelShadowAlpha:    100 / 255
    property color  labelShadowColor:    "#000000"
    property int    labelShadowXOffset:  2
    property int    labelShadowYOffset:  2

    // info text
    property string infoFontFamily:     "Liberation Sans"
    property int    infoFontPixelSize:  20
    property bool   infoFontBold:       false
    property color  infoFontColor:      "orange"
    property real   infoShadowAlpha:    100 / 255
    property color  infoShadowColor:    "#000000"
    property int    infoShadowXOffset:  0
    property int    infoShadowYOffset:  0

    // clock text
    property string clockFontFamily:     "Liberation Sans"
    property int    clockFontPixelSize:  28
    property bool   clockFontBold:       false
    property color  clockFontColor:      "gold"
    property real   clockShadowAlpha:    100 / 255
    property color  clockShadowColor:    "#000000"
    property int    clockShadowXOffset:  2
    property int    clockShadowYOffset:  2

    // base backgound
    property color bgColor:       "#78330000"
    property real  bgOpacity:     1.0
    property color bgBorderColor: "purple"
    property int   bgBorderWidth: 2
    property int   bgRadius:      12

    // base dialog background
    property color bgDialogColor:       "black"
    property real  bgDialogOpacity:     200 / 255
    property color bgDialogBorderColor: "purple"
    property int   bgDialogBorderWidth: 3
    property int   bgDialogRadius:      12

    // list view
    property color lvRowBackgroundNormal:          "#40111111"; // not selected or focused
    property color lvRowBackgroundFocused:         "#80111111"; // focused
    property color lvRowBackgroundSelected:        "#4000aa00"; // selected not focused
    property color lvRowBackgroundFocusedSelected: "#d000aa00"; // selected and focused

    property color lvRowTextNormal:          "#ffffffff"; // not selected or focused
    property color lvRowTextFocused:         "#ffffffff"; // focused
    property color lvRowTextSelected:        "#ffffa700"; // selected not focused
    property color lvRowTextFocusedSelected: "#ffffa700"; // selected and focused

    property real  lvBackgroundOpacity:      1.0;
    property color lvBackgroundBorderColor:  "green";
    property int   lvBackgroundBorderWidth:  2;
    property int   lvBackgroundBorderRadius: 10;

    // button
    property int   btBorderWidth: 3
    property int   btBorderRadius: 4

    property color btBorderColorNormal:          "#008c00"
    property color btBorderColorFocused:         "#00a500"
    property color btBorderColorSelected:        "#00d500"
    property color btBorderColorFocusedSelected: "#00f500"
    property color btBorderColorDisabled:        "#aaaaaa"

    property color btTextColorNormal:          "#ff8800"
    property color btTextColorFocused:         "#ffaa00"
    property color btTextColorSelected:        "#ffdd00"
    property color btTextColorFocusedSelected: "#ffff00"
    property color btTextColorDisabled:        "#888888"

    // text edit
    property color txTextColorNormal:            "#101010"
    property color txTextColorFocused:           "#000000"
    property color txTextBackgroundColorNormal:  "#a8ffffff"
    property color txTextBackgroundColorFocused: "#c8ffffff"

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

    function realPixels (size)
    {
        return (size * Screen.devicePixelRatio);
    }

    function iconSize (size) 
    {
        var tmp = (size || 1.0);
        return realPixels (tmp * 24);
    }

    function gray (val)
    {
        var tmp = (val / 255);
        return Qt.rgba (tmp, tmp, tmp, 1.0);
    }

    function opacify (tint, alpha)
    {
        var tmp = Qt.darker (tint, 1.0);
        return Qt.rgba (tmp.r, tmp.g, tmp.b, alpha);
    }

    function isDark (color)
    {
        var tmp = Qt.darker (color, 1.0);
        return (((tmp.r + tmp.g + tmp.b) / 3) < 0.5);
    }

    function selectFont (list, fallback)
    {
        var ret;
        var all = Qt.fontFamilies ();
        for (var idx = 0; idx < list.length; idx++)
        {
            var tmp = list [idx];
            if (all.indexOf (tmp) >= 0)
            {
                ret = tmp;
                break;
            }
        }
        return (ret || fallback);
    }

    function clamp (val, bound1, bound2)
    {
        var min = Math.min (bound1, bound2);
        var max = Math.max (bound1, bound2);
        return (val > max ? max : (val < min ? min : val));
    }

    function convert (srcVal, srcMin, srcMax, dstMin, dstMax)
    {
        var srcRatio = ((srcVal - srcMin) / (srcMax - srcMin));
        return clamp ((dstMin + ((dstMax - dstMin) * srcRatio)), dstMin, dstMax);
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
