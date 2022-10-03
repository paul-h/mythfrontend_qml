import QtQuick 2.0
import Base 1.0
import Models 1.0

BaseScreen
{
    defaultFocusItem: currentConditionsEdit

    Component.onCompleted:
    {
        showTitle(true, "Weather Settings");
        setHelp("https://mythqml.net/help/settings_weather.php#top");
        showTime(true);
        showTicker(false);
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
        }
        else if (event.key === Qt.Key_F4)
        {
            // BLUE - help
            window.showHelp();
        }
        else
            event.accepted = false;
    }

    LabelText
    {
        x: xscale(30); y: yscale(100)
        text: "Current Conditions:"
    }

    BaseEdit
    {
        id: currentConditionsEdit
        x: xscale(300); y: yscale(100)
        width: parent.width - x - xscale(80)
        height: yscale(50)
        text: settings.weatherCurrentConditions
        KeyNavigation.up: saveButton
        KeyNavigation.down: bbcForecastEdit
    }

    //
    LabelText
    {
        x: xscale(30); y: yscale(150)
        text: "BBC Forecast:"
    }

    BaseEdit
    {
        id: bbcForecastEdit
        x: xscale(300); y: yscale(150)
        width: parent.width - x - xscale(80)
        height: yscale(50)
        text: settings.weatherBBCForecast
        KeyNavigation.up: currentConditionsEdit
        KeyNavigation.down: metOfficeForecastEdit
    }

    LabelText
    {
        x: xscale(30); y: yscale(200)
        text: "Met Office Forecast:"
    }

    BaseEdit
    {
        id: metOfficeForecastEdit
        x: xscale(300); y: yscale(200)
        width: parent.width - x - xscale(80)
        height: yscale(50)
        text: settings.weatherMetOfficeForecast
        KeyNavigation.up: bbcForecastEdit
        KeyNavigation.down: lightningMapEdit
    }

    LabelText
    {
        x: xscale(30); y: yscale(250)
        text: "Lightning Map:"
    }

    BaseEdit
    {
        id: lightningMapEdit
        x: xscale(300); y: yscale(250)
        width: parent.width - x - xscale(80)
        height: yscale(50)
        text: settings.weatherLightningMap
        KeyNavigation.up: metOfficeForecastEdit
        KeyNavigation.down: rainRadarEdit
    }

    LabelText
    {
        x: xscale(30); y: yscale(300)
        text: "Rain Radar:"
    }

    BaseEdit
    {
        id: rainRadarEdit
        x: xscale(300); y: yscale(300)
        width: parent.width - x - xscale(80)
        height: yscale(50)
        text: settings.weatherRainRadar
        KeyNavigation.up: lightningMapEdit
        KeyNavigation.down: videoForecastEdit
    }

    LabelText
    {
        x: xscale(30); y: yscale(350)
        text: "Met Office Video Forecast:"
    }

    BaseEdit
    {
        id: videoForecastEdit
        x: xscale(300); y: yscale(350)
        width: parent.width - x - xscale(80)
        height: yscale(50)
        text: settings.weatherVideoForecast
        KeyNavigation.up: rainRadarEdit
        KeyNavigation.down: saveButton
    }

    BaseButton
    {
        id: saveButton;
        x: parent.width - width - xscale(50); y: yscale(620);
        text: "Save";
        KeyNavigation.up: videoForecastEdit
        KeyNavigation.down: currentConditionsEdit
        onClicked: save()
    }

    Footer
    {
        id: footer
        redText: "Cancel"
        greenText: "Save"
        yellowText: ""
        blueText: "Help"
    }

    function save()
    {
        dbUtils.setSetting("WeatherCurrentConditions", settings.hostName, currentConditionsEdit.text);
        dbUtils.setSetting("WeatherBBCForecast",       settings.hostName, bbcForecastEdit.text);
        dbUtils.setSetting("WeatherMetOfficeForecast", settings.hostName, metOfficeForecastEdit.text);
        dbUtils.setSetting("WeatherLightningMap",      settings.hostName, lightningMapEdith.text);
        dbUtils.setSetting("WeatherRainRadar",         settings.hostName, rainRadarEdit.text);
        dbUtils.setSetting("WeatherVideoForecast",     settings.hostName, videoForecastEdit.text);

        settings.weatherCurrentConditions = currentConditionsEdit.text;
        settings.weatherBBCForecast       = bbcForecastEdit.text;
        settings.weatherMetOfficeForecast = metOfficeForecastEdit.text;
        settings.weatherLightningMap      = lightningMapEdith.text;
        settings.weatherRainRadar         = rainRadarEdit.text;
        settings.weatherVideoForecast     = videoForecastEdit.text;

        returnSound.play();
        stack.pop();
    }
}
