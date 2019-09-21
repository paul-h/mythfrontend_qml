// qt
#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QQmlComponent>
#include <QHostInfo>
#include <QtWebEngine>
#include <QUrl>
#include <QDomDocument>
#include <QFile>
#include <QDir>

// common
#include "databaseutils.h"
#include "mythutils.h"
#include "settings.h"
#include "urlinterceptor.h"
#include "process.h"
#include "eventlistener.h"
#include "context.h"

// from QmlVlc
#include <QmlVlc.h>
#include <QmlVlc/QmlVlcConfig.h>

Context::Context(const QString &appName, QObject *parent) : QObject(parent)
{
    m_appName = appName;
    m_logger = nullptr;
    m_engine = nullptr;
    m_settings = nullptr;
    m_databaseUtils = nullptr;
    m_mythUtils = nullptr;
    m_eventListener = nullptr;
    m_urlInterceptor = nullptr;

    // create the logger
    m_logger = new Logger();
    m_logger->setFilename(QString("/var/log/mythqml/%1.log").arg(m_appName));
    //m_logger->setVerbosity(Verbose::GENERAL | Verbose::GUI | Verbose::FILE | Verbose::PROCESS | Verbose::DATABASE | Verbose::PLAYBACK | Verbose::WEBSOCKET | Verbose::SERVICESAPI);
    m_logger->setVerbosity(Verbose::ALL);
    m_logger->setLogLevel(Level::INFO);

    m_logger->info(Verbose::GENERAL, QString("Starting ") + m_appName + ": version " + APP_VERSION);
}

Context::~Context(void)
{
    delete m_engine;
    delete m_settings;
    delete m_databaseUtils;
    delete m_mythUtils;
    delete m_eventListener;
    delete m_urlInterceptor;
    delete m_logger;
}

void Context::init()
{
    m_engine = new QQmlApplicationEngine;

    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);

    QtWebEngine::initialize();

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

    // create the logger for QML
    m_engine->rootContext()->setContextProperty("log", m_logger);

    // create version property
    m_engine->rootContext()->setContextProperty("version", QString(APP_VERSION));

    // create the Qt version property
    m_engine->rootContext()->setContextProperty("qtversion", QString(qVersion()));

    // create the build time property
    m_engine->rootContext()->setContextProperty("buildtime", QString("%1 - %2").arg(__DATE__).arg(__TIME__));

    // create the database utils
    m_databaseUtils = new DatabaseUtils();
    m_engine->rootContext()->setContextProperty("dbUtils", m_databaseUtils);

    QString hostName = QHostInfo::localHostName();
    QString theme = m_databaseUtils->getSetting("Qml_theme", hostName, "MythCenter");

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

bool Context::loadDBSettings(void)
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
        m_logger->error(Verbose::GENERAL, "ERROR: Unable to find config file.You need to put a valid config.xml file at: ~/.mythqml/config.xml");
        return false;
    }

    m_logger->info(Verbose::DATABASE, "Loading database config from: " + configFile);

    QFile file(configFile);

    if (!file.open(QIODevice::ReadOnly))
    {
        m_logger->error(Verbose::GENERAL, "Failed to open config file");
        return false;
    }

    if (!doc.setContent(&file))
    {
        file.close();
        m_logger->error(Verbose::GENERAL, "Failed to read from config file");
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
        m_logger->error(Verbose::GENERAL, "Expected 1 'Database' node but got " + nodeList.count());
        return false;
    }

    node = nodeList.at(0);
    m_dbHost = node.namedItem(QString("Host")).toElement().text();
    m_dbUser = node.namedItem(QString("UserName")).toElement().text();
    m_dbPassword = node.namedItem(QString("Password")).toElement().text();
    m_dbName = node.namedItem(QString("DatabaseName")).toElement().text();
    m_dbPort = node.namedItem(QString("Port")).toElement().text();

    m_db = QSqlDatabase::addDatabase("QMYSQL");
    m_db.setHostName(m_dbHost);
    m_db.setDatabaseName(m_dbName);
    m_db.setUserName(m_dbUser);
    m_db.setPassword(m_dbPassword);
    bool ok = m_db.open();

    if (!ok)
    {
        m_logger->error(Verbose::GENERAL, "Failed to open the database");
        return false;
    }

    return true;
}
