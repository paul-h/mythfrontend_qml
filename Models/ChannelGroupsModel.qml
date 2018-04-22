import QtQuick 2.0
import QtQuick.XmlListModel 2.0

XmlListModel
{
    id: channelGroupsModel

    source: settings.masterBackend + "Guide/GetChannelGroupList"
    query: "/ChannelGroupList/ChannelGroups/ChannelGroup"

    XmlRole { name: "GroupId"; query: "GroupId/number()" }
    XmlRole { name: "Name"; query: "Name/string()" }
    XmlRole { name: "Password"; query: "Password/string()" }

    onStatusChanged:
    {
        if (status == XmlListModel.Ready)
        {
            console.log("Status: " + "ChannelGroups - Found " + count + " channelgroups");
        }

        if (status === XmlListModel.Loading)
        {
            console.log("Status: " + "ChannelGroups - LOADING - " + source.toString());
        }

        if (status === XmlListModel.Error)
        {
            console.log("Status: " + "ChannelGroups - ERROR: " + errorString() + "\n" + source.toString());
        }
    }

    function addChannelToGroup(chanId, groupId)
    {
        var http = new XMLHttpRequest();
        var url = settings.masterBackend + "Guide/AddToChannelGroup";
        var params = "ChannelGroupId=" + groupId + "&ChanId=" + chanId;
        http.open("POST", url, true);

        // Send the proper header information along with the request
        http.setRequestHeader("Content-type", "application/x-www-form-urlencoded");
        http.setRequestHeader("Content-length", params.length);
        http.setRequestHeader("Connection", "close");

        http.onreadystatechange = function()
        {
            // Call a function when the state changes.
            if (http.readyState == 4)
            {
                if (http.status == 200)
                {
                    if (http.responseText.endsWith("<bool>true</bool>\n"))
                    {
                        console.log("addChannelToGroup: channel: " + chanId + " added to channel group: " + groupId + " OK");
                        channelGroupsModel.reload();
                    }
                    else
                    {
                        console.log("addChannelToGroup: failed to add channel: " + chanId + " to channel group: " + groupId + "\n" + http.responseText);
                    }
                }
                else
                {
                    console.error("addChannelToGroup error: " + http.status)
                }
            }
        }

        http.send(params);
    }

    function removeChannelFromGroup(chanId, groupId)
    {
        var http = new XMLHttpRequest();
        var url = settings.masterBackend + "Guide/RemoveFromChannelGroup";
        var params = "ChannelGroupId=" + groupId + "&ChanId=" + chanId;
        http.open("POST", url, true);

        // Send the proper header information along with the request
        http.setRequestHeader("Content-type", "application/x-www-form-urlencoded");
        http.setRequestHeader("Content-length", params.length);
        http.setRequestHeader("Connection", "close");

        http.onreadystatechange = function()
        {
            // Call a function when the state changes.
            if (http.readyState == 4)
            {
                if (http.status == 200)
                {
                    if (http.responseText.endsWith("<bool>true</bool>\n"))
                    {
                        console.log("removeChannelFromGroup: channel: " + chanId + " removed from channel group: " + groupId + " OK");
                        channelGroupsModel.reload();
                    }
                    else
                    {
                        console.log("removeChannelFromGroup: failed to remove channel: " + chanId + " from channel group: " + groupId + "\n" + http.responseText);
                    }
                }
                else
                {
                    console.error("removeChannelFromGroup error: " + http.status)
                }
            }
        }

        http.send(params);
    }
}
