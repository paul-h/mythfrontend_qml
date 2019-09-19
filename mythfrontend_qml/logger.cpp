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
    m_verbosity = Verbose::ALL;
}

Logger::~Logger()
{
    m_writer.flush();
    m_file.close();
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

void Logger::info(Verbose verbosity, const QString &data)
{
    log(verbosity, Level::INFO, data);
}

void Logger::warning(Verbose verbosity, const QString &data)
{
    log(verbosity, Level::WARNING, data);
}

void Logger::error(Verbose verbosity, const QString &data)
{
    log(verbosity, Level::ERROR, data);
}

void Logger::debug(Verbose verbosity, const QString &data)
{
    log(verbosity, Level::DEBUG, data);
}

void Logger::critical(Verbose verbosity, const QString &data)
{
    log(verbosity, Level::CRITICAL, data);
}

void Logger::log(Verbose verbosity, Level logLevel, const QString& data)
{
    if (!m_isEnabled)
        return;

    if (!(verbosity & m_verbosity))
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
        QDir dir(m_filename);
        if (dir.isAbsolute())
            std::cout << qPrintable(linePrefix(Level::INFO) + "Logger: Opening " + m_filename + " to log") << std::endl;
        else
        {
            m_filename =
                #if defined(Q_OS_WIN)
                    QStandardPaths::writableLocation(QStandardPaths::StandardLocation::AppDataLocation)
                #else
                    QStandardPaths::writableLocation(QStandardPaths::StandardLocation::DocumentsLocation)
                #endif
                + "/" + m_filename;
            std::cout << qPrintable(linePrefix(Level::INFO) + "Logger: Absolute path not given, opening " + m_filename + " to log.") << std::endl;
            emit filenameChanged();
        }
        QDir::root().mkpath(QFileInfo(m_filename).absolutePath());

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
