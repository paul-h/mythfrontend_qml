#ifndef HELPER_H
#define HELPER_H

#include <QRunnable>
#include <QObject>
#include <QThreadPool>
#include <QDir>
#include <QStringList>

class FileCounter : public QObject, public QRunnable
{
  Q_OBJECT

  public:
    FileCounter(const QString &folder)
    {
        m_folder = folder;
        m_extensions << "ts" << "mp4" << "mp2" << "flv" << "mpg" << "mkv" << "webm" << "avi" << "wmv" << "iso" << "mov";
    }
  public slots:
    void countFiles(const QString &folder)
    {
        int count = doCountFiles(folder);
        emit result(folder, count);
    }

    int doCountFiles(const QString &folder)
    {
        int count = 0;
        QDir dir(folder);
        dir.setFilter(QDir::AllEntries | QDir::NoDotAndDotDot);

        if (!dir.exists())
            return 0;

        QFileInfoList sList = dir.entryInfoList(QDir::AllEntries | QDir::NoDotAndDotDot);

        foreach(QFileInfo finfo, sList)
        {
            if (finfo.isDir())
                count += doCountFiles(finfo.path() + "/" + finfo.completeBaseName() + "/");
            else
            {
                if (m_extensions.contains(finfo.suffix()))
                    count++;
            }
        }

        return count;
    }

  protected:
    void run()
    {
        countFiles(m_folder);
    }

  signals:
    void result(const QString &folder, int fileCount);

  private:
    QString m_folder;
    QStringList m_extensions;
};

class HelperController : public QObject
{
    Q_OBJECT
  public:
    HelperController()
    {
    }

    Q_INVOKABLE void countFiles(const QString &folder)
    {
        m_fileCounter = new FileCounter(folder);
        m_fileCounter->setAutoDelete(true);
        connect(m_fileCounter, SIGNAL(result(const QString &, int)), this, SIGNAL(fileCounterResult(const QString &, int)), Qt::QueuedConnection);
        QThreadPool::globalInstance()->start(m_fileCounter);
    }
  private:
    FileCounter * m_fileCounter;

  signals:
//    void countFiles(const QString &folder);
    void fileCounterResult(const QString &folder, int fileCount);
};

#endif // HELPER_H
