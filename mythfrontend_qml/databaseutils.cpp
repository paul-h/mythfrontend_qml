// qt
#include <QVariant>
#include <QSqlError>

// mythfrontend_qml
#include "databaseutils.h"
#include "context.h"
#include "logger.h"

void DatabaseUtils::updateChannel(int chanid, QString chanName, QString chanNo, QString xmltvid, QString callsign)
{
    gContext->m_logger->debug(Verbose::DATABASE,
                              QString("DatabaseUtils::updateChannel: chanid is: %1, chanName is: %2, chanNo is: %3, xmltv is: %4, callsign is: %5")
                              .arg(chanid).arg(chanName).arg(chanNo).arg(xmltvid).arg(callsign));

    QSqlQuery query(gContext->m_mythDB);
    query.prepare("UPDATE channel SET channum = :CHANNUM, name = :NAME, xmltvid = :XMLTVID, callsign = :CALLSIGN "
                  "WHERE chanid = :CHANID;");
    query.bindValue(":CHANID",   QString("%1").arg(chanid));
    query.bindValue(":CHANNUM",  chanNo);
    query.bindValue(":NAME",     chanName);
    query.bindValue(":XMLTVID",  xmltvid);
    query.bindValue(":CALLSIGN", callsign);
    query.exec();
}

QString DatabaseUtils::getMythSetting(const QString &settingName, const QString &hostName, const QString &defaultValue)
{
    QString value;
    QSqlQuery query(gContext->m_mythDB);

    query.prepare(
        "SELECT data "
        "FROM settings "
        "WHERE value = :VALUE AND hostname = :HOSTNAME");

    query.bindValue(":VALUE", settingName);
    query.bindValue(":HOSTNAME", hostName);

    if (query.exec() && query.next())
    {
        value = query.value(0).toString();
        return value;
    }

    return defaultValue;
}

bool DatabaseUtils::setMythSetting(QString settingName, QString hostName, QString value)
{
    QSqlQuery query(gContext->m_mythDB);
    bool success = false;

    if (!hostName.isEmpty())
        query.prepare("DELETE FROM settings WHERE value = :KEY "
                      "AND hostname = :HOSTNAME ;");
    else
        query.prepare("DELETE FROM settings WHERE value = :KEY "
                      "AND hostname is NULL;");

    query.bindValue(":KEY", settingName);
    if (!hostName.isEmpty())
        query.bindValue(":HOSTNAME", hostName);

    if (!query.exec())
    {
        gContext->m_logger->error(Verbose::DATABASE, "DatabaseUtils::setMythSetting delete failed");
        return false;
    }
    else
    {
        success = true;
    }

    if (success)
    {
        if (!hostName.isEmpty())
            query.prepare("INSERT INTO settings (value,data,hostname) "
                          "VALUES ( :VALUE, :DATA, :HOSTNAME );");
        else
            query.prepare("INSERT INTO settings (value,data ) "
                          "VALUES ( :VALUE, :DATA );");

        query.bindValue(":VALUE", settingName);
        query.bindValue(":DATA", value);
        if (!hostName.isEmpty())
            query.bindValue(":HOSTNAME", hostName);

        if (!query.exec())
        {
            success = false;
            gContext->m_logger->error(Verbose::DATABASE, "DatabaseUtils::setMythSetting insert failed");
        }
    }

    return success;
}

// these use the MythQML database
QString DatabaseUtils::getSetting(const QString &settingName, const QString &hostName, const QString &defaultValue)
{
    QString value;
    QSqlQuery query(gContext->m_mythQMLDB);

    query.prepare(
        "SELECT data "
        "FROM settings "
        "WHERE value = :VALUE AND hostname = :HOSTNAME");

    query.bindValue(":VALUE", settingName);
    query.bindValue(":HOSTNAME", hostName);

    if (query.exec() && query.next())
    {
        value = query.value(0).toString();
        gContext->m_logger->debug(Verbose::DATABASE, QString("DatabaseUtils::getSetting - settingName: '%1', hostName: '%2', value: '%3'")
                                                            .arg(settingName).arg(hostName).arg(value));
        return value;
    }

    gContext->m_logger->debug(Verbose::DATABASE, QString("DatabaseUtils::getSetting - settingName: '%1', hostName: '%2', value: '%3'")
                                                        .arg(settingName).arg(hostName).arg(defaultValue));
    return defaultValue;
}

