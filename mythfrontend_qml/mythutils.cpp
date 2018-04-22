#include <iostream>

#include <QFile>
#include <QString>
#include <QGuiApplication>
#include <QQmlContext>
#include <QQuickWindow>
#include <QPixmap>
#include <QImage>

#include "mythutils.h"

QString MythUtils::findThemeFile(const QString &fileName)
{
    // do we have a http file
    if (fileName.startsWith("http"))
        return fileName;

    // do we have a full path
    QString f = fileName;
    if (QFile::exists(f.remove("file://")))
        return fileName;

    // look in the active theme
    if (QFile::exists(gSettings->qmlPath().remove("file://") + fileName))
        return gSettings->qmlPath() + fileName;

    // look in the default theme
    if (QFile::exists(gSettings->sharePath().remove("file://") + "qml/Themes/default-wide/" + fileName))
        return gSettings->sharePath() + "qml/Themes/default-wide/" + fileName;

    // not found
    return QString();
}

bool MythUtils::grabScreen(const QString& fileName)
{
    QQuickWindow *qw = dynamic_cast<QQuickWindow*>(m_engine->rootObjects().first());

    if (!qw)
    {
        return false;
    }

    QImage image = qw->grabWindow();

    if (image.isNull())
        return false;

    return image.save(fileName, "PNG");
}

bool MythUtils::fileExists(const QString& fileName)
{
    return QFile::exists(fileName);
}

QDateTime MythUtils::addMinutes(const QDateTime& dateTime, int minutes)
{
    return dateTime.addSecs(minutes * 60);
}

