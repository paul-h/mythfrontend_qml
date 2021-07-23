#include "mdkplayer.h"
#include <QDebug>

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


QmlMDKPlayer::QmlMDKPlayer(QQuickItem *parent):
    QQuickFramebufferObject(parent),
    m_player(new mdk::Player), m_updateTimer(new QTimer)
{
    qRegisterMetaType<MediaStatus>("MediaStatus");

    setMirrorVertically(true);

    m_player->onStateChanged([this](mdk::PlaybackState s) { playbackStateChanged(s);});
    m_player->onMediaStatusChanged([this](mdk::MediaStatus s) { return mediaStatusChanged(s);});
    m_player->onEvent([this](mdk::MediaEvent e) { return eventHandler(e);});

    connect(m_updateTimer, &QTimer::timeout, this, &QmlMDKPlayer::updatePosition);
    m_updateTimer->start(1000);
}

QmlMDKPlayer::~QmlMDKPlayer()
{
    delete m_player;
}

QQuickFramebufferObject::Renderer *QmlMDKPlayer::createRenderer() const
{
    return new VideoRendererInternal(const_cast<QmlMDKPlayer*>(this));
}

void QmlMDKPlayer::setSource(const QString & s)
{
    m_player->setMedia(s.toUtf8().data());
    m_source = s;
    emit sourceChanged();
    play();
}

void QmlMDKPlayer::updatePosition(void)
{
    if (m_position != m_player->position())
    {
        m_position = m_player->position();
        positionChanged();
    }

    if (m_duration != m_player->mediaInfo().duration)
    {
        m_duration = m_player->mediaInfo().duration;
        emit durationChanged();
    }
}
void QmlMDKPlayer::playbackStateChanged(mdk::PlaybackState playbackState)
{
    m_playbackState = static_cast<PlayerState>(playbackState);

    emit playerStateChanged(m_playbackState);
}

bool QmlMDKPlayer::mediaStatusChanged(mdk::MediaStatus mediaStatus)
{
    QStringList status;
    if (mediaStatus == 0)
        status.append("NoMedia");
    if (mediaStatus == 1)
        status.append("Unloaded");
    if (mediaStatus & mdk::Loading)
        status.append("Loading");
    if (mediaStatus & mdk::Loaded)
        status.append("Loaded");
    if (mediaStatus & mdk::Prepared)
        status.append("Prepared");
    if (mediaStatus & mdk::Stalled)
        status.append("Stalled");
    if (mediaStatus & mdk::Buffering)
        status.append("Buffering");
    if (mediaStatus & mdk::Buffered)
        status.append("Buffered");
    if (mediaStatus & mdk::End)
        status.append("End");
    if (mediaStatus & mdk::Seeking)
        status.append("Seeking");
    if (mediaStatus & mdk::Invalid)
        status.append("Invalid");

    qDebug() << "QmlMDKPlayer: MediaStatus changed - " << status.join("|") << " - " << (int) mediaStatus;

    m_mediaStatus = static_cast<MediaStatus>(mediaStatus);

    emit mediaStatusChanged(m_mediaStatus);

    return true;
}

bool QmlMDKPlayer::eventHandler(mdk::MediaEvent mediaEvent)
{
    qDebug() << "QmlMDKPlayer::eventHandler - category: " << mediaEvent.category.c_str() << ", details: " << mediaEvent.detail.c_str() << ", error: " << mediaEvent.error;
    return true;
}

QmlMDKPlayer::PlayerState QmlMDKPlayer::playerState()
{
    return (PlayerState)m_player->state();
}

void QmlMDKPlayer::setPlayerState(PlayerState newState)
{
    m_player->set((mdk::PlaybackState)newState);
}


void QmlMDKPlayer::setVolume(float volume)
{
    m_player->setVolume(volume);
    emit volumeChanged();
}

void QmlMDKPlayer::setMuted(bool muted)
{
    m_player->setMute(muted);
    emit mutedChanged();
}

qint64 QmlMDKPlayer::position(void)
{
    if (m_position != m_player->position())
    {
        m_position = m_player->position();
        emit positionChanged();
    }

    return m_player->position();
}

qint64 QmlMDKPlayer::duration(void)
{
    if (m_duration != m_player->mediaInfo().duration)
    {
        m_duration = m_player->mediaInfo().duration;
        emit durationChanged();
    }

    return m_player->mediaInfo().duration;
}

void QmlMDKPlayer::play()
{
    m_player->set(mdk::PlaybackState::Playing);
    m_player->setRenderCallback([=](void *) {QMetaObject::invokeMethod(this, "update");} );
}

void QmlMDKPlayer::stop()
{
    m_player->set(mdk::PlaybackState::Stopped);
}

void QmlMDKPlayer::pause()
{
    m_player->set(mdk::PlaybackState::Paused);
}

float QmlMDKPlayer::getPlaybackRate(void)
{
    return m_player->playbackRate();
}

void QmlMDKPlayer::setPlaybackRate(float rate)
{
    m_player->setPlaybackRate(rate);
}

QmlMDKPlayer::MediaStatus QmlMDKPlayer::mediaStatus(void)
{
    return m_mediaStatus;
}

void QmlMDKPlayer::seek(qint64 ms)
{
    m_player->seek(ms, mdk::SeekFlag::FromNow, nullptr);
}

void QmlMDKPlayer::setProperty(const QString &key, const QString &value)
{
    m_player->setProperty(key.toLocal8Bit().data(), value.toLocal8Bit().data());
}

QString QmlMDKPlayer::getProperty(const QString &key, const QString &defaultValue)
{
    return QString::fromStdString(m_player->property(key.toLocal8Bit().data(), defaultValue.toLocal8Bit().data()));
}

void QmlMDKPlayer::setVideoSurfaceSize(int width, int height)
{
    m_player->setVideoSurfaceSize(width, height);
}

void QmlMDKPlayer::renderVideo()
{
    m_player->renderVideo();
}
