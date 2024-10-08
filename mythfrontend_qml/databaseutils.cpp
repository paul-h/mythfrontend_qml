// qt
#include <QVariant>
#include <QSqlError>
#include <QDomDocument>

// mythfrontend_qml
#include "databaseutils.h"
#include "context.h"
#include "logger.h"

void DatabaseUtils::updateChannel(int chanid, QString chanName, QString chanNo, QString xmltvid, QString callsign)
{
    gContext->m_logger->debug(Verbose::DATABASE,
                              QString("DatabaseUtils::updateChannel: chanid is: %1, chanName is: %2, chanNo is: %3, xmltv is: %4, callsign is: %5")
                              .arg(chanid).arg(chanName).arg(chanNo).arg(xmltvid).arg(callsign));

    QSqlQuery query(getMythTVDatabase());
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
    QSqlQuery query(getMythTVDatabase());

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
    QSqlQuery query(getMythTVDatabase());
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
    QSqlQuery query(getMythQMLDatabase());

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
    QSqlQuery query(getMythQMLDatabase());
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

    QSqlQuery query(getMythQMLDatabase());
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

    getMythQMLDatabase().commit();

}

// browser bookmark

int DatabaseUtils::addBrowserBookmark(const QString &website, const QString &title, const QString &category, const QString &url, const QString &iconUrl)
{
    gContext->m_logger->debug(Verbose::DATABASE,
                              QString("DatabaseUtils::addBrowserBookmark: website is: %1, title is: %2, category is: %3, url is: %4, iconUrl is: %5")
                              .arg(website).arg(title).arg(category).arg(url).arg(iconUrl));

    QSqlQuery query(getMythQMLDatabase());
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

    getMythQMLDatabase().commit();

    return query.lastInsertId().toInt();
}

void DatabaseUtils::updateBrowserBookmark(int bookmarkid, const QString &website, const QString &title, const QString &category, const QString &url, const QString &iconUrl)
{
    gContext->m_logger->debug(Verbose::DATABASE,
                              QString("DatabaseUtils::updateBrowserBookmark: bookmarkid is: %1, website is: %2, title is: %3, category is: %4, url is: %5, iconUrl is: %6")
                              .arg(bookmarkid).arg(website).arg(title).arg(category).arg(url).arg(iconUrl));

    QSqlQuery query(getMythQMLDatabase());
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

    getMythQMLDatabase().commit();

}

void DatabaseUtils::deleteBrowserBookmark(int bookmarkid)
{
    gContext->m_logger->debug(Verbose::DATABASE, QString("DatabaseUtils::deleteBrowserBookmark: bookmarkid is: %1").arg(bookmarkid));

    QSqlQuery query(getMythQMLDatabase());
    query.prepare("DELETE FROM bookmarks WHERE bookmarkid = :BOOKMARTKID;");
    query.bindValue(0, bookmarkid);
    query.exec();

    getMythQMLDatabase().commit();
}

// tivo channels

int DatabaseUtils::addTivoChannel(int channo, const QString &name, int plus1, const QString &category, const QString &definition, int sdid, const QString &icon)
{
    gContext->m_logger->debug(Verbose::DATABASE,
                              QString("DatabaseUtils::addTivoChannel: channo is: %1, name is: %2, plus1 is: %3, category is: %4, definition is: %5, sdid is: %6, icon is: %7")
                              .arg(channo).arg(name).arg(plus1).arg(category).arg(definition).arg(sdid).arg(icon));

    QSqlQuery query(getMythQMLDatabase());
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

    getMythQMLDatabase().commit();

    return query.lastInsertId().toInt();
}

void DatabaseUtils::updateTivoChannel(int chanid,int channo, const QString &name, int plus1, const QString &category, const QString &definition, int sdid, const QString &icon)
{
    gContext->m_logger->debug(Verbose::DATABASE,
                              QString("DatabaseUtils::updateTivoChannel: chanid: %1, channo is: %2, name is: %3, plus1 is: %4, category is: %5, definition is: %6, sdid is: %7, icon is: %8")
                              .arg(chanid).arg(channo).arg(name).arg(plus1).arg(category).arg(definition).arg(sdid).arg(icon));

    QSqlQuery query(getMythQMLDatabase());
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

    getMythQMLDatabase().commit();

}

