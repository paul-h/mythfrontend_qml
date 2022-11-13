#ifndef FILEIO_H
#define FILEIO_H

#include <QObject>

class FileIO : public QObject
{
    Q_OBJECT

public:
    Q_PROPERTY(QString source READ source WRITE setSource NOTIFY sourceChanged)
    explicit FileIO(QObject *parent = 0);

    Q_INVOKABLE QString read();
    Q_INVOKABLE bool write(const QString& data);
    Q_INVOKABLE bool fileExists(void);

    QString source() { return m_source; };

public slots:
    void setSource(const QString& source);

signals:
    void sourceChanged(const QString& source);
    void error(const QString& msg);

private:
    QString m_source;
};

#endif // FILEIO_H