bool DatabaseUtils::setSetting(QString settingName, QString hostName, QString value)
{
    gContext->m_logger->debug(Verbose::DATABASE, QString("DatabaseUtils::setSetting - settingName: '%1', hostName: '%2', value: '%3'")
                                                        .arg(settingName).arg(hostName).arg(value));
    QSqlQuery query(gContext->m_mythQMLDB);
    bool success = false;

    if (!hostName.isEmpty())
        query.prepare("DELETE FROM settings WHERE value = :KEY "
                      "AND hostname = :HOSTNAME ;");
    else
        query.prepare("DELETE FROM settings WHERE value = :KEY "
                      "AND hostname is NULL;");

    query.bindValue(":KEY", settingName);
    if (!hostName.isEmpty())
        query.bindValue(":HOSTNAME", hostName);

    if (!query.exec())
    {
        gContext->m_logger->error(Verbose::DATABASE, "DatabaseUtils::setSetting delete failed");
        return false;
    }
    else
    {
        success = true;
    }

    if (success)
    {
        if (!hostName.isEmpty())
            query.prepare("INSERT INTO settings (value,data,hostname) "
                          "VALUES ( :VALUE, :DATA, :HOSTNAME );");
        else
            query.prepare("INSERT INTO settings (value,data ) "
                          "VALUES ( :VALUE, :DATA );");

        query.bindValue(":VALUE", settingName);
        query.bindValue(":DATA", value);
        if (!hostName.isEmpty())
            query.bindValue(":HOSTNAME", hostName);

        if (!query.exec())
        {
            success = false;
            gContext->m_logger->error(Verbose::DATABASE, "DatabaseUtils::setSetting insert failed - " + query.lastError().text() + ", query was: " + query.lastQuery());
        }
    }

    return success;
}

// recordings

void DatabaseUtils::updateRecording(int recordid, const QString &title, const QString &subtitle, const QString &description, const QString &category,
                                    const QString &chanid, const QString &channum, const QString &callsign, const QString &channelname, const QString &recgroup,
                                    const QString &starttime, const QString & airdate, const QString &filename, const QString &hostname)
{
    gContext->m_logger->debug(Verbose::DATABASE,
                              QString("DatabaseUtils::updateRecording: recordid is: %1, title is: %2, subtitle is: %3, description is: %4, category is: %5"
                                      "chanid is: %6, channum is: %7, callsign is: %8, channelname is: %9, recgroup is: %10, starttime is: %11, airdate is: %11"
                                      "filemame is: %12, hostname is: %13")
                              .arg(recordid).arg(title).arg(subtitle).arg(description).arg(category).arg(chanid).arg(channum).arg(callsign)
                              .arg(channelname).arg(starttime).arg(airdate).arg(filename).arg(hostname));

    QSqlQuery query(gContext->m_mythQMLDB);
    query.prepare("UPDATE recordings SET title = :TITLE, subtitle = :SUBTITLE, description = :DESCRIPTION, category = :CATEGORY, "
                  "chanid = :CHANID, channum = :CHANNUM, callsign = :CALLSIGN, channelname = :CHANNELNAME, recgroup = : RECGROUP, "
                  "starttime = :STARTTIME, airdate = :AIRDATE, filename = :FILENAME, hostname = :HOSTNAME "
                  "WHERE recordid = :RECORDID;");

    query.bindValue(":RECORDID", QString("%1").arg(recordid));
    query.bindValue(":TITLE", title);
    query.bindValue(":SUBTITLE", subtitle);
    query.bindValue(":DESCRIPTION", description);
    query.bindValue(":CATEGORY", category);
    query.bindValue(":CHANID", chanid);
    query.bindValue(":CHANNUM", channum);
    query.bindValue(":CALLSIGN", callsign);
    query.bindValue(":CHANNELNAME", channelname);
    query.bindValue(":RECGROUP", recgroup);
    query.bindValue(":STARTTIME", starttime);
    query.bindValue(":AIRDATE", airdate);
    query.bindValue(":FILENAME", filename);
    query.bindValue(":HOSTNAME", hostname);
    query.exec();

    gContext->m_mythQMLDB.commit();

}

