// qt
#include <QGuiApplication>
#include <QUrl>

// common
#include "context.h"

Context *gContext = nullptr;

int main(int argc, char *argv[])
{
     QGuiApplication app(argc, argv);

    // create the context
    gContext = new Context("MythLauncherQML");
    gContext->init();

    gContext->m_engine->load(QUrl(QString(SHAREPATH) + "qml/launcher.qml"));

    return app.exec();
}
