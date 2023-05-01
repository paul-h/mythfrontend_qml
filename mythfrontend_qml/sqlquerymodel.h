#pragma once
#include <QSqlQueryModel>

class SqlQueryModel : public QSqlQueryModel
{
    Q_OBJECT

public:
    explicit SqlQueryModel(QObject *parent = nullptr);

    Q_PROPERTY(QString sql READ sql WRITE setSql NOTIFY sqlChanged)
    Q_PROPERTY(bool useMythQMLDB READ useMythQMLDB WRITE setUseMythQMLDB NOTIFY useMythQMLDBChanged)

    Q_INVOKABLE void reload(void);

    void setQuery(const QString &query, const QSqlDatabase &db = QSqlDatabase());
    void setQuery(const QSqlQuery &query);
    QVariant data(const QModelIndex &index, int role) const;
    QHash<int, QByteArray> roleNames() const {  return m_roleNames; }

    void setSql(const QString &sql);
    QString sql(void);

    void setUseMythQMLDB(bool useMythQMLDB);
    bool useMythQMLDB(void);

signals:
    void sqlChanged(const QString& sql);
    void useMythQMLDBChanged(bool useMythQMLDBChanged);

private:
    void generateRoleNames();

    bool m_useMythQMLDB;
    QString m_sql;
    QHash<int, QByteArray> m_roleNames;
};
