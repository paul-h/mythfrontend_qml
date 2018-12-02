#include <QProcess>
#include <QVariant>

class Process : public QProcess 
{
    Q_OBJECT

public:
    Process(QObject *parent = 0) : QProcess(parent) { }

    Q_INVOKABLE void start(const QString &program, const QVariantList &arguments) 
    {
        QStringList args;

        // convert QVariantList from QML to QStringList for QProcess 

        for (int i = 0; i < arguments.length(); i++)
            args << arguments[i].toString();

        QProcess::start(program, args);
    }

    Q_INVOKABLE void stop()
    {
        QProcess::terminate();
    }

    Q_INVOKABLE QByteArray readAll()
    {
        return QProcess::readAll();
    }

    Q_INVOKABLE int getState()
    {
        return QProcess::state();
    }

    Q_INVOKABLE bool waitForFinished(int msecs = 30000)
    {
        return QProcess::waitForFinished(msecs);
    }
};