// browser bookmark

int DatabaseUtils::addBrowserBookmark(const QString &website, const QString &title, const QString &category, const QString &url, const QString &iconUrl)
{
    gContext->m_logger->debug(Verbose::DATABASE,
                              QString("DatabaseUtils::addBrowserBookmark: website is: %1, title is: %2, category is: %3, url is: %4, iconUrl is: %5")
                              .arg(website).arg(title).arg(category).arg(url).arg(iconUrl));

    QSqlQuery query(gContext->m_mythQMLDB);
    query.prepare("INSERT INTO bookmarks (website, title, category, url, iconurl, date_added, date_modified, date_visited, visited_count) "
                  "VALUES (:WEBSITE, :TITLE, :CATEGORY, :URL, :ICONURL, :DATE_ADDED, :DATE_MODIFIED, :DATE_VISITED, :VISITED_COUNT);");
    query.bindValue(":WEBSITE", website);
    query.bindValue(":TITLE", title);
    query.bindValue(":CATEGORY", category);
    query.bindValue(":URL", url);
    query.bindValue(":ICONURL", iconUrl);
    query.bindValue(":DATE_ADDED", QDateTime::currentDateTime().toString(Qt::ISODate));
    query.bindValue(":DATE_MODIFIED", QDateTime::currentDateTime().toString(Qt::ISODate));
    query.bindValue(":DATE_VISITED", "");
    query.bindValue(":VISITED_COUNT", 0);

    if (!query.exec())
    {
        gContext->m_logger->error(Verbose::GENERAL, QString("DatabaseUtils::addBrowserBookmark ERROR: %1 - %2").arg(query.lastError().text()).arg(query.executedQuery()));
        return -1;
    }

    gContext->m_mythQMLDB.commit();

    return query.lastInsertId().toInt();
}

void DatabaseUtils::updateBrowserBookmark(int bookmarkid, const QString &website, const QString &title, const QString &category, const QString &url, const QString &iconUrl)
{
    gContext->m_logger->debug(Verbose::DATABASE,
                              QString("DatabaseUtils::updateBrowserBookmark: bookmarkid is: %1, website is: %2, title is: %3, category is: %4, url is: %5, iconUrl is: %6")
                              .arg(bookmarkid).arg(website).arg(title).arg(category).arg(url).arg(iconUrl));

    QSqlQuery query(gContext->m_mythQMLDB);
    query.prepare("UPDATE bookmarks SET website = :WEBSITE, title = :TITLE, category = :CATEGORY, url = :URL, iconurl = :ICONURL, date_modified = :DATE_MODIFIED "
                  "WHERE bookmarkid = :BOOKMARTKID;");
    query.bindValue(":WEBSITE", website);
    query.bindValue(":TITLE", title);
    query.bindValue(":CATEGORY", category);
    query.bindValue(":URL", url);
    query.bindValue(":ICONURL", iconUrl);
    query.bindValue(":DATE_MODIFIED", QDateTime::currentDateTime().toString(Qt::ISODate));
    query.bindValue(":BOOKMARTKID", bookmarkid);

    if (!query.exec())
    {
        gContext->m_logger->error(Verbose::GENERAL, QString("DatabaseUtils::updateBrowserBookmark ERROR: %1 - %2").arg(query.lastError().text()).arg(query.executedQuery()));
    }

    gContext->m_mythQMLDB.commit();

}

void DatabaseUtils::deleteBrowserBookmark(int bookmarkid)
{
    gContext->m_logger->debug(Verbose::DATABASE, QString("DatabaseUtils::deleteBrowserBookmark: bookmarkid is: %1").arg(bookmarkid));

    QSqlQuery query(gContext->m_mythQMLDB);
    query.prepare("DELETE FROM bookmarks WHERE bookmarkid = :BOOKMARTKID;");
    query.bindValue(0, bookmarkid);
    query.exec();

    gContext->m_mythQMLDB.commit();
}

