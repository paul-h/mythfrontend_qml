// qt
#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QQmlComponent>
#include <QDebug>
#include <QHostInfo>
#include <QDomDocument>
#include <QFile>
#include <QDir>
#include <QtWebEngine>
#include <QUrl>

// from QmlVlc
#include <QmlVlc.h>
#include <QmlVlc/QmlVlcConfig.h>

// mythfrontend_qml
#include "recordingsmodel.h"
#include "sqlquerymodel.h"
#include "databaseutils.h"
#include "mythutils.h"
#include "settings.h"
#include "urlinterceptor.h"
#include "process.h"
#include "keypresslistener.h"

#define SHAREPATH "file:///usr/share/mythtv/"

static QString dbHost;
static QString dbPort;
static QString dbUser;
static QString dbPassword;
static QString dbName;

//#undef QT_NO_DEBUG_OUTPUT

Settings *gSettings = NULL;

static bool loadDBSettings(void)
{
    QDomDocument doc("mydocument");
    QFile file(QDir::homePath() + "/.mythtv/config.xml");
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
    QDomNodeList dbNodeList;
    QDomNode node;
    QDomElement elem;

    dbNodeList = doc.elementsByTagName("Database");

    if (dbNodeList.count() != 1)
    {
        qDebug() << "Expected 1 'Database' node but got " << dbNodeList.count();
        return false;
    }

    node = dbNodeList.at(0);
    dbHost = node.namedItem(QString("Host")).toElement().text();
    dbUser = node.namedItem(QString("UserName")).toElement().text();
    dbPassword = node.namedItem(QString("Password")).toElement().text();
    dbName = node.namedItem(QString("DatabaseName")).toElement().text();
    dbPort = node.namedItem(QString("Port")).toElement().text();

    return true;
}

