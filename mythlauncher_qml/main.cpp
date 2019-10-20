// qt
#include <QGuiApplication>
#include <QUrl>

// common
#include "context.h"

Context *gContext = nullptr;

int main(int argc, char *argv[])
{
     QGuiApplication app(argc, argv);

     QCoreApplication::setApplicationName("mythlauncher_qml");
     QCoreApplication::setApplicationVersion(APP_VERSION);

     QCommandLineParser parser;
     parser.setApplicationDescription("Experimental MythTV launcher");
     parser.addHelpOption();
     parser.addVersionOption();

     // add loglevel option
     QCommandLineOption logLevelOption(QStringList() << "l" << "loglevel",
                                              QCoreApplication::translate("main", "Set log level one of CRITICAL, ERROR, WARNING, INFO or DEBUG."),
                                              QCoreApplication::translate("main", "loglevel"));
     parser.addOption(logLevelOption);

     // add verbose option
     QCommandLineOption verboseOption(QStringList() << "d" << "verbose",
                                              QCoreApplication::translate("main", "Set verbose levels one or more of ALL, GENERAL, MODEL, PROCESS, GUI, DATABASE, FILE, WEBSOCKET, SERVICESAPI, PLAYBACK, NETWORK, LIBVLC."),
                                              QCoreApplication::translate("main", "verbose"));
     parser.addOption(verboseOption);

     // Process the command line arguments given by the user
     parser.process(app);

     QString logLevel = parser.value(logLevelOption);
     QString verbose = parser.value(verboseOption);

    // create the context
    gContext = new Context("MythLauncherQML", logLevel, verbose);

    // attempt to connect to the database
    if (!gContext->loadDBSettings())
        return 1;

    gContext->init();

    gContext->m_engine->load(QUrl(QString(SHAREPATH) + "qml/launcher.qml"));

    return app.exec();
}
