import QtQuick 2.0
import QtQuick.XmlListModel 2.0
import mythqml.net 1.0

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
    XmlRole { name: "categories"; query: "string-join(categories/category/name, ', ')" }

    onStatusChanged:
    {
        if (status == XmlListModel.Ready)
        {
            log.debug(Verbose.MODEL, "MythMetadataXMLModel: READY - found " + count + " items")
        }

        if (status === XmlListModel.Loading)
        {
            log.debug(Verbose.MODEL, "MythMetadataXMLModel: LOADING - " + mxmlModel.source)
        }

        if (status === XmlListModel.Error)
        {
            log.error(Verbose.MODEL, "MythMetadataXMLModel: ERROR - " + errorString() + " - " + source);
        }
    }
}
