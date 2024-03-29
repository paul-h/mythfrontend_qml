// qt
#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QQmlComponent>
#include <QHostInfo>
#include <QUrl>
#include <QDomDocument>
#include <QFile>
#include <QDir>
#include <QUuid>
#include <QSqlQuery>
#include <QSqlError>

// common
#include "databaseutils.h"
#include "mythutils.h"
#include "settings.h"
#include "urlinterceptor.h"
#include "process.h"
#include "eventlistener.h"
#include "context.h"
#include "mdkplayer.h"

// from QmlVlc
#include <QmlVlc.h>
#include <QmlVlc/QmlVlcConfig.h>

// from VlcQml
#ifdef USE_VLCQT
#include <VLCQtQml/Qml.h>
#include <VLCQtQml/QmlPlayer.h>
#endif

Context::Context(const QString &appName, const QString &logLevel, const QString &verbose, QObject *parent) : QObject(parent)
{
    m_appName = appName;
    m_logger = nullptr;
    m_engine = nullptr;
    m_settings = nullptr;
    m_databaseUtils = nullptr;
    m_mythUtils = nullptr;
    m_eventListener = nullptr;
    m_urlInterceptor = nullptr;

    // make sure our log path exists
    QDir d;
    QString logPath(QDir::homePath() + "/.mythqml/logs");
    d.mkpath(logPath);

    // create the logger
    m_logger = new Logger();
    m_logger->setFilename(QString("%1/%2.log").arg(logPath).arg(m_appName));
    m_logger->info(Verbose::GENERAL, QString("Starting ") + m_appName + ": version " + APP_VERSION + " (" GIT_BRANCH + ")");
    m_logger->setLogLevel(logLevel);
    m_logger->setVerbose(verbose);
}

Context::~Context(void)
{
    cleanUp();
}

void Context::init()
{
    m_engine = new QQmlApplicationEngine;

    QCoreApplication::setApplicationName(m_appName);
    QCoreApplication::setAttribute(Qt::AA_X11InitThreads);

    qmlRegisterType<Process>("Process", 1, 0, "Process");

    qRegisterMetaType<Verbose>("Verbose");
    qmlRegisterUncreatableType<VerboseClass>("mythqml.net", 1, 0, "Verbose", "Not creatable as it is an enum type");

    RegisterQmlVlc();
    QmlVlcConfig& config = QmlVlcConfig::instance();
    config.enableAdjustFilter( true );
    config.enableMarqueeFilter(false);
    config.enableLogoFilter(false);
    config.enableDebug(false);
    config.enableLoopPlayback(false);
    config.setTrustedEnvironment(true);

#ifdef USE_VLCQT
    //VlcCommon::setPluginPath("/usr/local/qml/");
    //VlcQmlVideoPlayer::registerPlugin();
    VlcQml::registerTypes();
#endif

    // try to load the MDK API
    gMDKAPI = new MDKAPI();
    qmlRegisterType<QmlMDKPlayer>("MDKPlayer", 1, 0, "MDKPlayer");

    // create the logger for QML
    m_engine->rootContext()->setContextProperty("log", m_logger);

    // create appName property
    m_engine->rootContext()->setContextProperty("appName", m_appName);

    // create version property
    m_engine->rootContext()->setContextProperty("version", QString(APP_VERSION));

    // create branch property
    m_engine->rootContext()->setContextProperty("branch", QString(GIT_BRANCH));

    // create the OS version property
    m_engine->rootContext()->setContextProperty("osversion", getOSVersion());

    // create the Qt version property
    m_engine->rootContext()->setContextProperty("qtversion", QString(qVersion()));

    // create the build time property
    m_engine->rootContext()->setContextProperty("buildtime", QString("%1 - %2").arg(__DATE__).arg(__TIME__));

    // create the database utils
    m_databaseUtils = new DatabaseUtils();
    m_engine->rootContext()->setContextProperty("dbUtils", m_databaseUtils);

    // create systemid property
    m_engine->rootContext()->setContextProperty("systemid", systemID());

    QString hostName = QHostInfo::localHostName();
    QString theme = m_databaseUtils->getSetting("Theme", hostName, "MythCenter");

    // create the settings
    m_settings = new Settings(hostName, theme);

    m_engine->rootContext()->setContextProperty("settings", m_settings);

    // create the snapshots dir
    QDir d;
    if (!d.exists(m_settings->configPath() + "Snapshots"))
        d.mkpath(m_settings->configPath() + "Snapshots");

    // create the background video dir
    if (!d.exists(m_settings->configPath() + "Themes/Videos"))
        d.mkpath(m_settings->configPath() + "Themes/Videos");

    // create the background slideshow dir
    if (!d.exists(m_settings->configPath() + "Themes/Pictures"))
        d.mkpath(m_settings->configPath() + "Themes/Pictures");

    // create the myth utils
    m_mythUtils = new MythUtils(m_engine);
    m_engine->rootContext()->setContextProperty("mythUtils", m_mythUtils);

    // create eventlistener
    m_eventListener = new EventListener;
    m_engine->rootContext()->setContextProperty("eventListener", m_eventListener);

    // create URL interceptor
    m_urlInterceptor = new MythQmlAbstractUrlInterceptor(m_engine);
    m_urlInterceptor->setTheme(theme);
    m_engine->setUrlInterceptor(m_urlInterceptor);

    m_engine->addImportPath(QString(SHAREPATH) + "qml/Themes/Default");
    m_engine->addImportPath(QString(SHAREPATH) + "qml");
}

