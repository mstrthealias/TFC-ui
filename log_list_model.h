#ifndef LOGLISTMODEL_H
#define LOGLISTMODEL_H

#include <QAbstractTableModel>


class LogListModel : public QAbstractListModel
{
Q_OBJECT

public:
    LogListModel(QObject* parent = nullptr);

    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const;
    int rowCount(const QModelIndex &parent = QModelIndex()) const;

    Q_INVOKABLE bool add(QString row);

private:
    QStringList m_logs;

};


#endif // LOGLISTMODEL_H
