#pragma once
#include <QSqlQueryModel>

class SqlQueryModel : public QSqlQueryModel
{
    Q_OBJECT

public:
    explicit SqlQueryModel(QObject *parent = nullptr);

    Q_PROPERTY(QString sql READ sql WRITE setSql NOTIFY sqlChanged)
    Q_PROPERTY(QString database READ database WRITE setDatabase NOTIFY databaseChanged)

    Q_INVOKABLE void reload(void);
    Q_INVOKABLE QVariant get(int row, const QString &field) const;

    void setQuery(const QString &query, const QSqlDatabase &db = QSqlDatabase());
    void setQuery(const QSqlQuery &query);
    QVariant data(const QModelIndex &index, int role) const;
    QHash<int, QByteArray> roleNames() const {  return m_roleNames; }

    void setSql(const QString &sql);
    QString sql(void);

    void setDatabase(const QString &database);
    QString database(void);

signals:
    void sqlChanged(const QString &sql);
    void databaseChanged(const QString &database);

private:
    void generateRoleNames();

    QString m_database;

    QString m_sql;
    QHash<int, QByteArray> m_roleNames;
    QHash<QByteArray, int> m_nameToRoleMap;
};