void Context::cleanUp(void)
{
    delete gMDKAPI;
    delete m_engine;
    delete m_settings;
    delete m_databaseUtils;
    delete m_mythUtils;
    delete m_eventListener;
    delete m_urlInterceptor;
    delete m_logger;

    gMDKAPI = nullptr;
    m_engine = nullptr;
    m_settings = nullptr;
    m_databaseUtils = nullptr;
    m_mythUtils = nullptr;
    m_eventListener = nullptr;
    m_urlInterceptor = nullptr;
    m_logger = nullptr;
}

bool Context::initMythDB(void)
{
    // attemp to connect the MythTV Mysql database using our stored setting
    m_mythDB = QSqlDatabase::addDatabase("QMYSQL", "MythTV");
    m_mythDB.setHostName(m_settings->mysqlIP());
    m_mythDB.setPort((m_settings->mysqlPort()));
    m_mythDB.setDatabaseName(m_settings->mysqlDBName());
    m_mythDB.setUserName(m_settings->mysqlUser());
    m_mythDB.setPassword(m_settings->mysqlPassword());

    m_logger->info(Verbose::DATABASE, "Context: Connecting to MythTV DB using stored credentials");
    m_logger->debug(Verbose::DATABASE, QString("IP: %1, Port: %2, DBName: %3, User: %4, Password: %5")
                   .arg(m_settings->mysqlIP()).arg(m_settings->mysqlPort()).arg(m_settings->mysqlDBName())
                   .arg(m_settings->mysqlUser()).arg(m_settings->mysqlPassword()));

    bool ok = m_mythDB.open();

    if (!ok)
    {
        m_logger->error(Verbose::GENERAL, "Context: Failed to open the MythTV database using our stored credentials");
        m_mythDB.close();
        return false;
    }

    m_logger->error(Verbose::GENERAL, "Context: Connected to MythTV database");

    return true;
}

