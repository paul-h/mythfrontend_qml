#pragma once

// qt
#include <QtGui>
#include <QtQml>

class KeyPressListener : public QObject
{
    Q_OBJECT

public:
    KeyPressListener(QObject *parent = nullptr) :
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

        return false;
    }

  signals:
    void keyPressed(void);
};
