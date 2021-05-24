// c/c++
#include <iostream>

// qt
#include <QDebug>
#include <QFile>

// common
#include "context.h"
#include "urlinterceptor.h"

QUrl MythQmlAbstractUrlInterceptor::intercept(const QUrl &url, DataType type)
{
    if (type != QQmlAbstractUrlInterceptor::QmlFile)
        return url;

    QString sUrl = url.toString();

    gContext->m_logger->debug(Verbose::FILE, QString("MythQmlAbstractUrlInterceptor::intercept: looking for: '%1'").arg(sUrl));

    // we are only interested in our theme urls
    if (!sUrl.startsWith(gContext->m_settings->sharePath()) || sUrl.endsWith("qmldir"))
    {
        gContext->m_logger->debug(Verbose::FILE, QString("MythQmlAbstractUrlInterceptor::intercept: not one of our URLs ignoring"));
        return url;
    }

    // look in the map first
    if (m_fileMap.contains(sUrl))
    {
        gContext->m_logger->debug(Verbose::FILE, QString("MythQmlAbstractUrlInterceptor::intercept: found in map - result: '%1'").arg("file://" + sUrl));
        return QUrl("file://" + m_fileMap.value(sUrl));
    }

    QString fileName = sUrl;

    if (fileName.startsWith(m_defaultThemePath))
        fileName.remove(m_defaultThemePath);

    if (fileName.startsWith(m_activeThemePath))
        fileName.remove(m_activeThemePath);

    // special case for Theme.qml files - look at the top level theme directory
    if (fileName.endsWith("/Theme.qml"))
    {
        QString searchURL = m_activeThemePath + "/Theme.qml";

        if (QFile::exists(searchURL.remove("file://")))
        {
            m_fileMap.insert(sUrl, searchURL);
            gContext->m_logger->debug(Verbose::FILE, QString("MythQmlAbstractUrlInterceptor::intercept: found themes Theme.qml - result: '%1'").arg("file://" + searchURL));
            return QUrl("file://" + searchURL);
        }
    }

    // look up in the active theme
    if (!m_defaultThemePath.isEmpty())
    {
        QString searchURL = m_activeThemePath + fileName;

        if (QFile::exists(searchURL.remove("file://")))
        {
            m_fileMap.insert(sUrl, searchURL);
            gContext->m_logger->debug(Verbose::FILE, QString("MythQmlAbstractUrlInterceptor::intercept: found in active theme - result: '%1'").arg("file://" + searchURL));
            return QUrl("file://" + searchURL);
        }
    }

    // look up in the default theme
    if (!m_defaultThemePath.isEmpty())
    {
        QString searchURL = m_defaultThemePath + fileName;

        if (QFile::exists(searchURL.remove("file://")))
        {
            m_fileMap.insert(sUrl, searchURL);
            gContext->m_logger->debug(Verbose::FILE, QString("MythQmlAbstractUrlInterceptor::intercept: found in default theme - result: '%1'").arg("file://" + searchURL));
            return QUrl("file://" + searchURL);
        }
    }

    // fall back to the original url
    m_fileMap.insert(sUrl, sUrl);
    gContext->m_logger->debug(Verbose::FILE, QString("MythQmlAbstractUrlInterceptor::intercept: not found using original URL - result: '%1'").arg(sUrl));
    return url;
}

void MythQmlAbstractUrlInterceptor::setTheme(const QString& theme)
{
   m_theme = theme;

   m_defaultThemePath = gContext->m_settings->sharePath() + "qml/Themes/Default";
   m_activeThemePath = gContext->m_settings->sharePath() + "qml/Themes/" + m_theme;

   m_fileMap.clear();
}
