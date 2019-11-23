#include "logger.h"

#include <iostream>

#include <QDir>
#include <QStandardPaths>
#include <QDateTime>
#include <QDebug>

Logger::Logger(QObject* parent) : QObject(parent)
{
    m_logTime = true;
    m_logMillisec = true;
    m_toConsole = true;
    m_isEnabled = true;
    m_fileNeedsReopen = false;
    m_logLevel = Level::INFO;
    m_verbose = Verbose::ALL;
}

Logger::~Logger()
{
    m_writer.flush();
    m_file.close();
}

void Logger::setVerbose(const QString &verbose)
{
    if (verbose.isEmpty())
        return;

    uint v = Verbose::NONE;

    QStringList verboseList = verbose.split(",");

    for (int x = 0; x < verboseList.count(); x++)
    {
        if (verboseList[x].trimmed().toLower() == "all")
            v = Verbose::ALL;
        else if (verboseList[x].trimmed().toLower() == "none")
            v = Verbose::NONE;
        else if (verboseList[x].trimmed().toLower() == "model")
            v |= Verbose::MODEL;
        else if (verboseList[x].trimmed().toLower() == "process")
            v |= Verbose::PROCESS;
        else if (verboseList[x].trimmed().toLower() == "gui")
            v |= Verbose::GUI;
        else if (verboseList[x].trimmed().toLower() == "database")
            v |= Verbose::DATABASE;
        else if (verboseList[x].trimmed().toLower() == "file")
            v |= Verbose::FILE;
        else if (verboseList[x].trimmed().toLower() == "websocket")
            v |= Verbose::WEBSOCKET;
        else if (verboseList[x].trimmed().toLower() == "servicesapi")
            v |= Verbose::SERVICESAPI;
        else if (verboseList[x].trimmed().toLower() == "general")
            v |= Verbose::GENERAL;
        else if (verboseList[x].trimmed().toLower() == "playback")
            v |= Verbose::PLAYBACK;
        else if (verboseList[x].trimmed().toLower() == "network")
            v |= Verbose::NETWORK;
        else if (verboseList[x].trimmed().toLower() == "libvlc")
            v |= Verbose::LIBVLC;
        else
            error(Verbose::GENERAL, QString("Logger::setVerbose - got bad verbose '%1'").arg(verboseList[x]));
    }

    setVerbose(static_cast<Verbose>(v));
}

void Logger::setVerbose(Verbose verbose)
{
    m_verbose = verbose;

    notice(Verbose::ALL, QString("Logging: setting verbose to - %1").arg(verboseToStr(m_verbose)));
}

void Logger::setLogLevel(Level logLevel)
{
    m_logLevel = logLevel;

    notice(Verbose::ALL, QString("Logging: setting loglevel to - %1").arg(logLevelToStr(m_logLevel)));
}

void Logger::setLogLevel(const QString &logLevel)
{
    if (logLevel.isEmpty())
        return;

    if (logLevel.toLower() == "info")
        setLogLevel(Level::INFO);
    else if (logLevel.toLower() == "debug")
        setLogLevel(Level::DEBUG);
    else if (logLevel.toLower() == "error")
        setLogLevel(Level::ERROR);
    else if (logLevel.toLower() == "warning")
        setLogLevel(Level::WARNING);
    else if (logLevel.toLower() == "critical")
        setLogLevel(Level::CRITICAL);
    else
        error(Verbose::GENERAL, QString("Logger::setLogLevel - got bad loglevel '%1'").arg(logLevel));
}

inline QString Logger::linePrefix(Level logLevel)
{
    QString levelStr;
    switch (logLevel)
    {
        case Level::INFO:
            levelStr = "I";
            break;
        case Level::DEBUG:
            levelStr = "D";
            break;
        case Level::ERROR:
            levelStr = "E";
            break;
        case Level::WARNING:
            levelStr = "W";
            break;
        case Level::CRITICAL:
            levelStr = "C";
            break;
        case Level::NOTICE:
            levelStr = "N";
            break;
        default:
            levelStr = "?";
            break;
    }

    QString res = "";
    if (m_logTime)
    {
        if (m_logMillisec)
            res += QDateTime::currentDateTime().toString("yyyy-MM-dd HH:mm:ss.zzz") + " ";
        else
            res += QDateTime::currentDateTime().toString("yyyy-MM-dd HH:mm:ss") + " ";
    }

    res += levelStr + " ";

    return res;
}

