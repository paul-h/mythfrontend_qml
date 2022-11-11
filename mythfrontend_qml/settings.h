#pragma once
#include <QObject>

// this is where we find all our qml files etc.
#define SHAREPATH "file:///usr/share/mythtv/"

class Settings : public QObject
{
    Q_OBJECT

    // general get/set methods
    Q_INVOKABLE QString getSetting(const QString &setting);
    Q_INVOKABLE void setSetting(const QString &setting, const QString &value);

    // mysql DB
    Q_PROPERTY(QString mysqlIP READ mysqlIP WRITE setMysqlIP NOTIFY mysqlIPChanged)
    Q_PROPERTY(int     mysqlPort READ mysqlPort WRITE setMysqlPort NOTIFY mysqlPortChanged)
    Q_PROPERTY(QString mysqlUser READ mysqlUser WRITE setMysqlUser NOTIFY mysqlUserChanged)
    Q_PROPERTY(QString mysqlPassword READ mysqlPassword WRITE setMysqlPassword NOTIFY mysqlPasswordChanged)
    Q_PROPERTY(QString mysqlDBName READ mysqlDBName WRITE setMysqlDBName NOTIFY mysqlDBNameChanged)

    //  MythTV backend
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

    Q_PROPERTY(int websocketPort READ websocketPort WRITE setWebsocketPort NOTIFY websocketPortChanged)
    Q_PROPERTY(QString videoPath READ videoPath WRITE setVideoPath NOTIFY videoPathChanged)
    Q_PROPERTY(QString picturePath READ picturePath WRITE setPicturePath NOTIFY picturePathChanged)
    Q_PROPERTY(QString sdChannels READ sdChannels WRITE setSdChannels NOTIFY sdChannelsChanged)
    Q_PROPERTY(bool    startFullscreen READ startFullscreen WRITE setStartFullscreen NOTIFY startFullscreenChanged)
    Q_PROPERTY(bool    mythQLayout READ mythQLayout WRITE setMythQLayout NOTIFY mythQLayoutChanged)
    Q_PROPERTY(QString webcamListFile READ webcamListFile WRITE setWebcamListFile NOTIFY webcamListFileChanged)
    Q_PROPERTY(QString webvideoListFile READ webvideoListFile WRITE setWebvideoListFile NOTIFY webvideoListFileChanged)
    Q_PROPERTY(QString youtubeSubListFile READ youtubeSubListFile WRITE setYoutubeSubListFile NOTIFY youtubeSubListFileChanged)
    Q_PROPERTY(QString youtubeAPIKey READ youtubeAPIKey WRITE setYoutubeAPIKey NOTIFY youtubeAPIKeyChanged)

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
    Q_PROPERTY(int     frontendIdleTime READ frontendIdleTime WRITE setFrontendIdleTime NOTIFY frontendIdleTimeChanged)
    Q_PROPERTY(int     launcherIdleTime READ launcherIdleTime WRITE setLauncherIdleTime NOTIFY launcherIdleTimeChanged)
    Q_PROPERTY(QString rebootCommand READ rebootCommand WRITE setRebootCommand NOTIFY rebootCommandChanged)
    Q_PROPERTY(QString shutdownCommand READ shutdownCommand WRITE setShutdownCommand NOTIFY shutdownCommandChanged)
    Q_PROPERTY(QString suspendCommand READ suspendCommand WRITE setSuspendCommand NOTIFY suspendCommandChanged)

    // auto start
    Q_PROPERTY(QString autoStartFrontend READ autoStartFrontend WRITE setAutoStartFrontend NOTIFY autoStartFrontendChanged)

    // tivo
    Q_PROPERTY(QString tivoIP READ tivoIP WRITE setTivoIP NOTIFY tivoIPChanged)
    Q_PROPERTY(QString tivoControlPort READ tivoControlPort WRITE setTivoControlPort NOTIFY tivoControlPortChanged)
    Q_PROPERTY(QString tivoVideoURL READ tivoVideoURL WRITE setTivoVideoURL NOTIFY tivoVideoURLChanged)

    // schedules direct
    Q_PROPERTY(QString sdUserName READ sdUserName WRITE setSDUserName NOTIFY sdUserNameChanged)
    Q_PROPERTY(QString sdPassword READ sdPassword WRITE setSDPassword NOTIFY sdPasswordChanged)