void DatabaseUtils::deleteTivoChannel(int chanid)
{
    gContext->m_logger->debug(Verbose::DATABASE, QString("DatabaseUtils::deleteTivoChannel: chanid is: %1").arg(chanid));

    QSqlQuery query(getMythQMLDatabase());
    query.prepare("DELETE FROM tivochannels WHERE chanid = :CHANID;");
    query.bindValue(0, chanid);
    query.exec();

    getMythQMLDatabase().commit();
}

// menu items

int DatabaseUtils::addMenuItem(const QString &menu, int position, const QString &menuText, const QString &loaderSource, const QString &waterMark, const QString &url,
                               double zoom, bool fullscreen, int layout, const QString &exec)
{
    gContext->m_logger->debug(Verbose::DATABASE,
                              QString("DatabaseUtils::addMenuItem: menu is: %1, position is: %2, menuText is: %3, loaderSource is: %4, waterMark is: %5, url is %6, zoom is %7,fullscreen is %8, layout is %9, exec is %10")
                              .arg(menu).arg(position).arg(menuText).arg(loaderSource).arg(waterMark).arg(url).arg(zoom).arg(fullscreen).arg(layout).arg(exec));

    QSqlQuery query(getMythQMLDatabase());
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

    getMythQMLDatabase().commit();

    return query.lastInsertId().toInt();
}

void DatabaseUtils::updateMenuItem(int itemid,const QString &menu, int position, const QString &menuText, const QString &loaderSource, const QString &waterMark, const QString &url,
                                   double zoom, bool fullscreen, int layout, const QString &exec)
{
    gContext->m_logger->debug(Verbose::DATABASE,
                              QString("DatabaseUtils::updateMenuItem: itemid is %1, menu is: %2, position is: %3, menuText is: %4, loaderSource is: %5, waterMark is: %6, url is %7, zoom is %8,fullscreen is %9, layout is %10, exec is %11")
                              .arg(itemid).arg(menu).arg(position).arg(menuText).arg(loaderSource).arg(waterMark).arg(url).arg(zoom).arg(fullscreen).arg(layout).arg(exec));

    QSqlQuery query(getMythQMLDatabase());
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

    getMythQMLDatabase().commit();
}

void DatabaseUtils::deleteMenuItem(int itemid)
{
    gContext->m_logger->debug(Verbose::DATABASE, QString("DatabaseUtils::deleteMenuItem: itemid is: %1").arg(itemid));

    QSqlQuery query(getMythQMLDatabase());
    query.prepare("DELETE FROM menuitems WHERE itemid = :ITEMID;");
    query.bindValue(0, itemid);
    query.exec();

    getMythQMLDatabase().commit();
}

bool DatabaseUtils::updateMediaItem(QObject *metadata)
{
    QSqlQuery query(getMythQMLDatabase());
    query.prepare("UPDATE mediaitems SET title = :TITLE, subtitle = :SUBTITLE, description = :DESCRIPTION, season = :SEASON, episode = :EPISODE, "
                  "tagline = :TAGLINE, genres = :CATEGORIES, inetref = :INETREF, website = :WEBSITE, contenttype = :CONTENTTYPE, nsfw = :NSFW, studio = :STUDIO, "
                  "coverart = :COVERART, fanart = :FANART, banner = :BANNER, screenshot = :SCREENSHOT, front = :FRONT, back = :BACK, channum = :CHANNUM, "
                  "callsign = :CALLSIGN, startts = :STARTTS, releasedate = :RELEASEDATE, runtime = :RUNTIME, runtimesecs = :RUNTIMESECS, status = :STATUS "
                  "WHERE id = :ID;");

    query.bindValue(":TITLE", metadata->property("title").toString());
    query.bindValue(":SUBTITLE", metadata->property("subtitle").toString());
    query.bindValue(":DESCRIPTION", metadata->property("description").toString());
    query.bindValue(":SEASON", metadata->property("season").toString());
    query.bindValue(":EPISODE", metadata->property("episode").toString());
    query.bindValue(":TAGLINE", metadata->property("tagline").toString());
    query.bindValue(":CATEGORIES", metadata->property("categories").toString());
    query.bindValue(":INETREF", metadata->property("inetref").toString());
    query.bindValue(":WEBSITE", metadata->property("website").toString());
    query.bindValue(":CONTENTTYPE", metadata->property("contentType").toString());
    query.bindValue(":NSFW", metadata->property("nsfw").toInt());
    query.bindValue(":STUDIO", metadata->property("studio").toString());
    query.bindValue(":COVERART", metadata->property("coverart").toString());
    query.bindValue(":FANART", metadata->property("fanart").toString());
    query.bindValue(":BANNER", metadata->property("banner").toString());
    query.bindValue(":SCREENSHOT", metadata->property("screenshot").toString());
    query.bindValue(":FRONT", metadata->property("front").toString());
    query.bindValue(":BACK", metadata->property("back").toString());
    query.bindValue(":CHANNUM", metadata->property("channum").toString());
    query.bindValue(":CALLSIGN", metadata->property("callsign").toString());
    query.bindValue(":STARTTS", metadata->property("startts").toString());
    query.bindValue(":RELEASEDATE", metadata->property("releasedate").toString());
    query.bindValue(":RUNTIME", metadata->property("runtime").toString());
    query.bindValue(":RUNTIMESECS", metadata->property("runtimesecs").toString());
    query.bindValue(":STATUS", metadata->property("status").toString());
    query.bindValue(":ID", metadata->property("id").toString());

    if (!query.exec())
    {
        gContext->m_logger->error(Verbose::GENERAL, QString("SqlQueryModel::update ERROR: %1 - %2").arg(query.lastError().text()).arg(query.executedQuery()));
        return false;
    }

    getMythQMLDatabase().commit();

    return true;
}

