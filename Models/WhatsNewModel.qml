import QtQuick 2.0
import QtQuick.XmlListModel 2.0

XmlListModel
{
    id: whatsNewModel

    signal loaded();

    source: "http://pdh.hopto.org:4549/downloads/whatsnew.xml"

    query: "/items/item"
    XmlRole { name: "id"; query: "id/number()" }
    XmlRole { name: "minversion"; query: "minversion/string()" }
    XmlRole { name: "title"; query: "title/string()" }
    XmlRole { name: "date"; query: "date/string()" }
    XmlRole { name: "url"; query: "url/string()" }

    onStatusChanged:
    {
        if (status == XmlListModel.Ready)
        {
            loaded();
            return;
        }

        if (status === XmlListModel.Error)
            console.info("WhatsNewModel - ERROR: " + errorString() + "\n" + source.toString());
    }
}
