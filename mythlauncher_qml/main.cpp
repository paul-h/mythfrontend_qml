// qt
#include <QGuiApplication>
#include <QUrl>

// common
#include "context.h"
#include "mdkapi.h"

// mythfrontend_qml
#include "sqlquerymodel.h"

Context *gContext = nullptr;
MDKAPI  *gMDKAPI = nullptr;

int main(int argc, char *argv[])
{
    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
    QCoreApplication::setAttribute(Qt::AA_ShareOpenGLContexts);

    QGuiApplication *app = new QGuiApplication(argc, argv);

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

    // add frontend option
    QCommandLineOption frontendOption(QStringList() << "f" << "frontend",
                                     QCoreApplication::translate("main", "Frontend to auto start. Options are QML, LEGACY, NETFLIX, PLUTO, NONE."),
                                     QCoreApplication::translate("main", "frontend"));
    parser.addOption(frontendOption);

    // Process the command line arguments given by the user
    parser.process(*app);

    QString logLevel = parser.value(logLevelOption);
    QString verbose = parser.value(verboseOption);
    QString frontend = parser.value(frontendOption);

    // create the context
    gContext = new Context("MythLauncherQML", logLevel, verbose);

    if (!gContext->init())
        return 1;

    // register our QML types
    qmlRegisterType<SqlQueryModel, 1>("SqlQueryModel", 1, 0, "SqlQueryModel");

    if (frontend != "")
        gContext->m_engine->setInitialProperties({{"showFrontend", QVariant::fromValue(frontend)}});

    gContext->m_engine->load(QUrl(QString(SHAREPATH) + "qml/launcher.qml"));

    app->exec();

    delete gContext;
    delete app;

    return 0;
}
