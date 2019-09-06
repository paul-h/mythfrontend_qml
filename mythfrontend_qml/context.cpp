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
#include <QDebug>

// common
#include "databaseutils.h"
#include "mythutils.h"
#include "settings.h"
#include "urlinterceptor.h"
#include "process.h"
#include "keypresslistener.h"
#include "context.h"

// from QmlVlc
#include <QmlVlc.h>
#include <QmlVlc/QmlVlcConfig.h>

Context::Context(const QString &appName, QObject *parent) : QObject(parent)
{
    m_appName = appName;
    m_engine = nullptr;
    m_settings = nullptr;
    m_databaseUtils = nullptr;
    m_mythUtils = nullptr;
    m_kpl = nullptr;
    m_urlInterceptor = nullptr;
}

Context::~Context(void)
{
    delete m_engine;
    delete m_settings;
    delete m_databaseUtils;
    delete m_mythUtils;
    delete m_kpl;
    delete m_urlInterceptor;
}

void Context::init()
{
    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);

    QtWebEngine::initialize();

    QCoreApplication::setApplicationName(m_appName);
    QCoreApplication::setAttribute(Qt::AA_X11InitThreads);

    qDebug() << "Starting " + m_appName + ": version " << APP_VERSION;
    qmlRegisterType<Process>("Process", 1, 0, "Process");

    RegisterQmlVlc();
    QmlVlcConfig& config = QmlVlcConfig::instance();
    config.enableAdjustFilter( true );
    config.enableMarqueeFilter(false);
    config.enableLogoFilter(false);
    config.enableDebug(false);
    config.enableLoopPlayback(false);
    config.setTrustedEnvironment(true);

    m_engine = new QQmlApplicationEngine;

    // create version property
    m_engine->rootContext()->setContextProperty("version", QString(APP_VERSION));

    // create the build time property
    m_engine->rootContext()->setContextProperty("buildtime", QString("%1 - %2").arg(__DATE__).arg(__TIME__));

    // create the database utils
    m_databaseUtils = new DatabaseUtils();
    m_engine->rootContext()->setContextProperty("dbUtils", m_databaseUtils);

    QString hostName = QHostInfo::localHostName();
    QString theme = m_databaseUtils->getSetting("Qml_theme", hostName, "MythCenter-wide");

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

    // create keypresslistener
    m_kpl = new KeyPressListener;
    m_engine->rootContext()->setContextProperty("keyPressListener", m_kpl);

    // create URL interceptor
    m_urlInterceptor = new MythQmlAbstractUrlInterceptor(m_engine);
    m_urlInterceptor->setTheme(theme);
    m_engine->setUrlInterceptor(m_urlInterceptor);

    m_engine->addImportPath(QString(SHAREPATH) + "qml/Themes/default-wide");
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
        qDebug() << "ERROR: Unable to find config file\nYou need to put a valid config.xml file at: ~/.mythqml/config.xml";
        return false;
    }

    qDebug() << "Loading database config from: " << configFile;

    QFile file(configFile);

    if (!file.open(QIODevice::ReadOnly))
    {
        qDebug() << "Failed to open config file";
        return false;
    }

    if (!doc.setContent(&file))
    {
        file.close();
        qDebug() << "Failed to read from config file";
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
        qDebug() << "Expected 1 'Database' node but got " << nodeList.count();
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
        qDebug() << "Failed to open the database";
        return false;
    }

    return true;
}
