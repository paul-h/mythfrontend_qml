/*
    telnetclient, Telnet Client
*/

#ifndef TELNET_H
#define TELNET_H
#include <QObject>
#include "qttelnet.h"

class Telnet : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString version READ readVersion NOTIFY versionChanged())
    Q_PROPERTY(QString data READ readData NOTIFY dataChanged())
    Q_PROPERTY(bool connected READ readConnected NOTIFY connectedChanged())
    Q_PROPERTY(bool connecting READ readConnecting NOTIFY connectingChanged())

public:
    explicit Telnet(QObject *parent = 0);
    ~Telnet();

    QString readVersion();
    QString readData() { return m_data; }
    bool readConnected() { return m_connected; }
    bool readConnecting() { return m_connecting; }

    Q_INVOKABLE void connectToTelnet(QString host);
    Q_INVOKABLE void telnetSend(QString data);
    Q_INVOKABLE void disconnectTelnet();

signals:
    void versionChanged();
    void dataChanged();
    void connectedChanged();
    void connectingChanged();

public slots:
    void telnetConnected();
    void telnetError(QAbstractSocket::SocketError);
    void telnetReceive(const QString &data);

private:

    QtTelnet* t;
    QString m_data;
    bool m_connected;
    bool m_connecting;
};


#endif // TELNET_H