// tivo channels

int DatabaseUtils::addTivoChannel(int channo, const QString &name, int plus1, const QString &category, const QString &definition, int sdid, const QString &icon)
{
    gContext->m_logger->debug(Verbose::DATABASE,
                              QString("DatabaseUtils::addTivoChannel: channo is: %1, name is: %2, plus1 is: %3, category is: %4, definition is: %5, sdid is: %6, icon is: %7")
                              .arg(channo).arg(name).arg(plus1).arg(category).arg(definition).arg(sdid).arg(icon));

    QSqlQuery query(gContext->m_mythQMLDB);
    query.prepare("INSERT INTO tivochannels (channo, name, plus1, category, definition, sdid, icon) "
                  "VALUES (:CHANNO, :NAME, :PLUS1, :CATEGORY, :DEFINITION, :SDID, :ICON);");
    query.bindValue(":CHANNO", channo);
    query.bindValue(":NAME", name);
    query.bindValue(":PLUS1", plus1);
    query.bindValue(":CATEGORY", category);
    query.bindValue(":DEFINITION", definition);
    query.bindValue(":SDID", sdid);
    query.bindValue(":ICON", icon);

    if (!query.exec())
    {
        gContext->m_logger->error(Verbose::GENERAL, QString("DatabaseUtils::addTivoChannel ERROR: %1 - %2").arg(query.lastError().text()).arg(query.executedQuery()));
        return -1;
    }

    gContext->m_mythQMLDB.commit();

    return query.lastInsertId().toInt();
}

void DatabaseUtils::updateTivoChannel(int chanid,int channo, const QString &name, int plus1, const QString &category, const QString &definition, int sdid, const QString &icon)
{
    gContext->m_logger->debug(Verbose::DATABASE,
                              QString("DatabaseUtils::updateTivoChannel: chanid: %1, channo is: %2, name is: %3, plus1 is: %4, category is: %5, definition is: %6, sdid is: %7, icon is: %8")
                              .arg(chanid).arg(channo).arg(name).arg(plus1).arg(category).arg(definition).arg(sdid).arg(icon));

    QSqlQuery query(gContext->m_mythQMLDB);
    query.prepare("UPDATE tivochannels SET channo = :CHANNO, name = :NAME, plus1 = :PLUS1, category = :CATEGORY, definition = :DEFINITION, sdid = :SDID,icon = :ICON "
                  "WHERE chanid = :CHANID;");
    query.bindValue(":CHANNO", channo);
    query.bindValue(":NAME", name);
    query.bindValue(":PLUS1", plus1);
    query.bindValue(":CATEGORY", category);
    query.bindValue(":DEFINITION", definition);
    query.bindValue(":SDID", sdid);
    query.bindValue(":ICON", icon);
    query.bindValue(":CHANID", chanid);

    if (!query.exec())
    {
        gContext->m_logger->error(Verbose::GENERAL, QString("DatabaseUtils::updateTivoChannel ERROR: %1 - %2").arg(query.lastError().text()).arg(query.executedQuery()));
    }

    gContext->m_mythQMLDB.commit();

}

void DatabaseUtils::deleteTivoChannel(int chanid)
{
    gContext->m_logger->debug(Verbose::DATABASE, QString("DatabaseUtils::deleteTivoChannel: chanid is: %1").arg(chanid));

    QSqlQuery query(gContext->m_mythQMLDB);
    query.prepare("DELETE FROM tivochannels WHERE chanid = :CHANID;");
    query.bindValue(0, chanid);
    query.exec();

    gContext->m_mythQMLDB.commit();
}

// menu items