    // weather
    Q_PROPERTY(QString weatherCurrentConditions READ weatherCurrentConditions WRITE setWeatherCurrentConditions NOTIFY weatherCurrentConditionsChanged)
    Q_PROPERTY(QString weatherBBCForecast READ weatherBBCForecast WRITE setWeatherBBCForecast NOTIFY weatherBBCForecastChanged)
    Q_PROPERTY(QString weatherMetOfficeForecast READ weatherMetOfficeForecast WRITE setWeatherMetOfficeForecast NOTIFY weatherMetOfficeForecastChanged)
    Q_PROPERTY(QString weatherLightningMap READ weatherLightningMap WRITE setWeatherLightningMap NOTIFY weatherLightningMapChanged)
    Q_PROPERTY(QString weatherRainRadar READ weatherRainRadar WRITE setWeatherRainRadar NOTIFY weatherRainRadarChanged)
    Q_PROPERTY(QString weatherVideoForecast READ weatherVideoForecast WRITE setWeatherVideoForecast NOTIFY weatherVideoForecastChanged)

    // dvd player
    Q_PROPERTY(QString dvdCommand READ dvdCommand WRITE setDvdCommand NOTIFY dvdCommandChanged)
    Q_PROPERTY(QString dvdParameters READ dvdParameters WRITE setDvdParameters NOTIFY dvdParametersChanged)

    // data sources
    Q_PROPERTY(QString energyDataDir READ energyDataDir WRITE setEnergyDataDir NOTIFY energyDataDirChanged)

   signals:
    void mysqlIPChanged(void);
    void mysqlPortChanged(void);
    void mysqlUserChanged(void);
    void mysqlPasswordChanged(void);
    void mysqlDBNameChanged(void);
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
    void websocketPortChanged(void);
    void videoPathChanged(void);
    void picturePathChanged(void);
    void sdChannelsChanged(void);
    void vboxFreeviewIPChanged(void);
    void vboxFreesatIPChanged(void);
    void hdmiEncoderChanged(void);
    void showTextBorderChanged(void);
    void startFullscreenChanged(void);
    void mythQLayoutChanged(void);
    void webcamListFileChanged(void);
    void webvideoListFileChanged(void);
    void youtubeSubListFileChanged(void);
    void youtubeAPIKeyChanged(void);
    void osdTimeoutShortChanged(void);
    void osdTimeoutMediumChanged(void);
    void osdTimeoutLongChanged(void);
    void zmIPChanged(void);
    void zmUserNameChanged(void);
    void zmPasswordChanged(void);
    void frontendIdleTimeChanged(void);
    void launcherIdleTimeChanged(void);
    void rebootCommandChanged(void);
    void shutdownCommandChanged(void);
    void suspendCommandChanged(void);
    void autoStartFrontendChanged(void);
    void tivoIPChanged(void);
    void tivoControlPortChanged(void);
    void tivoVideoURLChanged(void);
    void sdUserNameChanged(void);
    void sdPasswordChanged(void);
    void weatherCurrentConditionsChanged(void);
    void weatherBBCForecastChanged(void);
    void weatherMetOfficeForecastChanged(void);
    void weatherLightningMapChanged(void);
    void weatherRainRadarChanged(void);
    void weatherVideoForecastChanged(void);
    void dvdCommandChanged(void);
    void dvdParametersChanged(void);
    void energyDataDirChanged(void);

  public:
    Settings(const QString &hostName, const QString &theme);
    void setDefaultSettings(const QString &hostName);
    void initSettings(const QString &hostName, const QString &theme);

    // Mysql Database
    QString mysqlIP(void);
    void setMysqlIP(const QString &mysqlIP);

    int mysqlPort(void);
    void setMysqlPort(int mysqlPort);

    QString mysqlUser(void);
    void setMysqlUser(const QString &mysqlUser);

    QString mysqlPassword(void);
    void setMysqlPassword(const QString &mysqlPassword);

    QString mysqlDBName(void);
    void setMysqlDBName(const QString &mysqlDBName);

    // MythTV backend
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

    int     websocketPort(void);
    void    setWebsocketPort(int websocketPort);

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

    bool    mythQLayout(void);
    void    setMythQLayout(const bool mythQLayout);

    QString webcamListFile(void);
    void    setWebcamListFile(const QString &webcamListFile);

    QString webvideoListFile(void);
    void    setWebvideoListFile(const QString &webvideoListFile);

    QString youtubeSubListFile(void);
    void    setYoutubeSubListFile(const QString &youtubeSubListFile);

    QString youtubeAPIKey(void);
    void    setYoutubeAPIKey(const QString &youtubeAPIKey);

