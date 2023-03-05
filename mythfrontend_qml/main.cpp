// c++
#include <stdio.h>
#include <unistd.h>

// qt
#include <QApplication>
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
#include "svgimage.h"
#include "telnet.h"
#include "fileio.h"

// shared
#include "context.h"
#include "mdkapi.h"

//#undef QT_NO_DEBUG_OUTPUT

Context *gContext = nullptr;
MDKAPI  *gMDKAPI = nullptr;
QFile outFile("log_file.txt");

int main(int argc, char *argv[])
{
//    outFile.open(QIODevice::WriteOnly | QIODevice::Append);

//    // redirect stdout
//    dup2(outFile.handle(), STDOUT_FILENO);

//    // redirect stderr
//    dup2(STDOUT_FILENO, STDERR_FILENO);


    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
    QCoreApplication::setAttribute(Qt::AA_ShareOpenGLContexts);

    QtWebEngine::initialize();

    QGuiApplication *app = new QApplication(argc, argv);

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
                                                                             "DATABASE, FILE, WEBSOCKET, SERVICESAPI, PLAYBACK, NETWORK, LIBVLC, TELNET."),
                                     QCoreApplication::translate("main", "verbose"));
    parser.addOption(verboseOption);

    // add jump option
    QCommandLineOption jumpOption(QStringList() << "j" << "jumpto",
                                     QCoreApplication::translate("main", "Jump to a screen on startup. Useful for testing to quickly jump to a screen. "
                                                                         "The name of the jump must match ones from JumpModel"),
                                     QCoreApplication::translate("main", "verbose"));
    parser.addOption(jumpOption);

    // Process the command line arguments given by the user
    parser.process(*app);

    QString logLevel = parser.value(logLevelOption);
    QString verbose = parser.value(verboseOption);

    // create the context
    gContext = new Context("MythFrontendQML", logLevel, verbose);

    // attempt to connect to the local mythqml database
    if (!gContext->initMythQMLDB())
        return 1;

    gContext->init();

    // attempt to connect to the MythTV database using our stored credentials
    if (!gContext->initMythDB())
    {
        // failed so try to get the DB credentials from the config.xml
        if (!gContext->loadMythDBSettings())
        {
            // failed to open MythTV database using stored/default credentials or from the mythtv config.xml file
            gContext->m_logger->error(Verbose::GENERAL, "Failed to open the MythTV database - Please make sure the "
                                                            "Mysql settings are correct on the Myth Backend settings page");
        }
    }

    // register our QML types
    qmlRegisterType<SvgImage>("SvgImage", 1, 0, "SvgImage");
    qmlRegisterType<FileIO, 1>("FileIO", 1, 0, "FileIO");

    // these are frontend only

    // recordings model
    qmlRegisterType<Telnet>("Telnet", 1, 0, "Telnet");

    qmlRegisterType<RecordingsModel>("RecordingsModel", 1, 0, "RecordingsModel");

    //ZoneMinder Events model
    qmlRegisterType<ZMEventsModel>("ZMEventsModel", 1, 0, "ZMEventsModel");

    // create the radio streams model
    SqlQueryModel *radioStreamsModel = new SqlQueryModel(gContext->m_engine);
    radioStreamsModel->setQuery("SELECT intid, broadcaster, channel, description, "
                                    "url1, url2, url3, url4, url5, logourl, country, "
                                    "language, genre, metaformat, format "
                                    "FROM music_radios ORDER BY broadcaster, channel", gContext->m_mythDB);
    gContext->m_engine->rootContext()->setContextProperty("radioStreamsModel", radioStreamsModel);

    // create the radio streams database model
    SqlQueryModel *radioStreamsDBModel = new SqlQueryModel(gContext->m_engine);
    radioStreamsDBModel->setQuery("SELECT intid, broadcaster, channel, description, "
                                      "url1, url2, url3, url4, url5, logourl, country, "
                                      "language, genre, metaformat "
                                      "FROM music_streams ORDER BY broadcaster, channel", gContext->m_mythDB);
    gContext->m_engine->rootContext()->setContextProperty("radioStreamsDBModel", radioStreamsDBModel);

    // create the news feed model
    SqlQueryModel *rssFeedsModel = new SqlQueryModel(gContext->m_engine);
    rssFeedsModel->setQuery("SELECT name, url, ico, updated, podcast FROM newssites ORDER BY name", gContext->m_mythDB);
    gContext->m_engine->rootContext()->setContextProperty("rssFeedsModel", rssFeedsModel);

    // create the tv channels model
    SqlQueryModel *dbChannelsModel = new SqlQueryModel(gContext->m_engine);
    dbChannelsModel->setQuery("SELECT chanid, channum, callsign, name, icon, xmltvid FROM channel ORDER BY cast(channum as unsigned);", gContext->m_mythDB);
    gContext->m_engine->rootContext()->setContextProperty("dbChannelsModel", dbChannelsModel);

    // create the optional jumpto property
    QString jumpto = parser.value(jumpOption);
    gContext->m_engine->rootContext()->setContextProperty("jumpto", QString(jumpto));

    gContext->m_engine->clearComponentCache();
    gContext->m_engine->load(QUrl(QString(SHAREPATH) + "qml/main.qml"));
    app->exec();

    delete gContext;
    delete app;

    return 0;
}