int main(int argc, char *argv[])
{
    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
    QGuiApplication app(argc, argv);

    QtWebEngine::initialize();

    QCoreApplication::setApplicationName("MythFrontendQML");
    QCoreApplication::setAttribute(Qt::AA_X11InitThreads);

    qmlRegisterType<Process>("Process", 1, 0, "Process");
    qmlRegisterType<RecordingsModel>("RecordingsModel", 1, 0, "RecordingsModel");

    RegisterQmlVlc();
    QmlVlcConfig& config = QmlVlcConfig::instance();
    config.enableAdjustFilter( true );
    config.enableMarqueeFilter(false);
    config.enableLogoFilter(false);
    config.enableDebug(false);
    config.enableLoopPlayback(false);
    config.setTrustedEnvironment(true);

    QQmlApplicationEngine engine;

    // get the database login details from ~/.mythtv/config.xml
    if (!loadDBSettings())
    {
        qDebug() << "Failed to load database config";
        return 1;
    }

    QSqlDatabase db = QSqlDatabase::addDatabase("QMYSQL");
    db.setHostName(dbHost);
    db.setDatabaseName(dbName);
    db.setUserName(dbUser);
    db.setPassword(dbPassword);
    bool ok = db.open();

    if (!ok)
    {
        qDebug() << "Failed to open the database";
        return 1;
    }

    // create the database utils
    DatabaseUtils databaseUtils(db);
    engine.rootContext()->setContextProperty("dbUtils", &databaseUtils);

    QString hostName = QHostInfo::localHostName();
    QString theme = databaseUtils.getSetting("Qml_theme", hostName, "MythCenter-wide");

    // create the settings
    gSettings = new Settings;

    gSettings->setThemeName(theme);
    gSettings->setHostName(hostName);
    gSettings->setConfigPath(QDir::homePath() + "/.mythtv/");
    gSettings->setSharePath(QString(SHAREPATH));
    gSettings->setQmlPath(QString(SHAREPATH) + "qml/Themes/" + theme + "/");
    gSettings->setMasterBackend(databaseUtils.getSetting("Qml_masterBackend", hostName));
    gSettings->setVideoPath(databaseUtils.getSetting("Qml_videoPath", hostName));
    gSettings->setPicturePath(databaseUtils.getSetting("Qml_picturePath", hostName));
    gSettings->setSdChannels(databaseUtils.getSetting("Qml_sdChannels", hostName));
    gSettings->setWebcamPath(databaseUtils.getSetting("Qml_webcamPath", hostName));

    // set the websocket url using the master backend as a starting point
    QUrl url(gSettings->masterBackend());
    url.setScheme("ws");
    url.setPort(url.port() + 5);
    gSettings->setWebSocketUrl(url.toString());

    // start fullscreen
    gSettings->setStartFullscreen((databaseUtils.getSetting("Qml_startFullScreen", hostName) == "true"));

    // vbox
    gSettings->setVboxFreeviewIP(databaseUtils.getSetting("Qml_vboxFreeviewIP", hostName));
    gSettings->setVboxFreesatIP(databaseUtils.getSetting("Qml_vboxFreesatIP", hostName));

    // hdmiEncoder
    gSettings->setHdmiEncoder(databaseUtils.getSetting("Qml_hdmiEncoder", hostName));

    // look for the theme in ~/.mythtv/themes
    if (QFile::exists(QString(QDir::homePath() + "/.mythtv/themes/") + theme + "/themeinfo.xml"))
        gSettings->setThemePath(QString(QDir::homePath() + "/.mythtv/themes/") + theme + "/");
    else
        gSettings->setThemePath(QString(SHAREPATH) + "themes/" + theme + "/");

    // menu theme
    QString menuTheme = "classic"; // just use this for now
    gSettings->setMenuPath(QString(SHAREPATH) + "qml/MenuThemes/" + menuTheme + "/");

    // show text borders debug flag
    gSettings->setShowTextBorder(false);

    engine.rootContext()->setContextProperty("settings", gSettings);

    // create the myth utils
    MythUtils mythUtils(&engine);
    engine.rootContext()->setContextProperty("mythUtils", &mythUtils);

    // create keypresslistener
    KeyPressListener kpl;
    engine.rootContext()->setContextProperty("keyPressListener", &kpl);

    // create the radio streams model
    SqlQueryModel *radioStreamsModel = new SqlQueryModel(&engine);
    radioStreamsModel->setQuery("SELECT intid, broadcaster, channel, description, "
                                "url1, url2, url3, url4, url5, logourl, country, "
                                "language, genre, metaformat, format "
                                "FROM music_radios ORDER BY broadcaster, channel", db);
    engine.rootContext()->setContextProperty("radioStreamsModel", radioStreamsModel);

    // create the radio streams database model
    SqlQueryModel *radioStreamsDBModel = new SqlQueryModel(&engine);
    radioStreamsDBModel->setQuery("SELECT intid, broadcaster, channel, description, "
                                "url1, url2, url3, url4, url5, logourl, country, "
                                "language, genre, metaformat "
                                "FROM music_streams ORDER BY broadcaster, channel", db);
    engine.rootContext()->setContextProperty("radioStreamsDBModel", radioStreamsDBModel);

    // create the news feed model
    SqlQueryModel *rssFeedsModel = new SqlQueryModel(&engine);
    rssFeedsModel->setQuery("SELECT name, url, ico, updated, podcast FROM newssites ORDER BY name", db);
    engine.rootContext()->setContextProperty("rssFeedsModel", rssFeedsModel);

    // create the tv channels model
    SqlQueryModel *dbChannelsModel = new SqlQueryModel(&engine);
    dbChannelsModel->setQuery("SELECT chanid, channum, callsign, name, icon, xmltvid FROM channel ORDER BY cast(channum as unsigned);", db);
    engine.rootContext()->setContextProperty("dbChannelsModel", dbChannelsModel);

    MythQmlAbstractUrlInterceptor interceptor(&engine);
    interceptor.setTheme(theme);
    engine.setUrlInterceptor(&interceptor);

    engine.addImportPath(QString(SHAREPATH) + "qml/Themes/default-wide");

    engine.load(QUrl(QString(SHAREPATH) + "qml/main.qml"));

    return app.exec();
}