    int     osdTimeoutShort(void);
    void    setOsdTimeoutShort(const int osdTimeoutShort);

    int     osdTimeoutMedium(void);
    void    setOsdTimeoutMedium(const int osdTimeoutMedium);

    int     osdTimeoutLong(void);
    void    setOsdTimeoutLong(const int osdTimeoutLong);

    QString zmIP(void);
    void    setZMIP(const QString &zmIP);

    QString zmUserName(void);
    void    setZMUserName(const QString &zmUserName);

    QString zmPassword(void);
    void    setZMPassword(const QString &zmPassword);

    int     frontendIdleTime(void);
    void    setFrontendIdleTime(const int idleTime);

    int     launcherIdleTime(void);
    void    setLauncherIdleTime(const int idleTime);

    QString rebootCommand(void);
    void    setRebootCommand(const QString &rebootCommand);

    QString shutdownCommand(void);
    void    setShutdownCommand(const QString &shutdownCommand);

    QString suspendCommand(void);
    void    setSuspendCommand(const QString &suspendCommand);

    QString autoStartFrontend(void);
    void    setAutoStartFrontend(const QString &autoStartFrontend);

    QString tivoIP(void);
    void    setTivoIP(const QString &tivoIP);

    QString tivoControlPort(void);
    void    setTivoControlPort(const QString &tivoControlPort);

    QString tivoVideoURL(void);
    void    setTivoVideoURL(const QString &tivoVideoURL);

    QString sdUserName(void);
    void    setSDUserName(const QString &sdUserName);

    QString sdPassword(void);
    void    setSDPassword(const QString &sdPassword);

    QString weatherCurrentConditions(void);
    void    setWeatherCurrentConditions(const QString &currentConditions);

    QString weatherBBCForecast(void);
    void    setWeatherBBCForecast(const QString &BBCForecast);

    QString weatherMetOfficeForecast(void);
    void    setWeatherMetOfficeForecast(const QString &metOfficeForecast);

    QString weatherLightningMap(void);
    void    setWeatherLightningMap(const QString &lightningMap);

    QString weatherRainRadar(void);
    void    setWeatherRainRadar(const QString &rainRadar);

    QString weatherVideoForecast(void);
    void    setWeatherVideoForecast(const QString &videoForecast);

    QString dvdCommand(void);
    void    setDvdCommand(const QString &dvdCommand);

    QString dvdParameters(void);
    void    setDvdParameters(const QString &dvdParameters);

    QString energyDataDir(void);
    void    setEnergyDataDir(const QString &energyDataDir);

  private:
    // Mysql Database
    QString m_mysqlIP;
    int     m_mysqlPort;
    QString m_mysqlUser;
    QString m_mysqlPassword;
    QString m_mysqlDBName;

    // MythTV Backend
    QString m_themeName;
    QString m_hostName;
    QString m_masterIP;
    int     m_masterPort;
    QString m_securityPin;
    QString m_configPath;
    QString m_sharePath;
    QString m_qmlPath;
    QString m_menuPath;
    QString m_webcamListFile;
    QString m_webvideoListFile;
    QString m_youtubeSubListFile;
    QString m_youtubeAPIKey;

    int     m_websocketPort;
    QString m_videoPath;
    QString m_picturePath;
    QString m_sdChannels;

    QString m_vboxFreeviewIP;
    QString m_vboxFreesatIP;

    QString m_hdmiEncoder;

    bool    m_showTextBorder;
    bool    m_startFullscreen;
    bool    m_mythQLayout;

    int     m_osdTimeoutShort;
    int     m_osdTimeoutMedium;
    int     m_osdTimeoutLong;

    QString m_zmIP;
    QString m_zmUserName;
    QString m_zmPassword;

    int     m_frontendIdleTime;
    int     m_launcherIdleTime;
    QString m_rebootCommand;
    QString m_shutdownCommand;
    QString m_suspendCommand;

    QString m_autoStartFrontend;

    QString m_tivoIP;
    QString m_tivoControlPort;
    QString m_tivoVideoURL;

    QString m_sdUserName;
    QString m_sdPassword;

    QString m_weatherCurrentConditions;
    QString m_weatherBBCForecast;
    QString m_weatherMetOfficeForecast;
    QString m_weatherLightningMap;
    QString m_weatherRainRadar;
    QString m_weatherVideoForecast;

    QString m_dvdCommand;
    QString m_dvdParameters;

    QString m_energyDataDir;
};
