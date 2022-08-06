#include <QObject>
#include <QQuickItem>
#include <QQuickPaintedItem>
#include <QTimer>
#include <QSvgRenderer>

#include <svgimage.h>

SvgImage::SvgImage(QQuickItem *parent) : QQuickPaintedItem(parent)
{
    m_refreshRate = 1 / 60 * 1000;  // 60hz
    setAntialiasing(true);

    m_timer = new QTimer{this};
    connect(m_timer, &QTimer::timeout, [this]
    {
        if (m_renderer->isValid())
        {
            update(boundingRect().toRect());
        }
    });

    connect(this, &QQuickItem::widthChanged, [this]
    {
        if (m_renderer)
            m_renderer->setViewBox(QRect(0, 0 ,width(), height()));
    });

    connect(this, &QQuickItem::heightChanged, [this]
    {
        if (m_renderer)
            m_renderer->setViewBox(QRect(0, 0 ,width(), height()));
    });
}

void SvgImage::paint(QPainter *painter)
{
    m_renderer->render(painter);
}

const QString &SvgImage::source()
{
    return m_source;
}

void SvgImage::setSource(const QString &source)
{
    m_source = source;
    m_renderer = new QSvgRenderer(source, this);
    emit sourceChanged(source);
    m_timer->start(m_refreshRate);
}
