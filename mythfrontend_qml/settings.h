#pragma once
#include <QObject>

// this is where we find all our qml files etc.
#define SHAREPATH "file:///usr/share/mythtv/"

class Settings : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString themeName READ themeName WRITE setThemeName NOTIFY themeNameChanged)
    Q_PROPERTY(QString hostName READ hostName WRITE setHostName NOTIFY hostNameChanged)
    Q_PROPERTY(QString masterIP READ masterIP WRITE setMasterIP NOTIFY masterIPChanged)
    Q_PROPERTY(int     masterPort READ masterPort WRITE setMasterPort NOTIFY masterPortChanged)
    Q_PROPERTY(QString masterBackend READ masterBackend NOTIFY masterBackendChanged)
    Q_PROPERTY(QString securityPin READ securityPin  WRITE setSecurityPin  NOTIFY securityPinChanged)
    Q_PROPERTY(QString configPath READ configPath WRITE setConfigPath NOTIFY configPathChanged)
    Q_PROPERTY(QString sharePath READ sharePath WRITE setSharePath NOTIFY sharePathChanged)
    Q_PROPERTY(QString qmlPath READ qmlPath WRITE setQmlPath NOTIFY qmlPathChanged)
    Q_PROPERTY(QString menuPath READ menuPath WRITE setMenuPath NOTIFY menuPathChanged)

    Q_PROPERTY(QString webSocketUrl READ webSocketUrl WRITE setWebSocketUrl NOTIFY webSocketUrlChanged)
    Q_PROPERTY(QString videoPath READ videoPath WRITE setVideoPath NOTIFY videoPathChanged)
    Q_PROPERTY(QString picturePath READ picturePath WRITE setPicturePath NOTIFY picturePathChanged)
    Q_PROPERTY(QString sdChannels READ sdChannels WRITE setSdChannels NOTIFY sdChannelsChanged)
    Q_PROPERTY(bool    startFullscreen READ startFullscreen WRITE setStartFullscreen NOTIFY startFullscreenChanged)
    Q_PROPERTY(QString webcamPath READ webcamPath WRITE setWebcamPath NOTIFY webcamPathChanged)

    // vbox
    Q_PROPERTY(QString vboxFreeviewIP READ vboxFreeviewIP WRITE setVboxFreeviewIP NOTIFY vboxFreeviewIPChanged)
    Q_PROPERTY(QString vboxFreesatIP  READ vboxFreesatIP  WRITE setVboxFreesatIP  NOTIFY vboxFreesatIPChanged)

    // hdmiEncoder
    Q_PROPERTY(QString hdmiEncoder READ hdmiEncoder WRITE setHdmiEncoder NOTIFY hdmiEncoderChanged)

    // debugging
    Q_PROPERTY(bool showTextBorder READ showTextBorder WRITE setShowTextBorder NOTIFY showTextBorderChanged)

    // default OSD timeouts
    Q_PROPERTY(int osdTimeoutShort READ osdTimeoutShort WRITE setOsdTimeoutShort NOTIFY osdTimeoutShortChanged)
    Q_PROPERTY(int osdTimeoutMedium READ osdTimeoutMedium WRITE setOsdTimeoutMedium NOTIFY osdTimeoutMediumChanged)
    Q_PROPERTY(int osdTimeoutLong READ osdTimeoutLong WRITE setOsdTimeoutLong NOTIFY osdTimeoutLongChanged)

    // zoneminder
    Q_PROPERTY(QString zmIP READ zmIP WRITE setZMIP NOTIFY zmIPChanged)
    Q_PROPERTY(QString zmUserName READ zmUserName WRITE setZMUserName NOTIFY zmUserNameChanged)
    Q_PROPERTY(QString zmPassword READ zmPassword WRITE setZMPassword NOTIFY zmPasswordChanged)

    // shutdown
    Q_PROPERTY(int     idleTime READ idleTime WRITE setIdleTime NOTIFY idleTimeChanged)
    Q_PROPERTY(QString rebootCommand READ rebootCommand WRITE setRebootCommand NOTIFY rebootCommandChanged)
    Q_PROPERTY(QString shutdownCommand READ shutdownCommand WRITE setShutdownCommand NOTIFY shutdownCommandChanged)

    // auto start
    Q_PROPERTY(QString autoStartFrontend READ autoStartFrontend WRITE setAutoStartFrontend NOTIFY autoStartFrontendChanged)

   signals:
     void themeNameChanged(void);
     void hostNameChanged(void);
     void masterIPChanged(void);
     void masterPortChanged(void);
     void masterBackendChanged(void);
     void securityPinChanged(void);
     void configPathChanged(void);
     void sharePathChanged(void);
     void qmlPathChanged(void);
     void menuPathChanged(void);
     void webSocketUrlChanged(void);
     void videoPathChanged(void);
     void picturePathChanged(void);
     void sdChannelsChanged(void);
     void vboxFreeviewIPChanged(void);
     void vboxFreesatIPChanged(void);
     void hdmiEncoderChanged(void);
     void showTextBorderChanged(void);
     void startFullscreenChanged(void);
     void webcamPathChanged(void);
     void osdTimeoutShortChanged(void);
     void osdTimeoutMediumChanged(void);
     void osdTimeoutLongChanged(void);
     void zmIPChanged(void);
     void zmUserNameChanged(void);
     void zmPasswordChanged(void);
     void idleTimeChanged(void);
     void rebootCommandChanged(void);
     void shutdownCommandChanged(void);
     void autoStartFrontendChanged(void);

  public:
    Settings(const QString &hostName, const QString &theme);
    void initSettings(const QString &hostName, const QString &theme);

    QString themeName(void);
    void    setThemeName(const QString &themeName);

    QString hostName(void);
    void    setHostName(const QString &hostName);

    QString masterIP(void);
    void    setMasterIP(const QString &masterIP);

    int     masterPort(void);
    void    setMasterPort(int masterPort);

    QString masterBackend(void);

    QString securityPin(void);
    void    setSecurityPin(const QString &securityPin);

    QString configPath(void);
    void    setConfigPath(const QString &configPath);

    QString sharePath(void);
    void    setSharePath(const QString &sharePath);

    QString qmlPath(void);
    void    setQmlPath(const QString &qmlPath);

    QString menuPath(void);
    void    setMenuPath(const QString &menuPath);

    QString webSocketUrl(void);
    void    setWebSocketUrl(const QString &webSocketUrl);

    QString videoPath(void);
    void    setVideoPath(const QString &videoPath);

    QString picturePath(void);
    void    setPicturePath(const QString &picturePath);

    QString sdChannels(void);
    void    setSdChannels(const QString &sdChannels);

    QString vboxFreeviewIP(void);
    void    setVboxFreeviewIP(const QString &vboxFreeviewIP);

    QString vboxFreesatIP(void);
    void    setVboxFreesatIP(const QString &vboxFreesatIP);

    QString hdmiEncoder(void);
    void    setHdmiEncoder(const QString &hdmiEncoder);

    bool    showTextBorder(void);
    void    setShowTextBorder(const bool showTextBorder);

    bool    startFullscreen(void);
    void    setStartFullscreen(const bool startFullscreen);

    QString webcamPath(void);
    void    setWebcamPath(const QString &webcamPath);

    int     osdTimeoutShort(void);
    void    setOsdTimeoutShort(const int &osdTimeoutShort);

    int     osdTimeoutMedium(void);
    void    setOsdTimeoutMedium(const int &osdTimeoutMedium);

    int     osdTimeoutLong(void);
    void    setOsdTimeoutLong(const int &osdTimeoutLong);

    QString zmIP(void);
    void    setZMIP(const QString &zmIP);

    QString zmUserName(void);
    void    setZMUserName(const QString &zmUserName);

    QString zmPassword(void);
    void    setZMPassword(const QString &zmPassword);

    int     idleTime(void);
    void    setIdleTime(const int &idleTime);

    QString rebootCommand(void);
    void    setRebootCommand(const QString &rebootCommand);

    QString shutdownCommand(void);
    void    setShutdownCommand(const QString &shutdownCommand);

    QString autoStartFrontend(void);
    void    setAutoStartFrontend(const QString &autoStartFrontend);

  private:
    QString m_themeName;
    QString m_hostName;
    QString m_masterIP;
    int     m_masterPort;
    QString m_securityPin;
    QString m_configPath;
    QString m_sharePath;
    QString m_qmlPath;
    QString m_menuPath;
    QString m_webcamPath;

    QString m_webSocketUrl;
    QString m_videoPath;
    QString m_picturePath;
    QString m_sdChannels;

    QString m_vboxFreeviewIP;
    QString m_vboxFreesatIP;

    QString m_hdmiEncoder;

    bool    m_showTextBorder;
    bool    m_startFullscreen;

    int     m_osdTimeoutShort;
    int     m_osdTimeoutMedium;
    int     m_osdTimeoutLong;

    QString m_zmIP;
    QString m_zmUserName;
    QString m_zmPassword;

    int     m_idleTime;
    QString m_rebootCommand;
    QString m_shutdownCommand;

    QString m_autoStartFrontend;
};
