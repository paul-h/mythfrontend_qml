import QtQuick 2.0

ListModel
{
    id: musicMenu
    property string logo: "title/title_info_center.png"
    property string title: "Energy Consumption Menu"

    ListElement
    {
        menutext: "Daily Energy Charts"
        loaderSource: "DailyEnergyConsumption.qml"
        waterMark: "watermark/energy_consumption.png"
    }
    ListElement
    {
        menutext: "Monthly Energy Charts"
        loaderSource:"EnergyConsumption.qml"
        waterMark: "watermark/energy_consumption.png"
    }
    ListElement
    {
        menutext: "Energy Bill Viewer"
        loaderSource:"EnergyBills.qml"
        waterMark: "watermark/energy_consumption.png"
    }
}
