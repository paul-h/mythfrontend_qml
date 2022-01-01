// qt
#include <QDebug>

// mdk
#include "mdk/c/MediaInfo.h"

// mythqml
#include "context.h"
#include "mdkplayer.h"


static void renderCallback(void *vo_opaque, void *opaque)
{
    Q_UNUSED(vo_opaque)

    QmlMDKPlayer *player = static_cast<QmlMDKPlayer *>(opaque);
    QMetaObject::invokeMethod(player, "update");
}

static void stateChangedCallback(MDK_State state, void *opaque)
{
    QmlMDKPlayer *player = static_cast<QmlMDKPlayer *>(opaque);
    player->playbackStateChanged(state);
}

static bool mediaStatusChangedCallback(MDK_MediaStatus status, void *opaque)
{
    QmlMDKPlayer *player = static_cast<QmlMDKPlayer *>(opaque);
    return player->mediaStatusChanged(status);
}

static bool mediaEventCallback(const mdkMediaEvent *event, void *opaque)
{
    QmlMDKPlayer *player = static_cast<QmlMDKPlayer *>(opaque);
    return player->eventHandler(*event);
}

class VideoRendererInternal : public QQuickFramebufferObject::Renderer
{
public:
    VideoRendererInternal(QmlMDKPlayer *r)
    {
        this->r = r;
    }

    void render() override
    {
        r->renderVideo();
    }

    QOpenGLFramebufferObject *createFramebufferObject(const QSize &size) override
    {
        r->setVideoSurfaceSize(size.width(), size.height());
        return new QOpenGLFramebufferObject(size);
    }

    QmlMDKPlayer *r;
};

QmlMDKPlayer::QmlMDKPlayer(QQuickItem *parent): QQuickFramebufferObject(parent),
    m_isAvailable(false), m_playerAPI(nullptr), m_updateTimer(new QTimer),m_mediaStatus(MediaStatusNoMedia),
    m_playbackState(PlayerStateStopped), m_position(0), m_duration(0), m_muted(false), m_volume(1.0)
{
    if (!gMDKAPI->isAvailable())
    {
        gContext->m_logger->info(Verbose::GUI, QString("QmlMDKPlayer: MDK API is not available"));
        return;
    }

    m_playerAPI = gMDKAPI->createPlayer();

    qRegisterMetaType<MediaStatus>("MediaStatus");
    qRegisterMetaType<PlayerState>("PlayerState");

    setMirrorVertically(true);

    if (m_playerAPI)
    {
        mdkStateChangedCallback callback;
        callback.cb = stateChangedCallback;
        callback.opaque = this;
        m_playerAPI->onStateChanged(m_playerAPI->object, callback);


        mdkMediaStatusChangedCallback callback2;
        callback2.cb = mediaStatusChangedCallback;
        callback2.opaque = this;
        m_playerAPI->onMediaStatusChanged(m_playerAPI->object, callback2);

        mdkMediaEventCallback callback3;
        callback3.cb = mediaEventCallback;
        callback3.opaque = this;
        m_playerAPI->onEvent(m_playerAPI->object, callback3, nullptr);

        connect(m_updateTimer, &QTimer::timeout, this, &QmlMDKPlayer::updatePosition);
        m_updateTimer->start(1000);

        gMDKAPI->getFFMPEGVersion();
        gMDKAPI->getFFMPEGConfig();
    }
}

QmlMDKPlayer::~QmlMDKPlayer()
{
    if (m_playerAPI)
        gMDKAPI->destroyPlayer(&m_playerAPI);
}

bool QmlMDKPlayer::isAvailable(void)
{
    return (m_playerAPI != nullptr);
}

QQuickFramebufferObject::Renderer *QmlMDKPlayer::createRenderer() const
{
    return new VideoRendererInternal(const_cast<QmlMDKPlayer*>(this));
}

void QmlMDKPlayer::setSource(const QString &s)
{
    if (!m_playerAPI || m_source == s)
        return;

    m_playerAPI->setMedia(m_playerAPI->object, s.toUtf8().data());
    m_source = s;
    emit sourceChanged();
    play();
}

void QmlMDKPlayer::updatePosition(void)
{
    if (!m_playerAPI)
        return;

    int pos = m_playerAPI->position(m_playerAPI->object);

    if (m_position != pos)
    {
        m_position =pos;
        emit positionChanged();
    }

    int duration = m_playerAPI->mediaInfo(m_playerAPI->object)->duration;
    if (m_duration != duration)
    {
        m_duration = duration;
        emit durationChanged();
    }
}

void QmlMDKPlayer::playbackStateChanged(MDK_PlaybackState playbackState)
{
    m_playbackState = static_cast<PlayerState>(playbackState);

    emit playerStateChanged(m_playbackState);
}