bool DatabaseUtils::addDatabase(QObject *database)
{
    gContext->m_logger->info(Verbose::GENERAL, QString("DatabaseUtils::addDatabase name: %1, engine: %2, filename: %3").arg(database->property("name").toString()).arg(database->property("engine").toString()).arg(database->property("filename").toString()));

    // have we already opened this database?
    if (!m_dbMap.contains(database->property("name").toString()))
    {
        // no so try to add and open the database
        if (database->property("engine").toString() == "sqlite3")
        {
            QString name = database->property("name").toString();
            QString filename = database->property("filename").toString();
            addSQLite3Database(name, filename);
        }
        //TODO add support for MySQL databases?
    }

    return true;
}

bool DatabaseUtils::initMythDB(void)
{
    // attempt to connect the MythTV Mysql database using our stored settings
    QString host = gContext->m_settings->mysqlIP();
    int port = gContext->m_settings->mysqlPort();
    QString databaseName = gContext->m_settings->mysqlDBName();
    QString user = gContext->m_settings->mysqlUser();
    QString password = gContext->m_settings->mysqlPassword();

    gContext->m_logger->info(Verbose::DATABASE, "Context: Connecting to MythTV DB using stored credentials");
    gContext->m_logger->debug(Verbose::DATABASE, QString("IP: %1, Port: %2, DBName: %3, User: %4, Password: %5")
                                           .arg(host).arg(port).arg(databaseName).arg(user).arg(password));

    if (!addMySQLDatabase("mythtv", host, port, user, password, databaseName))
        return false;

    QSqlDatabase db = m_dbMap["mythtv"];

    if (!db.isOpen())
    {
        gContext->m_logger->error(Verbose::GENERAL, "Context: Failed to open the MythTV database using credentials from the database");
        return false;
    }

    gContext->m_logger->info(Verbose::GENERAL, "Context: Connected to MythTV database");

    return true;
}

