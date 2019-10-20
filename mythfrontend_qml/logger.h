#ifndef LOGGER_H
#define LOGGER_H


#include <QString>
#include <QFile>
#include <QTextStream>

class VerboseClass
{
    Q_GADGET
public:
    enum Value
    {
        ALL =         0xffffffff,
        NONE =        0x00000000,
        GENERAL =     0x00000001,
        MODEL =       0x00000002,
        PROCESS =     0x00000004,
        GUI =         0x00000008,
        DATABASE =    0x00000010,
        FILE =        0x00000020,
        WEBSOCKET =   0x00000040,
        SERVICESAPI = 0x00000080,
        PLAYBACK =    0x00000100,
        NETWORK =     0x00000200,
        LIBVLC =      0x00000400
    };
    Q_ENUM(Value)

private:
    explicit VerboseClass() { }
};

typedef VerboseClass::Value Verbose;

class LevelClass
{
    Q_GADGET
public:
    enum Value
    {
        CRITICAL = 1,
        ERROR = 2,
        WARNING = 3,
        NOTICE = 4,
        INFO = 5,
        DEBUG = 6,
    };
    Q_ENUM(Value)

private:
    explicit LevelClass() { }
};

typedef LevelClass::Value Level;

class Logger : public QObject
{
    Q_OBJECT

    Q_PROPERTY(QString filename READ filename WRITE setFilename NOTIFY filenameChanged)
    Q_PROPERTY(bool logTime READ logTime WRITE setLogTime NOTIFY logTimeChanged)
    Q_PROPERTY(bool logMillisec READ logMillisec WRITE setLogMillisec NOTIFY logMillisecChanged)
    Q_PROPERTY(bool toConsole READ toConsole WRITE setToConsole NOTIFY toConsoleChanged)
    Q_PROPERTY(bool isEnabled READ isEnabled WRITE setIsEnabled NOTIFY isEnabledChanged)
    Q_PROPERTY(Verbose verbose READ verbose WRITE setVerbose NOTIFY verboseChanged)
    Q_PROPERTY(Level logLevel READ logLevel WRITE setLogLevel NOTIFY logLevelChanged)

public:

    Logger(QObject *parent = nullptr);
    ~Logger();

    Verbose verbose() { return m_verbose; }
    void setVerbose(Verbose verbose);
    void setVerbose(const QString &verbose);

    Level logLevel() { return m_logLevel; }
    void setLogLevel(Level logLevel);
    void setLogLevel(const QString &verbose);

    QString filename() { return m_filename; }
    void setFilename(const QString& filename);

    bool logTime() { return m_logTime; }
    void setLogTime(bool logTime) { m_logTime = logTime; emit logTimeChanged(); }

    bool logMillisec() { return m_logMillisec; }
    void setLogMillisec(bool logMillisec) { m_logMillisec = logMillisec; emit logMillisecChanged(); }

    bool toConsole() { return m_toConsole; }
    void setToConsole(bool toConsole) { m_toConsole = toConsole; emit toConsoleChanged(); }

    bool isEnabled() { return m_isEnabled; }
    void setIsEnabled(bool isEnabled) { m_isEnabled = isEnabled; emit isEnabledChanged(); }

signals:

    void filenameChanged();
    void logTimeChanged();
    void logMillisecChanged();
    void toConsoleChanged();
    void isEnabledChanged();
    void verboseChanged();
    void logLevelChanged();

public slots:
    void log(Verbose verbose, Level logLevel, const QString& data);
    void critical(Verbose verbose, const QString& data);
    void error(Verbose verbose, const QString& data);
    void warning(Verbose verbose, const QString& data);
    void notice(Verbose verbose, const QString& data);
    void info(Verbose verbose, const QString& data);
    void debug(Verbose verbose, const QString& data);

private:
    QString linePrefix(Level logLevel);
    QString logLevelToStr(Level logLevel);
    QString verboseToStr(Verbose verbose);

    Level m_logLevel;
    Verbose m_verbose;
    bool m_isEnabled;
    bool m_toConsole;
    bool m_logTime;
    bool m_logMillisec;
    QString m_filename;
    bool m_fileNeedsReopen;

    QFile m_file;
    QTextStream m_writer;
};

#endif // LOGGER_H
