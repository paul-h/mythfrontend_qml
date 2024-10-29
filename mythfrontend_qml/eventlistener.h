#pragma once

// qt
#include <QtGui>
#include <QtQml>

class EventListener : public QObject
{
    Q_OBJECT

public:
    EventListener(QObject *parent = nullptr) :
        QObject(parent)
    {
    }

    Q_INVOKABLE void listenTo(QObject *object)
    {
        if (!object)
            return;

        object->installEventFilter(this);
    }

    bool eventFilter(QObject *object, QEvent *event) override
    {
        Q_UNUSED(object);

        if (event->type() == QEvent::KeyPress)
        {
            emit keyPressed();
        }

        if (event->type() == QEvent::MouseMove)
        {
            QMouseEvent *mouseEvent = dynamic_cast<QMouseEvent*>(event);
            if (mouseEvent)
            {
                emit mouseMoved(mouseEvent->globalPosition().x(), mouseEvent->globalPosition().y());
            }

        }
        if (event->type() == QEvent::MouseButtonPress)
        {
            QMouseEvent *mouseEvent = dynamic_cast<QMouseEvent*>(event);
            if (mouseEvent)
            {
                emit mouseButtonPressed(mouseEvent->globalPosition().x(), mouseEvent->globalPosition().y());
            }

        }
        return false;
    }

  signals:
    void keyPressed(void);
    void mouseMoved(int x, int y);
    void mouseButtonPressed(int x, int y);
};
