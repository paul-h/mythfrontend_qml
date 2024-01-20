import QtQuick 2.7
import QtCharts 2.15
import Base 1.0
import Dialogs 1.0
import Models 1.0
import FileIO 1.0
import "../../../Util.js" as Util

BaseScreen
{
    defaultFocusItem: chartView

    property int monthIdx: 0
    property string fuel: "Both"
    property string show: "Cost"

    Component.onCompleted:
    {
        showTitle(true, "Electric and Gas Cost and Usage");
        showTime(true);
        showTicker(false);
        muteAudio(true);

        // show current month by default
        var currentDate = new Date();
        monthIdx = currentDate.getMonth();

        loadData(monthIdx + 1);
    }

    Keys.onPressed:
    {
        event.accepted = true;

        if (event.key === Qt.Key_F1)
        {
            // RED - previous month
            returnSound.play();
            if (monthIdx === 0)
                monthIdx = 11;
            else
                monthIdx--;

            loadData(monthIdx + 1);
        }
        else if (event.key === Qt.Key_F2)
        {
            // GREEN - next month
            returnSound.play();
            if (monthIdx === 11)
                monthIdx = 0;
            else
                monthIdx++;

            loadData(monthIdx + 1);
        }
        else if (event.key === Qt.Key_F3)
        {
            // YELLOW - fuel
            if (fuel === "Electric")
                fuel = "Gas";
            else if (fuel === "Gas")
                fuel = "Both";
            else if (fuel === "Both")
                fuel = "Electric";

            footer.yellowText = "Showing (" + fuel + ")";

            loadData(monthIdx + 1);
        }
        else if (event.key === Qt.Key_F4)
        {
            // BLUE - showing
            if (show === "Cost")
                show = "Energy";
            else
                show = "Cost";

            footer.blueText = "Showing (" + show + ")";

            loadData(monthIdx + 1);

        }
        else
            event.accepted = false;
    }

    FileIO
    {
        id: jsonFile
        source: ""
        onError: console.log(msg)
    }

    JSONListModel
    {
        id: usageData2020Model

        query: "$.data.consumptionRange[*]"

        onLoaded:
        {
            if (fuel === "Electric")
            {
                if (show === "Cost")
                {
                    valueAxis.titleText = "Electric Cost (£)"
                    title.text = "Electric cost for "  + Util.monthToString(monthIdx);
                }
                else
                {
                    valueAxis.titleText = "Electric Usage (kWh)"
                    title.text = "Electric usage for "  + Util.monthToString(monthIdx);
                }
            }
            else if (fuel === "Gas")
            {
                if (show === "Cost")
                {
                    valueAxis.titleText = "Gas Cost (£)"
                    title.text = "Gas cost for "  + Util.monthToString(monthIdx);
                }
                else
                {
                    valueAxis.titleText = "Gas Usage (kWh)"
                    title.text = "Gas usage for "  + Util.monthToString(monthIdx);
                }
            }
            else if (fuel === "Both")
            {
                if (show === "Cost")
                {
                    valueAxis.titleText = "Gas/Electric Cost (£)"
                    title.text = "Gas and Electric cost for "  + Util.monthToString(monthIdx);
                }
                else
                {
                    valueAxis.titleText = "Gas/Electric Usage (kWh)"
                    title.text = "Gas and Electric usage for "  + Util.monthToString(monthIdx);
                }
            }

            chartView.title = "Energy Usage for " + Util.monthToString(monthIdx) + " (" + fuel + ")";

            var day = 1;
            var total = 0;

            year2020Set.remove(0, year2020Set.count);

            for (var x = 0; x < model.count; x++)
            {
                if ((model.get(x).fuel === "gas" && fuel === "Gas") || (model.get(x).fuel === "electricity" && fuel === "Electric") || (model.get(x).fuel === "total" && fuel === "Both"))
                {
                    // Set the x-axis labels to the dates of the usage data
                    var xLabels = dateAxis.categories;
                    xLabels[Number(day)] = day ;
                    dateAxis.categories = xLabels;
                    dateAxis.visible = true;
                    dateAxis.min = 0;
                    dateAxis.max = xLabels.length;

                    var value = 0
                    if (show === "Cost")
                        value = model.get(x).cost;
                    else
                        value = model.get(x).energy;

                    total += value;

                    valueAxis.max = Math.max(valueAxis.max, value);

                    year2020Set.append(value);

                    day++;
                }
            }

            if (show === "Cost")
                total2020.text = "2020 Total: £" + total.toFixed(2);
            else
                total2020.text = "2020 Total: " + total.toFixed(2) + "kWh";
        }
    }

    JSONListModel
    {
        id: usageData2021Model

        query: "$.data.consumptionRange[*]"

        onLoaded:
        {
            var total = 0;

            year2021Set.remove(0, year2021Set.count);

            for (var x = 0; x < model.count; x++)
            {
                if ((model.get(x).fuel === "gas" && fuel === "Gas") || (model.get(x).fuel === "electricity" && fuel === "Electric") || (model.get(x).fuel === "total" && fuel === "Both"))
                {
                    var value = 0
                    if (show === "Cost")
                        value = model.get(x).cost;
                    else
                        value = model.get(x).energy;

                    valueAxis.max = Math.max(valueAxis.max, value);

                    total += value;

                    year2021Set.append(value);
                }
            }

            if (show === "Cost")
                total2021.text = "2021 Total: £" + total.toFixed(2);
            else
                total2021.text = "2021 Total: " + total.toFixed(2) + "kWh";
        }
    }

    JSONListModel
    {
        id: usageData2022Model

        query: "$.data.consumptionRange[*]"

        onLoaded:
        {
            var total = 0;

            year2022Set.remove(0, year2022Set.count);

            for (var x = 0; x < model.count; x++)
            {
                if ((model.get(x).fuel === "gas" && fuel === "Gas") || (model.get(x).fuel === "electricity" && fuel === "Electric") || (model.get(x).fuel === "total" && fuel === "Both"))
                {
                    var value = 0
                    if (show === "Cost")
                        value = model.get(x).cost;
                    else
                        value = model.get(x).energy;

                    valueAxis.max = Math.max(valueAxis.max, value);

                    total += value;

                    year2022Set.append(value);
                }
            }

            if (show === "Cost")
                total2022.text = "2022 Total: £" + total.toFixed(2);
            else
                total2022.text = "2022 Total: " + total.toFixed(2) + "kWh";
        }
    }

    JSONListModel
    {
        id: usageData2023Model

        query: "$.data.consumptionRange[*]"

        onLoaded:
        {
            var total = 0;

            year2023Set.remove(0, year2023Set.count);

            for (var x = 0; x < model.count; x++)
            {
                if ((model.get(x).fuel === "gas" && fuel === "Gas") || (model.get(x).fuel === "electricity" && fuel === "Electric") || (model.get(x).fuel === "total" && fuel === "Both"))
                {
                    var value = 0
                    if (show === "Cost")
                        value = model.get(x).cost;
                    else
                        value = model.get(x).energy;

                    valueAxis.max = Math.max(valueAxis.max, value);

                    total += value;

                    year2023Set.append(value);
                }
            }

            if (show === "Cost")
                total2023.text = "2023 Total: £" + total.toFixed(2);
            else
                total2023.text = "2023 Total: " + total.toFixed(2) + "kWh";
        }
    }

    JSONListModel
    {
        id: usageData2024Model

        query: "$.data.consumptionRange[*]"

        onLoaded:
        {
            var total = 0;

            year2024Set.remove(0, year2024Set.count);

            for (var x = 0; x < model.count; x++)
            {
                if ((model.get(x).fuel === "gas" && fuel === "Gas") || (model.get(x).fuel === "electricity" && fuel === "Electric") || (model.get(x).fuel === "total" && fuel === "Both"))
                {
                    var value = 0
                    if (show === "Cost")
                        value = model.get(x).cost;
                    else
                        value = model.get(x).energy;

                    valueAxis.max = Math.max(valueAxis.max, value);

                    total += value;

                    year2024Set.append(value);
                }
            }

            if (show === "Cost")
                total2024.text = "2024 Total: £" + total.toFixed(2);
            else
                total2024.text = "2024 Total: " + total.toFixed(2) + "kWh";
        }
    }

    LabelText
    {
        id: title
        x: (parent.width / 2) - (width / 2)
        y: yscale(40)
        width: xscale(1000)
        height: yscale(50)
        horizontalAlignment: Text.AlignHCenter
        fontPixelSize: xscale(25)
        text: "Electric cost for January"
    }

    InfoText
    {
        id: total2020
        x: xscale(40)
        y: yscale(75)
        width: xscale(240)
        height: yscale(50)
        text: ""
    }

    InfoText
    {
        id: total2021
        x: xscale(280)
        y: yscale(75)
        width: xscale(240)
        height: yscale(50)
        horizontalAlignment: Text.AlignHCenter
        text: ""
    }

    InfoText
    {
        id: total2022
        x: xscale(520)
        y: yscale(75)
        width: xscale(240)
        height: yscale(50)
        horizontalAlignment: Text.AlignHCenter
        text: ""
    }

    InfoText
    {
        id: total2023
        x: xscale(760)
        y: yscale(75)
        width: xscale(240)
        height: yscale(50)
        horizontalAlignment: Text.AlignRight
        text: ""
    }

    InfoText
    {
        id: total2024
        x: xscale(1000)
        y: yscale(75)
        width: xscale(240)
        height: yscale(50)
        horizontalAlignment: Text.AlignRight
        text: ""
    }

    ChartView
    {
        id: chartView
        title: "Energy Usage for January 2020"
        titleFont: Qt.font({pointSize: xscale(12), bold:true});
        titleColor: "magenta"
        x: xscale(10)
        y: yscale(130)
        width: parent.width - xscale(20)
        height: parent.height / 4 * 3
        legend.alignment: Qt.AlignTop
        antialiasing: true
        animationOptions: ChartView.NoAnimation; // AllAnimations

        BarCategoryAxis
        {
            id: dateAxis
            titleText: "Date"
            titleFont: Qt.font({pointSize: xscale(10), bold: false});
            labelsFont: Qt.font({pointSize: xscale(10), bold: false});
        }

        ValueAxis
        {
            id: valueAxis
            min: 0
            max: 1
            titleText: "Electric [£]"
            titleFont: Qt.font({pointSize: xscale(10), bold:false});
            labelsFont: Qt.font({pointSize: xscale(10), bold: false});
        }

        BarSeries
        {
            id: myBarSeries
            axisX: dateAxis
            axisY: valueAxis
            labelsAngle: 270
            labelsVisible: true
            labelsPosition: AbstractBarSeries.LabelsCenter
            barWidth: 0.7

            BarSet
            {
                id: year2020Set
                label: "2020"
                labelFont: Qt.font({pointSize: xscale(6), bold: true});
                labelColor: "dark blue"
            }
            BarSet
            {
                id: year2021Set
                label: "2021"
                labelFont: Qt.font({pointSize: xscale(6), bold: true});
                labelColor: "dark blue"
            }
            BarSet
            {
                id: year2022Set
                label: "2022"
                labelFont: Qt.font({pointSize: xscale(6), bold: true});
                labelColor: "dark blue"
            }
            BarSet
            {
                id: year2023Set
                label: "2023"
                labelFont: Qt.font({pointSize: xscale(6), bold: true});
                labelColor: "dark blue"
            }
            BarSet
            {
                id: year2024Set
                label: "2024"
                labelFont: Qt.font({pointSize: xscale(6), bold: true});
                labelColor: "dark blue"
            }
        }
    }

    Footer
    {
        id: footer
        redText: "Previous Month"
        greenText: "Next Month"
        yellowText: "Fuel (Both)"
        blueText: "Showing (Cost)"
    }

    function loadData(month)
    {
        usageData2020Model.json = "";
        usageData2021Model.json = "";
        usageData2022Model.json = "";
        usageData2023Model.json = "";
        usageData2024Model.json = "";

        year2020Set.remove(0, year2020Set.count);
        year2021Set.remove(0, year2021Set.count);
        year2022Set.remove(0, year2022Set.count);
        year2023Set.remove(0, year2023Set.count);
        year2024Set.remove(0, year2024Set.count);

        total2020.text = "2020 Total: N/A";
        total2021.text = "2021 Total: N/A";
        total2022.text = "2022 Total: N/A";
        total2023.text = "2023 Total: N/A";
        total2024.text = "2024 Total: N/A";

        dateAxis.clear();
        valueAxis.max = 1;

        // load 2020
        jsonFile.source = settings.energyDataDir + "/2020_" + (month < 10 ? "0" : "") + month +".json";
        var json = jsonFile.read();
        json = json.replace(/"tou": null/g, '"tou": false');
        json = json.replace(/: null/g, ':""');
        usageData2020Model.json = json;

        // load 2021
        jsonFile.source = settings.energyDataDir + "/2021_" + (month < 10 ? "0" : "") + month +".json";
        json = jsonFile.read();
        json = json.replace(/"tou": null/g, '"tou": false');
        json = json.replace(/: null/g, ':""');
        usageData2021Model.json = json;

        // load 2022
        jsonFile.source = settings.energyDataDir + "/2022_" + (month < 10 ? "0" : "") + month +".json";
        json = jsonFile.read();
        json = json.replace(/"tou": null/g, '"tou": false');
        json = json.replace(/: null/g, ':""');
        usageData2022Model.json = json;

        // load 2023
        jsonFile.source = settings.energyDataDir + "/2023_" + (month < 10 ? "0" : "") + month +".json";
        json = jsonFile.read();
        json = json.replace(/"tou": null/g, '"tou": false');
        json = json.replace(/: null/g, ':""');
        usageData2023Model.json = json;

        // load 2024
        jsonFile.source = settings.energyDataDir + "/2024_" + (month < 10 ? "0" : "") + month +".json";
        json = jsonFile.read();
        json = json.replace(/"tou": null/g, '"tou": false');
        json = json.replace(/: null/g, ':""');
        usageData2024Model.json = json;
    }
}
