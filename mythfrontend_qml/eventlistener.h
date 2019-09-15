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
            emit mouseMoved();
        }
        return false;
    }

  signals:
    void keyPressed(void);
    void mouseMoved(void);
};
