
WorkerScript.onMessage = function(msg)
{
    if (msg.action === "Count Files")
    {
        WorkerScript.sendMessage({'action': "Count Files", 'status': "starting"});
        var url = msg.url;
        var mythUtils = msg.mythUtils;
        var count = mythUtils.countFiles(url);
        WorkerScript.sendMessage({'result': "Count Files", 'url': url, 'count': count});
    }
    else if (msg.action === "Test")
    {
        WorkerScript.sendMessage({'result': "Test", 'status': "Test Finished"});
    }
}

