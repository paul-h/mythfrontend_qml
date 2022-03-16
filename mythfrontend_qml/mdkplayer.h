#ifndef QMLMDKPLAYER_H
#define QMLMDKPLAYER_H

#include <QQuickFramebufferObject>
#include <QOpenGLFramebufferObject>
#include <QDebug>
#include <QTimer>
#include "mdkapi.h"

class QmlMDKPlayer : public QQuickFramebufferObject
{
    Q_OBJECT
public:
    enum PlayerState
    {
        PlayerStateStopped,
        PlayerStatePlaying,
        PlayerStatePaused
    };
    Q_ENUM(PlayerState)

    enum MediaStatus
    {
        MediaStatusNoMedia = MDK_MediaStatus_NoMedia,     // initial status, not invalid. // what if set an empty url and closed?
        MediaStatusUnloaded = MDK_MediaStatus_Unloaded,   // unloaded // (TODO: or when a source(url) is set?)
        MediaStatusLoading = MDK_MediaStatus_Loading,     // opening and parsing the media
        MediaStatusLoaded = MDK_MediaStatus_Loaded,       // media is loaded and parsed. player is stopped state. mediaInfo() is available now
        MediaStatusPrepared = MDK_MediaStatus_Prepared,   // all tracks are buffered and ready to decode frames. tracks failed to open decoder are ignored
        MediaStatusStalled = MDK_MediaStatus_Stalled,     // insufficient buffering or other interruptions (timeout, user interrupt)
        MediaStatusBuffering = MDK_MediaStatus_Buffering, // when buffering starts
        MediaStatusBuffered = MDK_MediaStatus_Buffered,   // when buffering ends
        MediaStatusEnd = MDK_MediaStatus_End,             // reached the end of the current media, no more data to read
        MediaStatusSeeking = MDK_MediaStatus_Seeking,
        MediaStatusInvalid = MDK_MediaStatus_Invalid,     // failed to load media because of unsupport format or invalid media source
    };
    Q_ENUM(MediaStatus)

    Q_PROPERTY(bool isAvailable READ isAvailable NOTIFY isAvailableChanged)
    Q_PROPERTY(QString source READ source WRITE setSource NOTIFY sourceChanged)
    Q_PROPERTY(float volume READ volume WRITE setVolume NOTIFY volumeChanged)
    Q_PROPERTY(bool muted READ muted WRITE setMuted NOTIFY mutedChanged)
    Q_PROPERTY(qint64 position READ position NOTIFY positionChanged)
    Q_PROPERTY(qint64 duration READ duration NOTIFY durationChanged)

    Q_PROPERTY(PlayerState playerState READ playerState WRITE setPlayerState NOTIFY playerStateChanged)
    Q_PROPERTY(MediaStatus mediaStatus READ mediaStatus NOTIFY mediaStatusChanged)

public:
    explicit QmlMDKPlayer(QQuickItem *parent = nullptr);
    virtual ~QmlMDKPlayer();
    Renderer *createRenderer() const;

    Q_INVOKABLE void play();
    Q_INVOKABLE void stop();
    Q_INVOKABLE void pause();
    
    Q_INVOKABLE void setFillMode(int fillMode);

    Q_INVOKABLE void setPlaybackRate(float rate);
    Q_INVOKABLE float getPlaybackRate(void);
    Q_INVOKABLE void seek(qint64 ms);
    Q_INVOKABLE void setVideoSurfaceSize(int width, int height);

    Q_INVOKABLE QString source() { return m_source; }
    Q_INVOKABLE void setSource(const QString & s);

    Q_INVOKABLE void setProperty(const QString &key, const QString &value);
    Q_INVOKABLE QString getProperty(const QString &key, const QString &defaultValue);

    bool isAvailable(void);

    PlayerState playerState(void);
    void setPlayerState(PlayerState newstate);

    float volume(void);
    void setVolume(float volume);

    bool muted(void);
    void setMuted(bool muted);

    qint64 position(void);
    qint64 duration(void);

    MediaStatus mediaStatus(void);

    void updatePosition(void);
    void renderVideo();
    void playbackStateChanged(MDK_State playbackState);
    bool mediaStatusChanged(MDK_MediaStatus mediaStatus);
    bool eventHandler(mdkMediaEvent mediaEvent);

signals:
    void isAvailableChanged();
    void sourceChanged();
    void volumeChanged();
    void mutedChanged();
    void positionChanged();
    void durationChanged();
    void playerStateChanged(PlayerState playerState);
    void mediaStatusChanged(MediaStatus mediaStatus, QString statusString);
    void playbackEnded();

private:
    bool          m_isAvailable;
    QString       m_source;
    const mdkPlayerAPI *m_playerAPI;
    QTimer       *m_updateTimer;
    MediaStatus   m_mediaStatus;
    PlayerState   m_playbackState;
    qint64        m_position;
    qint64        m_duration;
    bool          m_muted;
    float         m_volume;
};

#endif // QMLMDKPLAYER_H
