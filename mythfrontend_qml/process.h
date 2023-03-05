#include <QProcess>
#include <QVariant>

class Process : public QProcess 
{
    Q_OBJECT

public:
    Process(QObject *parent = nullptr) : QProcess(parent) { }

    Q_INVOKABLE void start(const QString &program, const QVariantList &arguments) 
    {
        QStringList args;

        // convert QVariantList from QML to QStringList for QProcess 

        for (int i = 0; i < arguments.length(); i++)
            args << arguments[i].toString();

        QProcess::start(program, args);
    }

    Q_INVOKABLE void start(const QString &program)
    {
        QProcess::start(program);
    }

    Q_INVOKABLE void stop()
    {
        QProcess::terminate();
    }

    Q_INVOKABLE QString readAll()
    {
        return QProcess::readAll();
    }

    Q_INVOKABLE QString readAllStandardError()
    {
        return QProcess::readAllStandardError();
    }

    Q_INVOKABLE QString readAllStandardOutput()
    {
        return QProcess::readAllStandardOutput();
    }

    Q_INVOKABLE int getState()
    {
        return QProcess::state();
    }

    Q_INVOKABLE bool waitForFinished(int msecs = 30000)
    {
        return QProcess::waitForFinished(msecs);
    }

    Q_INVOKABLE bool waitForStarted(int msecs = 30000)
    {
        return QProcess::waitForFinished(msecs);
    }

    Q_INVOKABLE int exitCode()
    {
        return QProcess::exitCode();
    }
};
