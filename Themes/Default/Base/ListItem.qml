import QtQuick 2.0

Item
{
    id: root

    width: ListView.view.width
    height: yscale(50)
    property bool selected: ListView.isCurrentItem
    property bool focused: ListView.view.focus
}