bool QmlMDKPlayer::mediaStatusChanged(MDK_MediaStatus mediaStatus)
{
    QStringList status;
    if (mediaStatus == MDK_MediaStatus_NoMedia)
        status.append("NoMedia");
    if (mediaStatus & MDK_MediaStatus_Unloaded)
        status.append("Unloaded");
    if (mediaStatus & MDK_MediaStatus_Loading)
        status.append("Loading");
    if (mediaStatus & MDK_MediaStatus_Loaded)
        status.append("Loaded");
    if (mediaStatus & MDK_MediaStatus_Prepared)
        status.append("Prepared");
    if (mediaStatus & MDK_MediaStatus_Stalled)
        status.append("Stalled");
    if (mediaStatus & MDK_MediaStatus_Buffering)
        status.append("Buffering");
    if (mediaStatus & MDK_MediaStatus_Buffered)
        status.append("Buffered");
    if (mediaStatus & MDK_MediaStatus_End)
        status.append("End");
    if (mediaStatus & MDK_MediaStatus_Seeking)
        status.append("Seeking");
    if (mediaStatus & MDK_MediaStatus_Invalid)
        status.append("Invalid");

    gContext->m_logger->debug(Verbose::GUI, QString("QmlMDKPlayer: MediaStatus changed - %1 (%2)").arg(status.join("|")).arg((int) mediaStatus));

    m_mediaStatus = static_cast<MediaStatus>(mediaStatus);

    emit mediaStatusChanged(m_mediaStatus, status.join(" | "));

    return true;
}

bool QmlMDKPlayer::eventHandler(mdkMediaEvent mediaEvent)
{
    gContext->m_logger->debug(Verbose::GUI, QString("QmlMDKPlayer::eventHandler - category: %1 , details %2, error: %3").arg(mediaEvent.category).arg(mediaEvent.detail).arg(mediaEvent.error));
    return true;
}

QmlMDKPlayer::PlayerState QmlMDKPlayer::playerState()
{
    if (!m_playerAPI)
        return PlayerStateStopped;

    return (PlayerState)m_playerAPI->state(m_playerAPI->object);
}

void QmlMDKPlayer::setPlayerState(PlayerState newState)
{
    if (!m_playerAPI)
        return;

    m_playerAPI->setState(m_playerAPI->object, (MDK_State)newState);
}

float QmlMDKPlayer::volume(void)
{
    if (!m_playerAPI)
        return 1.0;

    return m_volume;
}

void QmlMDKPlayer::setVolume(float volume)
{
    if (!m_playerAPI)
        return;

    m_volume = volume;
    m_playerAPI->setVolume(m_playerAPI->object, m_volume);

    emit volumeChanged();
}

bool QmlMDKPlayer::muted(void)
{
    if (!m_playerAPI)
        return true;

    return m_muted;
}

void QmlMDKPlayer::setMuted(bool muted)
{
    if (!m_playerAPI)
        return;

    m_muted = muted;
    m_playerAPI->setMute(m_playerAPI->object, m_muted);

    emit mutedChanged();
}

qint64 QmlMDKPlayer::position(void)
{
    if (!m_playerAPI)
        return 0;

    return m_position;
}

qint64 QmlMDKPlayer::duration(void)
{
    if (!m_playerAPI)
        return 0;

    return m_duration;
}

void QmlMDKPlayer::play()
{
    if (!m_playerAPI)
        return;

    m_playerAPI->setState(m_playerAPI->object, MDK_State_Playing);

    mdkRenderCallback callback;
    callback.cb = renderCallback;
    callback.opaque = this;
    m_playerAPI->setRenderCallback(m_playerAPI->object, callback );

//    gMDKAPI->getFFMPEGVersion();
//    gMDKAPI->getFFMPEGConfig();
}

void QmlMDKPlayer::stop()
{
    if (!m_playerAPI)
        return;

    m_playerAPI->setState(m_playerAPI->object, MDK_State_Stopped);
}

void QmlMDKPlayer::pause()
{
    if (!m_playerAPI)
        return;

    m_playerAPI->setState(m_playerAPI->object, MDK_State_Paused);
}

float QmlMDKPlayer::getPlaybackRate(void)
{
    if (!m_playerAPI)
        return 1.0;

    return m_playerAPI->playbackRate(m_playerAPI->object);
}

void QmlMDKPlayer::setPlaybackRate(float rate)
{
    if (!m_playerAPI)
        return;

    m_playerAPI->setPlaybackRate(m_playerAPI->object, rate);
}

QmlMDKPlayer::MediaStatus QmlMDKPlayer::mediaStatus(void)
{
    return m_mediaStatus;
}

void QmlMDKPlayer::seek(qint64 ms)
{
    if (!m_playerAPI)
        return;

    m_playerAPI->seekWithFlags(m_playerAPI->object, ms, MDK_SeekFlag_FromNow, {nullptr, nullptr});
}

void QmlMDKPlayer::setProperty(const QString &key, const QString &value)
{
    if (!m_playerAPI)
        return;

    m_playerAPI->setProperty(m_playerAPI->object, key.toLocal8Bit().data(), value.toLocal8Bit().data());
}

QString QmlMDKPlayer::getProperty(const QString &key, const QString &defaultValue)
{
    if (!m_playerAPI)
        return defaultValue;

    QString result;

    result = QString::fromStdString(m_playerAPI->getProperty(m_playerAPI->object, key.toLocal8Bit().data()));

    if (result.isNull() || result.isEmpty())
        result = defaultValue;

    return result;
}

void QmlMDKPlayer::setVideoSurfaceSize(int width, int height)
{
    if (!m_playerAPI)
        return;

    m_playerAPI->setVideoSurfaceSize(m_playerAPI->object, width, height, nullptr);
}

void QmlMDKPlayer::renderVideo()
{
    if (!m_playerAPI)
        return;

    m_playerAPI->renderVideo(m_playerAPI->object, nullptr);
}
