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

// from MythNews newssite.cpp
QString MythUtils::replaceHtmlChar(const QString &orig)
{
    if (orig.isEmpty())
        return orig;

    QString s = orig;
    s.replace("&amp;", "&");
    s.replace("&lt;", "<");
    s.replace("&gt;", ">");
    s.replace("&quot;", "\"");
    s.replace("&apos;", "\'");
    s.replace("&#8220;",QChar(8220));
    s.replace("&#8221;",QChar(8221));
    s.replace("&#8230;",QChar(8230));
    s.replace("&#233;",QChar(233));
    s.replace("&mdash;", QChar(8212));
    s.replace("&nbsp;", " ");
    s.replace("&#160;", QChar(160));
    s.replace("&#225;", QChar(225));
    s.replace("&#8216;", QChar(8216));
    s.replace("&#8217;", QChar(8217));
    s.replace("&#039;", "\'");
    s.replace("&#39;", "\'");
    s.replace("&#173;", "-");
    s.replace("&ndash;", QChar(8211));

    // german umlauts
    s.replace("&auml;", QChar(0x00e4));
    s.replace("&ouml;", QChar(0x00f6));
    s.replace("&uuml;", QChar(0x00fc));
    s.replace("&Auml;", QChar(0x00c4));
    s.replace("&Ouml;", QChar(0x00d6));
    s.replace("&Uuml;", QChar(0x00dc));
    s.replace("&szlig;", QChar(0x00df));

    // links
    s.replace(QRegExp("<a href=.*/a>"), "");

    // images
    s.replace(QRegExp("<img src=.*/>"), "");

    return s;
}
