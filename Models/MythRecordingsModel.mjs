WorkerScript.onMessage = function(msg)
{
    if (msg.action == 'loadLists')
    {
        var titles = [];
        var genres = [];
        var recgroups = [];

        msg.titleList.clear();
        msg.genreList.clear();
        msg.recgroupList.clear();

        for (var x = 0; x < msg.model.count; x++)
        {
            if (titles.indexOf(msg.model.get(x).Title) < 0)
                titles.push(msg.model.get(x).Title);

            if (genres.indexOf(msg.model.get(x).Category) < 0)
                genres.push(msg.model.get(x).Category);

            if (recgroups.indexOf(msg.model.get(x).Recording.RecGroup) < 0)
                recgroups.push(msg.model.get(x).Recording.RecGroup);
        }

        titles.sort();

        for (let x = 0; x < titles.length; x++)
            msg.titleList.append({"item": titles[x]});

        msg.titleList.sync();

        genres.sort();

        for (let x = 0; x < genres.length; x++)
            msg.genreList.append({"item": genres[x]});

        msg.genreList.sync();

        recgroups.sort();

        for (let x = 0; x < recgroups.length; x++)
            msg.recgroupList.append({"item": recgroups[x]});

        msg.recgroupList.sync();
    }
    else if (msg.action == 'expandNode')
    {
        msg.model.doExpandNode(msg.tree, msg.path, msg.node);
    }
}
