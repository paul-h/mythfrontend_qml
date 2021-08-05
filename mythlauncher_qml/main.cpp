// qt
#include <QGuiApplication>
#include <QUrl>

// common
#include "context.h"
#include "mdkapi.h"

Context *gContext = nullptr;
MDKAPI  *gMDKAPI = nullptr;

int main(int argc, char *argv[])
{
    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
    QCoreApplication::setAttribute(Qt::AA_ShareOpenGLContexts);

     QGuiApplication app(argc, argv);

     QCoreApplication::setApplicationName("mythlauncher_qml");
     QCoreApplication::setApplicationVersion(APP_VERSION);

     QCommandLineParser parser;
     parser.setApplicationDescription("Experimental MythTV launcher");
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
    gContext = new Context("MythLauncherQML", logLevel, verbose);

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

    gContext->m_engine->load(QUrl(QString(SHAREPATH) + "qml/launcher.qml"));

    return app.exec();
}
