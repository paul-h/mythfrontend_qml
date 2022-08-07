#include <QQuickPaintedItem>
#include <QSvgRenderer>
#include <QTimer>

class SvgImage : public QQuickPaintedItem {
    Q_OBJECT
    Q_PROPERTY(QString source READ source WRITE setSource NOTIFY sourceChanged)
    //QML_ELEMENT

   public:
    explicit SvgImage(QQuickItem* parent = 0);
    void paint(QPainter* painter) override;
    const QString& source();

   public slots:
    void setSource(const QString& source);

   signals:
    void sourceChanged(const QString& source);

   private:
    QSvgRenderer* m_renderer;
    QTimer* m_timer;
    QString m_source;
    int m_refreshRate;
};
