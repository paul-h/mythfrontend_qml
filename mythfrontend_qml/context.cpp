// qt
#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QQmlComponent>
#include <QHostInfo>
#include <QUrl>
#include <QUuid>

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

bool Context::init()
{
    m_engine = new QQmlApplicationEngine;

    QCoreApplication::setApplicationName(m_appName);

    qmlRegisterType<Process>("Process", 1, 0, "Process");

    qRegisterMetaType<Verbose>("Verbose");
    qmlRegisterUncreatableType<VerboseClass>("mythqml.net", 1, 0, "Verbose", "Not creatable as it is an enum type");

#if 0
    RegisterQmlVlc();
    QmlVlcConfig& config = QmlVlcConfig::instance();
    config.enableAdjustFilter( true );
    config.enableMarqueeFilter(false);
    config.enableLogoFilter(false);
    config.enableDebug(false);
    config.enableLoopPlayback(false);
    config.setTrustedEnvironment(true);
#endif

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

    // attempt to connect to the local mythqml database
    if (!m_databaseUtils->initMythQMLDB())
        return false;

    // create the settings
    QString hostName = QHostInfo::localHostName();
    QString theme = m_databaseUtils->getSetting("Theme", hostName, "MythCenter");
    m_settings = new Settings(hostName, theme);

    m_engine->rootContext()->setContextProperty("settings", m_settings);

    // attempt to connect to the MythTV database using our stored credentials
    if (!m_databaseUtils->initMythDB())
    {
        // failed so try to get the DB credentials from the config.xml
        if (!m_databaseUtils->loadMythDBSettings())
        {
            // failed to open MythTV database using stored/default credentials or from the mythtv config.xml file
            gContext->m_logger->error(Verbose::GENERAL, "Failed to open the MythTV database - Please make sure the "
                                                        "Mysql settings are correct on the Myth Backend settings page");
        }
    }

    // create systemid property
    m_engine->rootContext()->setContextProperty("systemid", systemID());

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
    m_engine->addUrlInterceptor(m_urlInterceptor);

    m_engine->addImportPath(QString(SHAREPATH) + "qml/Themes/Default");
    m_engine->addImportPath(QString(SHAREPATH) + "qml");

    return true;
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