void Logger::setFilename(const QString& filename)
{
    if (m_filename != filename)
    {
        m_writer.flush();
        m_file.close();

        m_filename = filename;

        m_fileNeedsReopen = true;

        emit filenameChanged();
    }
}

void Logger::info(Verbose verbose, const QString &data)
{
    log(verbose, Level::INFO, data);
}

void Logger::warning(Verbose verbose, const QString &data)
{
    log(verbose, Level::WARNING, data);
}

void Logger::notice(Verbose verbose, const QString &data)
{
    log(verbose, Level::NOTICE, data);
}

void Logger::error(Verbose verbose, const QString &data)
{
    log(verbose, Level::ERROR, data);
}

void Logger::debug(Verbose verbose, const QString &data)
{
    log(verbose, Level::DEBUG, data);
}

void Logger::critical(Verbose verbose, const QString &data)
{
    log(verbose, Level::CRITICAL, data);
}

void Logger::log(Verbose verbose, Level logLevel, const QString& data)
{
    if (!m_isEnabled)
        return;

    if (!(verbose & m_verbose))
        return;

    if (logLevel > m_logLevel)
        return;

    if (m_toConsole)
    {
        std::cout << qPrintable(linePrefix(logLevel) + data) << std::endl;
    }

    // File needs re-opening
    if (m_fileNeedsReopen)
    {
        m_file.setFileName(m_filename);

        if (!m_file.open(QIODevice::WriteOnly))
        {
            std::cout << qPrintable(linePrefix(Level::CRITICAL) + "Logger: Could not open file: " + m_file.errorString()) << std::endl;
            return;
        }
        else
            m_writer.setDevice(&m_file);

        m_fileNeedsReopen = false;
    }

    //Actual data logging
    if (m_file.isOpen())
    {
        m_writer << linePrefix(logLevel) << data << "\n";
        m_writer.flush();
    }
    else
        std::cout << qPrintable(linePrefix(Level::CRITICAL) + "Logger: File is not open, valid filename must be provided beforehand.") << std::endl;
}

QString Logger::logLevelToStr(Level logLevel)
{
    QString levelStr;
    switch (logLevel)
    {
        case Level::CRITICAL:
            levelStr = "Critical";
            break;
        case Level::ERROR:
            levelStr = "Error";
            break;
        case Level::WARNING:
            levelStr = "Warning";
            break;
        case Level::NOTICE:
            levelStr = "Critical";
            break;
        case Level::INFO:
            levelStr = "Info";
            break;
        case Level::DEBUG:
            levelStr = "Debug";
            break;
        default:
            levelStr = "Unknown";
            break;
    }

    return levelStr;
}
QString Logger::verboseToStr(Verbose verbose)
{
    QStringList verboseList;

    if (verbose == Verbose::ALL)
        return "ALL";

    if (verbose == Verbose::NONE)
        return "NONE";

    if (verbose & Verbose::DATABASE)
        verboseList.append("DATABASE");

    if (verbose & Verbose::FILE)
        verboseList.append("FILE");

    if (verbose & Verbose::GENERAL)
        verboseList.append("GENERAL");

    if (verbose & Verbose::GUI)
        verboseList.append("GUI");

    if (verbose & Verbose::LIBVLC)
        verboseList.append("LIBVLC");

    if (verbose & Verbose::MODEL)
        verboseList.append("MODEL");

    if (verbose & Verbose::NETWORK)
        verboseList.append("NETWORK");

    if (verbose & Verbose::PLAYBACK)
        verboseList.append("PLAYBACK");

    if (verbose & Verbose::PROCESS)
        verboseList.append("PROCESS");

    if (verbose & Verbose::SERVICESAPI)
        verboseList.append("SERVICESAPI");

    if (verbose & Verbose::WEBSOCKET)
        verboseList.append("WEBSOCKET");

    return verboseList.join(", ");
}
