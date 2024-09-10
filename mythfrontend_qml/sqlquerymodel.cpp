#include <QSqlRecord>
#include <QSqlField>
#include <QSqlQuery>
#include <QSqlError>

#include "sqlquerymodel.h"
#include "context.h"

SqlQueryModel::SqlQueryModel(QObject *parent) :
QSqlQueryModel(parent)
{
    m_database = "mythqml";
}

void SqlQueryModel::setSql(const QString &sql)
{
    m_sql = sql;

    clear();

    setQuery(m_sql, gContext->m_databaseUtils->getDatabase(m_database));

    if (QSqlQueryModel::lastError().isValid())
        gContext->m_logger->error(Verbose::GENERAL, "SqlQueryModel::setSql query failed: " + QSqlQueryModel::lastError().text());

    emit sqlChanged(sql);
}

QString SqlQueryModel::sql(void)
{
    return m_sql;
}

void SqlQueryModel::setDatabase(const QString &database)
{
    m_database = database;
}

QString SqlQueryModel::database(void)
{
    return m_database;
}

void SqlQueryModel::setQuery(const QString &query, const QSqlDatabase &db)
{
    QSqlQueryModel::setQuery(query, db);
    generateRoleNames();
}

void SqlQueryModel::setQuery(const QSqlQuery &query)
{
    QSqlQueryModel::setQuery(query);
    generateRoleNames();
}

void SqlQueryModel::generateRoleNames()
{
    m_roleNames.clear();
    m_nameToRoleMap.clear();

    for( int i = 0; i < record().count(); i ++)
    {
        m_roleNames.insert(Qt::UserRole + i + 1, record().fieldName(i).toUtf8());
        m_nameToRoleMap.insert(record().fieldName(i).toUtf8(), i);
    }
}

QVariant SqlQueryModel::data(const QModelIndex &index, int role) const
{
    QVariant value;

    if (role < Qt::UserRole)
    {
        value = QSqlQueryModel::data(index, role);
    }
    else
    {
        int columnIdx = role - Qt::UserRole - 1;
        QModelIndex modelIndex = this->index(index.row(), columnIdx);
        value = QSqlQueryModel::data(modelIndex, Qt::DisplayRole);
    }

    return value;
}

QVariant SqlQueryModel::get(int row, const QString &field) const
{
    int role = m_nameToRoleMap[field.toUtf8()];
    QModelIndex index = QSqlQueryModel::index(row, role);
    QVariant result = QSqlQueryModel::data(index, Qt::DisplayRole);
    return result;
}

void SqlQueryModel::reload()
{
    setSql(m_sql);
}
