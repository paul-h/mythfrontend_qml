import QtQuick 2.0
import QtQuick.XmlListModel 2.0
import mythqml.net 1.0

XmlListModel
{
    id: mxmlModel
    source: ""
    query: "/metadata/item"
    XmlRole { name: "title"; query: "title/string()" }
    XmlRole { name: "subtitle"; query: "subtitle/string()" }
    XmlRole { name: "description"; query: "description/string()" }
    XmlRole { name: "season"; query: "season/string()" }
    XmlRole { name: "episode"; query: "episode/string()" }
    XmlRole { name: "tagline"; query: "tagline/string()" }
    XmlRole { name: "categories"; query: "string-join(categories/category/@name, ',')" }
    XmlRole { name: "contenttype"; query: "contenttype/string()" }
    XmlRole { name: "nsfw"; query: "boolean(nsfw/number())" }
    XmlRole { name: "inetref"; query: "inetref/string()" }
    XmlRole { name: "hash"; query: "hash/string()" }
    XmlRole { name: "website"; query: "website/string()" }
    XmlRole { name: "studio"; query: "studio/string()" }
    XmlRole { name: "coverart"; query: "coverart/string()" }
    XmlRole { name: "fanart"; query: "fanart/string()" }
    XmlRole { name: "banner"; query: "banner/string()" }
    XmlRole { name: "screenshot"; query: "screenshot/string()" }
    XmlRole { name: "front"; query: "front/string()" }
    XmlRole { name: "back"; query: "back/string()" }

    XmlRole { name: "channum"; query: "channum/string()" }
    XmlRole { name: "callsign"; query: "callsign/string()" }
    XmlRole { name: "startts"; query: "startts/string()" }
    XmlRole { name: "releasedate"; query: "releasedate/string()" }
    XmlRole { name: "runtime"; query: "runtime/string()" }
    XmlRole { name: "runtimesecs"; query: "runtimesecs/string()" }
    XmlRole { name: "dateadded"; query: "dateadded/string()" }
    XmlRole { name: "datemodified"; query: "datemodified/string()" }
    XmlRole { name: "status"; query: "status/string()" }

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
