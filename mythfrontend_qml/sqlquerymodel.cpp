#include <QSqlRecord>
#include <QSqlField>
#include <QSqlQuery>
#include <QDebug>

#include "sqlquerymodel.h"
#include "context.h"

SqlQueryModel::SqlQueryModel(QObject *parent) :
QSqlQueryModel(parent)
{
    m_useMythQMLDB = true;
}

void SqlQueryModel::setSql(const QString &sql)
{
    m_sql = sql;

    clear();

    if (m_useMythQMLDB)
        setQuery(m_sql, gContext->m_mythQMLDB);
    else
        setQuery(m_sql, gContext->m_mythDB);

    emit sqlChanged(sql);
}

QString SqlQueryModel::sql(void)
{
    return m_sql;
}

void SqlQueryModel::setUseMythQMLDB(bool useMythQMLDB)
{
    m_useMythQMLDB = useMythQMLDB;

    emit useMythQMLDBChanged(useMythQMLDB);
}

bool SqlQueryModel::useMythQMLDB(void)
{
    return m_useMythQMLDB;
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

    for( int i = 0; i < record().count(); i ++)
    {
        m_roleNames.insert(Qt::UserRole + i + 1, record().fieldName(i).toUtf8());
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

void SqlQueryModel::reload()
{
    setSql(m_sql);
}
