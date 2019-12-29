#include "log_list_model.h"

LogListModel::LogListModel(QObject* parent) : QAbstractListModel(parent)
{
}

QVariant LogListModel::data(const QModelIndex &index, int role) const
{
    if (index.row()<0 || index.row()>=m_logs.size()) {
        return QVariant();
    }
    return m_logs.at(index.row());
}

int LogListModel::rowCount(const QModelIndex &parent) const
{
    return m_logs.size();
}

/*Q_INVOKABLE */bool LogListModel::add(QString row)
{
    beginInsertRows(QModelIndex(), rowCount(), rowCount());
    m_logs << row;
    endInsertRows();
    return true;
}
