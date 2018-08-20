#pragma once
#include <QObject>

class Settings : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString themeName READ themeName WRITE setThemeName NOTIFY themeNameChanged)
    Q_PROPERTY(QString hostName READ hostName WRITE setHostName NOTIFY hostNameChanged)
    Q_PROPERTY(QString configPath READ configPath WRITE setConfigPath NOTIFY configPathChanged)
    Q_PROPERTY(QString sharePath READ sharePath WRITE setSharePath NOTIFY sharePathChanged)
    Q_PROPERTY(QString qmlPath READ qmlPath WRITE setQmlPath NOTIFY qmlPathChanged)
    Q_PROPERTY(QString themePath READ themePath WRITE setThemePath NOTIFY themePathChanged)
    Q_PROPERTY(QString menuPath READ menuPath WRITE setMenuPath NOTIFY menuPathChanged)
    Q_PROPERTY(QString masterBackend READ masterBackend WRITE setMasterBackend NOTIFY masterBackendChanged)
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

  signals:
     void themeNameChanged(void);
     void hostNameChanged(void);
     void configPathChanged(void);
     void sharePathChanged(void);
     void qmlPathChanged(void);
     void themePathChanged(void);
     void menuPathChanged(void);
     void masterBackendChanged(void);
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

  public:
    QString themeName(void) {return m_themeName;}
    void    setThemeName(const QString &themeName) {m_themeName = themeName; emit themeNameChanged();}

    QString hostName(void) {return m_hostName;}
    void    setHostName(const QString &hostName) {m_hostName = hostName; emit hostNameChanged();}

    QString configPath(void) {return m_configPath;}
    void    setConfigPath(const QString &configPath) {m_configPath = configPath; emit configPathChanged();}

    QString sharePath(void) {return m_sharePath;}
    void    setSharePath(const QString &sharePath) {m_sharePath = sharePath; emit sharePathChanged();}

    QString qmlPath(void) {return m_qmlPath;}
    void    setQmlPath(const QString &qmlPath) {m_qmlPath = qmlPath; emit qmlPathChanged();}

    QString themePath(void) {return m_themePath;}
    void    setThemePath(const QString &themePath) {m_themePath = themePath; emit themePathChanged();}

    QString menuPath(void) {return m_menuPath;}
    void    setMenuPath(const QString &menuPath) {m_menuPath = menuPath; emit menuPathChanged();}

    QString masterBackend(void) {return m_masterBackend;}
    void    setMasterBackend(const QString &masterBackend) {m_masterBackend = masterBackend; emit masterBackendChanged(); }

    QString webSocketUrl(void) {return m_webSocketUrl;}
    void    setWebSocketUrl(const QString &webSocketUrl) {m_webSocketUrl = webSocketUrl; emit webSocketUrlChanged(); }

    QString videoPath(void) {return m_videoPath;}
    void    setVideoPath(const QString &videoPath) {m_videoPath = videoPath; emit videoPathChanged();}

    QString picturePath(void) {return m_picturePath;}
    void    setPicturePath(const QString &picturePath) {m_picturePath = picturePath; emit picturePathChanged();}

    QString sdChannels(void) {return m_sdChannels;}
    void    setSdChannels(const QString &sdChannels) {m_sdChannels = sdChannels; emit sdChannelsChanged();}

    QString vboxFreeviewIP(void) {return m_vboxFreeviewIP;}
    void    setVboxFreeviewIP(const QString &vboxFreeviewIP) {m_vboxFreeviewIP = vboxFreeviewIP; emit vboxFreeviewIPChanged();}

    QString vboxFreesatIP(void) {return m_vboxFreesatIP;}
    void    setVboxFreesatIP(const QString &vboxFreesatIP) {m_vboxFreesatIP = vboxFreesatIP; emit vboxFreesatIPChanged();}

    QString hdmiEncoder(void) {return m_hdmiEncoder;}
    void    setHdmiEncoder(const QString &hdmiEncoder) {m_hdmiEncoder = hdmiEncoder; emit hdmiEncoderChanged();}

    bool    showTextBorder(void) {return m_showTextBorder;}
    void    setShowTextBorder(const bool showTextBorder) {m_showTextBorder = showTextBorder; emit showTextBorderChanged();}

    bool    startFullscreen(void) {return m_startFullscreen;}
    void    setStartFullscreen(const bool startFullscreen) {m_startFullscreen = startFullscreen; emit startFullscreenChanged();}

    QString webcamPath(void) {return m_webcamPath;}
    void    setWebcamPath(const QString &webcamPath) {m_webcamPath = webcamPath; emit webcamPathChanged();}

  private:
    QString m_themeName;
    QString m_hostName;
    QString m_configPath;
    QString m_sharePath;
    QString m_qmlPath;
    QString m_themePath;
    QString m_menuPath;
    QString m_webcamPath;

    QString m_masterBackend;
    QString m_webSocketUrl;
    QString m_videoPath;
    QString m_picturePath;
    QString m_sdChannels;

    QString m_vboxFreeviewIP;
    QString m_vboxFreesatIP;

    QString m_hdmiEncoder;

    bool    m_showTextBorder;
    bool    m_startFullscreen;

};

extern Settings *gSettings;
