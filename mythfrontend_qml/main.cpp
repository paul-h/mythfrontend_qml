// qt
#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QQmlComponent>
#include <QHostInfo>
#include <QDomDocument>
#include <QFile>
#include <QDir>
#include <QtWebEngine>
#include <QUrl>

// mythfrontend_qml
#include "recordingsmodel.h"
#include "zmeventsmodel.h"
#include "sqlquerymodel.h"

// shared
#include "context.h"

//#undef QT_NO_DEBUG_OUTPUT

Context *gContext = nullptr;

int main(int argc, char *argv[])
{
    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
    QCoreApplication::setAttribute(Qt::AA_ShareOpenGLContexts);

    QGuiApplication app(argc, argv);

    QCoreApplication::setApplicationName("mythfrontend_qml");
    QCoreApplication::setApplicationVersion(APP_VERSION);

    QCommandLineParser parser;
    parser.setApplicationDescription("Experimental MythTV client");
    parser.addHelpOption();
    parser.addVersionOption();

    // add loglevel option
    QCommandLineOption logLevelOption(QStringList() << "l" << "loglevel",
                                      QCoreApplication::translate("main", "Set log level one of CRITICAL, ERROR, WARNING, NOTICE, INFO or DEBUG."),
                                      QCoreApplication::translate("main", "loglevel"));
    parser.addOption(logLevelOption);

    // add verbose option
    QCommandLineOption verboseOption(QStringList() << "d" << "verbose",
                                     QCoreApplication::translate("main", "Set verbose levels one or more of ALL, GENERAL, MODEL, PROCESS, GUI, "
                                                                         "DATABASE, FILE, WEBSOCKET, SERVICESAPI, PLAYBACK, NETWORK, LIBVLC."),
                                     QCoreApplication::translate("main", "verbose"));
    parser.addOption(verboseOption);

    // Process the command line arguments given by the user
    parser.process(app);

    QString logLevel = parser.value(logLevelOption);
    QString verbose = parser.value(verboseOption);

    // create the context
    gContext = new Context("MythFrontendQML", logLevel, verbose);

    // attempt to connect to the database
    if (!gContext->loadDBSettings())
        return 1;

    gContext->init();

    // these are frontend only

    // recordings model
    qmlRegisterType<RecordingsModel>("RecordingsModel", 1, 0, "RecordingsModel");

    //ZoneMinder Events model
    qmlRegisterType<ZMEventsModel>("ZMEventsModel", 1, 0, "ZMEventsModel");

    // create the radio streams model
    SqlQueryModel *radioStreamsModel = new SqlQueryModel(gContext->m_engine);
    radioStreamsModel->setQuery("SELECT intid, broadcaster, channel, description, "
                                "url1, url2, url3, url4, url5, logourl, country, "
                                "language, genre, metaformat, format "
                                "FROM music_radios ORDER BY broadcaster, channel", gContext->m_db);
    gContext->m_engine->rootContext()->setContextProperty("radioStreamsModel", radioStreamsModel);

    // create the radio streams database model
    SqlQueryModel *radioStreamsDBModel = new SqlQueryModel(gContext->m_engine);
    radioStreamsDBModel->setQuery("SELECT intid, broadcaster, channel, description, "
                                "url1, url2, url3, url4, url5, logourl, country, "
                                "language, genre, metaformat "
                                "FROM music_streams ORDER BY broadcaster, channel", gContext->m_db);
    gContext->m_engine->rootContext()->setContextProperty("radioStreamsDBModel", radioStreamsDBModel);

    // create the news feed model
    SqlQueryModel *rssFeedsModel = new SqlQueryModel(gContext->m_engine);
    rssFeedsModel->setQuery("SELECT name, url, ico, updated, podcast FROM newssites ORDER BY name", gContext->m_db);
    gContext->m_engine->rootContext()->setContextProperty("rssFeedsModel", rssFeedsModel);

    // create the tv channels model
    SqlQueryModel *dbChannelsModel = new SqlQueryModel(gContext->m_engine);
    dbChannelsModel->setQuery("SELECT chanid, channum, callsign, name, icon, xmltvid FROM channel ORDER BY cast(channum as unsigned);", gContext->m_db);
    gContext->m_engine->rootContext()->setContextProperty("dbChannelsModel", dbChannelsModel);

    // load the main screen
    gContext->m_engine->load(QUrl(QString(SHAREPATH) + "qml/main.qml"));

    return app.exec();
}