int DatabaseUtils::addMenuItem(const QString &menu, int position, const QString &menuText, const QString &loaderSource, const QString &waterMark, const QString &url,
                               double zoom, bool fullscreen, int layout, const QString &exec)
{
    gContext->m_logger->debug(Verbose::DATABASE,
                              QString("DatabaseUtils::addMenuItem: menu is: %1, position is: %2, menuText is: %3, loaderSource is: %4, waterMark is: %5, url is %6, zoom is %7,fullscreen is %8, layout is %9, exec is %10")
                              .arg(menu).arg(position).arg(menuText).arg(loaderSource).arg(waterMark).arg(url).arg(zoom).arg(fullscreen).arg(layout).arg(exec));

    QSqlQuery query(gContext->m_mythQMLDB);
    query.prepare("INSERT INTO menuitems (menu, position, menuText, loaderSource, waterMark, url, zoom, fullscreen, layout, exec) "
                  "VALUES (:MENU, :POSITION, :MENUTEXT, :LOADERSOURCE, :WATERMARK, :URL, :ZOOM, :FULLSCREEN, :LAYOUT, :EXEC);");
    query.bindValue(":MENU", menu);
    query.bindValue(":POSITION", position);
    query.bindValue(":MENUTEXT", menuText);
    query.bindValue(":LOADERSOURCE", loaderSource);
    query.bindValue(":WATERMARK", waterMark);
    query.bindValue(":URL", url);
    query.bindValue(":ZOOM", zoom);
    query.bindValue(":FULLSCREEN", (fullscreen ? "1" : "0"));
    query.bindValue(":LAYOUT", layout);
    query.bindValue(":EXEC", exec);

    if (!query.exec())
    {
        gContext->m_logger->error(Verbose::GENERAL, QString("DatabaseUtils::addMenuItem ERROR: %1 - %2").arg(query.lastError().text()).arg(query.executedQuery()));
        return -1;
    }

    gContext->m_mythQMLDB.commit();

    return query.lastInsertId().toInt();
}

void DatabaseUtils::updateMenuItem(int itemid,const QString &menu, int position, const QString &menuText, const QString &loaderSource, const QString &waterMark, const QString &url,
                                   double zoom, bool fullscreen, int layout, const QString &exec)
{
    gContext->m_logger->debug(Verbose::DATABASE,
                              QString("DatabaseUtils::updateMenuItem: itemid is %1, menu is: %2, position is: %3, menuText is: %4, loaderSource is: %5, waterMark is: %6, url is %7, zoom is %8,fullscreen is %9, layout is %10, exec is %11")
                              .arg(itemid).arg(menu).arg(position).arg(menuText).arg(loaderSource).arg(waterMark).arg(url).arg(zoom).arg(fullscreen).arg(layout).arg(exec));

    QSqlQuery query(gContext->m_mythQMLDB);
    query.prepare("UPDATE menuitems SET menu = :MENU, position = :POSITION, menuText = :MENUTEXT, loaderSource = :LOADERSOURCE, waterMark = :WATERMARK, url = :URL, zoom = :ZOOM, fullscreen = :FULLSCREEN, layout = :LAYOUT, exec = :EXEC "
                  "WHERE itemid = :ITEMID;");
    query.bindValue(":MENU", menu);
    query.bindValue(":POSITION", position);
    query.bindValue(":MENUTEXT", menuText);
    query.bindValue(":LOADERSOURCE", loaderSource);
    query.bindValue(":WATERMARK", waterMark);
    query.bindValue(":URL", url);
    query.bindValue(":ZOOM", zoom);
    query.bindValue(":FULLSCREEN", (fullscreen ? 1 : 0));
    query.bindValue(":LAYOUT", layout);
    query.bindValue(":EXEC", exec);
    query.bindValue(":ITEMID", itemid);

    if (!query.exec())
    {
        gContext->m_logger->error(Verbose::GENERAL, QString("DatabaseUtils::updateMenuItem ERROR: %1 - %2").arg(query.lastError().text()).arg(query.executedQuery()));
    }

    gContext->m_mythQMLDB.commit();
}

void DatabaseUtils::deleteMenuItem(int itemid)
{
    gContext->m_logger->debug(Verbose::DATABASE, QString("DatabaseUtils::deleteMenuItem: itemid is: %1").arg(itemid));

    QSqlQuery query(gContext->m_mythQMLDB);
    query.prepare("DELETE FROM menuitems WHERE itemid = :ITEMID;");
    query.bindValue(0, itemid);
    query.exec();

    gContext->m_mythQMLDB.commit();
}