bool DatabaseUtils::loadMythDBSettings(void)
{
    QDomDocument doc("mydocument");

    // find the config.xml
    QString configFile;

    if (QFile::exists(QDir::homePath() + "/.mythqml/config.xml"))
        configFile = QDir::homePath() + "/.mythqml/config.xml";
    else if (QFile::exists(QDir::homePath() + "/.mythtv/config.xml"))
        configFile = QDir::homePath() + "/.mythtv/config.xml";
    else if (QFile::exists("/etc/mythtv/config.xml"))
        configFile = "/etc/mythtv/config.xml";


    if (configFile.isEmpty())
    {
        gContext->m_logger->error(Verbose::GENERAL, "ERROR: Unable to find MythTV config file.You need to put a valid config.xml file at: ~/.mythqml/config.xml");
        return false;
    }

    gContext->m_logger->info(Verbose::DATABASE, "Context: Loading database config from: " + configFile);

    QFile file(configFile);

    if (!file.open(QIODevice::ReadOnly))
    {
        gContext->m_logger->error(Verbose::GENERAL, "Context: Failed to open MythTV config file");
        return false;
    }

    if (!doc.setContent(&file))
    {
        file.close();
        gContext->m_logger->error(Verbose::GENERAL, "Context: Failed to read from MythTV config file");
        return false;
    }
    file.close();

    QString docType = doc.doctype().name();
    QDomNodeList nodeList;
    QDomNode node;
    QDomElement elem;

    // find database credentials
    nodeList = doc.elementsByTagName("Database");

    if (nodeList.count() != 1)
    {
        gContext->m_logger->error(Verbose::GENERAL, QString("Context: Expected 1 'Database' node but got %1").arg( nodeList.count()));
        return false;
    }

    node = nodeList.at(0);
    QString host = node.namedItem(QString("Host")).toElement().text();
    QString user = node.namedItem(QString("UserName")).toElement().text();
    QString password = node.namedItem(QString("Password")).toElement().text();
    QString dbName = node.namedItem(QString("DatabaseName")).toElement().text();
    int dbPort = node.namedItem(QString("Port")).toElement().text().toInt();

    if (!addMySQLDatabase("mythtv", host, dbPort, user, password, dbName))
        return false;

    QSqlDatabase db = m_dbMap["mythtv"];

    if (!db.isOpen())
    {
        gContext->m_logger->error(Verbose::GENERAL, "Context: Failed to open the MythTV database using credentials from " + configFile);
        return false;
    }

    // save for future use
    gContext->m_settings->setMysqlIP(host);
    gContext->m_settings->setMysqlPort(dbPort);
    gContext->m_settings->setMysqlUser(user);
    gContext->m_settings->setMysqlPassword(password);
    gContext->m_settings->setMysqlDBName(dbName);

    setSetting("MysqlIP", gContext->m_settings->hostName(), host);
    setSetting("MysqlPort", gContext->m_settings->hostName(), QString::number(dbPort));
    setSetting("MysqlUser", gContext->m_settings->hostName(), user);
    setSetting("MysqlPassword", gContext->m_settings->hostName(), password);
    setSetting("MysqlDBName", gContext->m_settings->hostName(), dbName);

    gContext->m_logger->error(Verbose::GENERAL, "Context: Connected to MythTV database using credentials from " + configFile);
    return true;
}