bool Context::loadMythDBSettings(void)
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
        m_logger->error(Verbose::GENERAL, "ERROR: Unable to find MythTV config file.You need to put a valid config.xml file at: ~/.mythqml/config.xml");
        return false;
    }

    m_logger->info(Verbose::DATABASE, "Context: Loading database config from: " + configFile);

    QFile file(configFile);

    if (!file.open(QIODevice::ReadOnly))
    {
        m_logger->error(Verbose::GENERAL, "Context: Failed to open MythTV config file");
        return false;
    }

    if (!doc.setContent(&file))
    {
        file.close();
        m_logger->error(Verbose::GENERAL, "Context: Failed to read from MythTV config file");
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
        m_logger->error(Verbose::GENERAL, QString("Context: Expected 1 'Database' node but got %1").arg( nodeList.count()));
        return false;
    }

    node = nodeList.at(0);
    QString host = node.namedItem(QString("Host")).toElement().text();
    QString user = node.namedItem(QString("UserName")).toElement().text();
    QString password = node.namedItem(QString("Password")).toElement().text();
    QString dbName = node.namedItem(QString("DatabaseName")).toElement().text();
    int dbPort = node.namedItem(QString("Port")).toElement().text().toInt();

    m_mythDB = QSqlDatabase::addDatabase("QMYSQL");
    m_mythDB.setHostName(host);
    m_mythDB.setPort(dbPort);
    m_mythDB.setDatabaseName(dbName);
    m_mythDB.setUserName(user);
    m_mythDB.setPassword(password);

    bool ok = m_mythDB.open();

    if (!ok)
    {
        m_logger->error(Verbose::GENERAL, "Context: Failed to open the MythTV database using credentials from " + configFile);
        return false;
    }

    // save for future use
    m_settings->setMysqlIP(host);
    m_settings->setMysqlPort(dbPort);
    m_settings->setMysqlUser(user);
    m_settings->setMysqlPassword(password);
    m_settings->setMysqlDBName(dbName);

    m_databaseUtils->setSetting("MysqlIP", m_settings->hostName(), host);
    m_databaseUtils->setSetting("MysqlPort", m_settings->hostName(), QString::number(dbPort));
    m_databaseUtils->setSetting("MysqlUser", m_settings->hostName(), user);
    m_databaseUtils->setSetting("MysqlPassword", m_settings->hostName(), password);
    m_databaseUtils->setSetting("MysqlDBName", m_settings->hostName(), dbName);

    m_logger->error(Verbose::GENERAL, "Context: Connected to MythTV database using credentials from " + configFile);
    return true;
}

bool Context::initMythQMLDB(void)
{
    QString dbFilename = QDir::homePath() + "/.mythqml/mythqml.db";

    m_logger->info(Verbose::DATABASE, "Context: MythQML DB File is: " + dbFilename);

    // open local DB
    m_mythQMLDB = QSqlDatabase::addDatabase("QSQLITE", "mythqml");
    m_mythQMLDB.setDatabaseName(dbFilename);

    if (!m_mythQMLDB.open())
    {
        m_logger->error(Verbose::GENERAL, "Context: Failed to open MythQML DB - " + m_mythQMLDB.lastError().text());
    }

    if (!m_mythQMLDB.isOpen())
        return false;

    QSqlQuery q(m_mythQMLDB);

    if (!q.exec(QLatin1String("CREATE TABLE IF NOT EXISTS settings ("
                              "    value VARCHAR(128) PRIMARY KEY,"
                              "    data VARCHAR(16000) NOT NULL default '',"
                              "    hostname VARCHAR(64) default NULL"
                              ");")))
    {
            m_logger->error(Verbose::GENERAL, "Context: Failed to create settings table error - " + q.lastError().text());
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
        m_logger->error(Verbose::GENERAL, "Context: Failed to create recordings table error - " + q.lastError().text());
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
        m_logger->error(Verbose::GENERAL, "Context: Failed to create bookmarks table error - " + q.lastError().text());
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
        m_logger->error(Verbose::GENERAL, "Context: Failed to create tivochannels table error - " + q.lastError().text());
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
        m_logger->error(Verbose::GENERAL, "Context: Failed to create menuitems table error - " + q.lastError().text());
        return false;
    }

    return true;
}

QString Context::systemID(void)
{
    if (m_systemID.isEmpty())
    {
        m_systemID = m_databaseUtils->getSetting("SystemID", QHostInfo::localHostName());

        if (m_systemID.isEmpty())
        {
            QUuid id = QUuid::createUuid();
            m_systemID = id.toString();
            m_systemID.remove('{');
            m_systemID.remove('}');
            m_databaseUtils->setSetting("SystemID", QHostInfo::localHostName(), m_systemID);
        }
    }

    m_logger->debug(Verbose::GENERAL, "Context: SystemID - " + m_systemID);

    return m_systemID;
}

QString Context::getOSVersion(void)
{
    // try to get the  OS version from /etc/os-release
    if (!QFile::exists("/etc/os-release"))
        return QString("Unknown");

    QFile inputFile("/etc/os-release");
    if (inputFile.open(QIODevice::ReadOnly))
    {
       QTextStream in(&inputFile);
       while (!in.atEnd())
       {
          QString line = in.readLine();
          if (line.startsWith("PRETTY_NAME="))
          {
              line = line.remove("PRETTY_NAME=");
              line = line.remove("\"");
              inputFile.close();
              return line;
          }
       }
       inputFile.close();
    }

    return QString("Unknown");
}
