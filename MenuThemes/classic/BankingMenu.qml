import QtQuick 2.0

ListModel
{
    id: musicMenu
    property string logo: "title/title_info_center.png"
    property string title: "Energy Consumption Menu"

    ListElement
    {
        menutext: "Banking Viewer"
        loaderSource:"BankingViewer.qml"
        waterMark: "watermark/banking.png"
    }
    ListElement
    {
        menutext: "Bank Statements"
        loaderSource:"BankStatements.qml"
        waterMark: "watermark/banking.png"
    }
}