bool DatabaseUtils::initMythQMLDB(void)
{
    QString dbFilename = QDir::homePath() + "/.mythqml/mythqml.db";

    gContext->m_logger->info(Verbose::DATABASE, "Context: MythQML DB File is: " + dbFilename);

    if (!addSQLite3Database("mythqml", dbFilename))
        return false;

    QSqlDatabase db = m_dbMap["mythqml"];

    if (!db.isOpen())
        return false;

    QSqlQuery q(db);

    if (!q.exec(QLatin1String("CREATE TABLE IF NOT EXISTS settings ("
                              "    value VARCHAR(128) PRIMARY KEY,"
                              "    data VARCHAR(16000) NOT NULL default '',"
                              "    hostname VARCHAR(64) default NULL"
                              ");")))
    {
        gContext->m_logger->error(Verbose::GENERAL, "Context: Failed to create settings table error - " + q.lastError().text());
        return false;
    }

    if (!q.exec(QLatin1String("CREATE TABLE IF NOT EXISTS recordings ("
                              "    recordid INTEGER PRIMARY KEY,"
                              "    title VARCHAR(64) default NULL,"
                              "    subtitle VARCHAR(64) default NULL,"
                              "    description VARCHAR(64) default NULL,"
                              "    category VARCHAR(64) default NULL,"
                              "    chanid VARCHAR(64) default NULL,"
                              "    channum VARCHAR(64) default NULL,"
                              "    channame VARCHAR(64) default NULL,"
                              "    recgroup VARCHAR(64) default NULL,"
                              "    starttime VARCHAR(64) default NULL,"
                              "    airdate VARCHAR(64) default NULL,"
                              "    filename VARCHAR(64) default NULL,"
                              "    hostname VARCHAR(64) default NULL"
                              ");")))
    {
        gContext->m_logger->error(Verbose::GENERAL, "Context: Failed to create recordings table error - " + q.lastError().text());
        return false;
    }

    if (!q.exec(QLatin1String("CREATE TABLE IF NOT EXISTS bookmarks ("
                              "bookmarkid INTEGER NOT NULL,"
                              "website TEXT NOT NULL,"
                              "title TEXT NOT NULL,"
                              "categories TEXT NOT NULL,"
                              "url TEXT NOT NULL,"
                              "iconurl TEXT NOT NULL,"
                              "date_added TEXT NOT NULL,"
                              "date_modified TEXT NOT NULL,"
                              "date_visited	TEXT NOT NULL,"
                              "visited_count INTEGER NOT NULL DEFAULT 0,"
                              "PRIMARY KEY(bookmarkid AUTOINCREMENT)"
                              ");")))
    {
        gContext->m_logger->error(Verbose::GENERAL, "Context: Failed to create bookmarks table error - " + q.lastError().text());
        return false;
    }

    if (!q.exec(QLatin1String("CREATE TABLE IF NOT EXISTS tivochannels ("
                              "chanid INTEGER NOT NULL,"
                              "channo INTEGER NOT NULL,"
                              "name TEXT NOT NULL,"
                              "plus1 INTEGER default NULL,"
                              "category TEXT NOT NULL,"
                              "definition TEXT NOT NULL,"
                              "sdid TEXT default NULL,"
                              "icon TEXT default NULL,"
                              "PRIMARY KEY(chanid AUTOINCREMENT)"
                              ");")))
    {
        gContext->m_logger->error(Verbose::GENERAL, "Context: Failed to create tivochannels table error - " + q.lastError().text());
        return false;
    }

    if (!q.exec(QLatin1String("CREATE TABLE IF NOT EXISTS menuitems ("
                              "itemid INTEGER NOT NULL,"
                              "menu TEXT NOT NULL,"
                              "position INTEGER default 0,"
                              "menuText TEXT NOT NULL,"
                              "loaderSource TEXT NOT NULL,"
                              "waterMark TEXT default '',"
                              "url TEXT default '',"
                              "zoom REAL default 1.0,"
                              "fullscreen INTEGER default 0,"
                              "layout INTEGER default 0,"
                              "exec TEXT default '',"
                              "PRIMARY KEY(itemid AUTOINCREMENT)"
                              ");")))
    {
        gContext->m_logger->error(Verbose::GENERAL, "Context: Failed to create menuitems table error - " + q.lastError().text());
        return false;
    }

    return true;
}

QSqlDatabase DatabaseUtils::getDatabase(const QString &database)
{
    if (m_dbMap.contains(database))
        return m_dbMap[database];

    gContext->m_logger->error(Verbose::GENERAL, "Context::getDatabase: Failed to find database - " + database);

    return QSqlDatabase();
}

bool DatabaseUtils::addSQLite3Database(const QString &name, const QString &filename)
{
    gContext->m_logger->info(Verbose::GENERAL, "Context: adding SQLite3 DB - name: " + name + ", filename: " + filename);

    // open local Sqlite3 DB
    QSqlDatabase db = QSqlDatabase::addDatabase("QSQLITE", name);
    db.setDatabaseName(filename);

    if (!db.open())
    {
        gContext->m_logger->error(Verbose::GENERAL, "Context: Failed to open " + name + "SQLite3 DB - " + db.lastError().text());
    }

    if (!db.isOpen())
        return false;

    m_dbMap.insert(name, db);

    return true;
}

bool DatabaseUtils::addMySQLDatabase(const QString &name, const QString &host, int port, const QString &user, const QString &password, const QString &databaseName)
{
    gContext->m_logger->info(Verbose::GENERAL, "Context: adding MySQL DB - name: " + name + ", filename: " + databaseName);

    QSqlDatabase db = QSqlDatabase::addDatabase("QMYSQL", name);
    db.setHostName(host);
    db.setPort(port);
    db.setDatabaseName(databaseName);
    db.setUserName(user);
    db.setPassword(password);

    bool ok = db.open();

    if (!ok)
    {
        gContext->m_logger->error(Verbose::GENERAL, "Context: Failed to open the " + name + " MySQl DB");
        return false;
    }

    m_dbMap.insert(name, db);

    return true;
}

