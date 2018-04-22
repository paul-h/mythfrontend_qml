import QtQuick 2.0
import QtQuick.XmlListModel 2.0

XmlListModel
{
    id: mxmlModel
    source: ""
    query: "/metadata/item"
    XmlRole { name: "title"; query: "title/string()" }
    XmlRole { name: "description"; query: "description/string()" }
    XmlRole { name: "channum"; query: "channum/string()" }
    XmlRole { name: "chansign"; query: "chansign/string()" }
    XmlRole { name: "startts"; query: "startts/string()" }
    XmlRole { name: "releasedate"; query: "releasedate/string()" }
    XmlRole { name: "runtime"; query: "runtime/string()" }
    XmlRole { name: "runtimesecs"; query: "runtimesecs/string()" }

    onStatusChanged:
    {
        if (status == XmlListModel.Ready)
        {
            console.log("READY >> " + mxmlModel.source.toString())
        }

        if (status === XmlListModel.Loading)
        {
            console.log("LOADING >> " + mxmlModel.source.toString())
        }

        if (status === XmlListModel.Error)
        {
            console.log("Error: " + errorString + "\n \n \n " + mxmlModel.source.toString());
        }
    }
}
