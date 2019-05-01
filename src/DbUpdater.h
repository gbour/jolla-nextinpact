#ifndef DBUPDATER_H
#define DBUPDATER_H

#include <QObject>
#include <QSqlDatabase>

class DbUpdater: public QObject
{
    Q_OBJECT
public:
    explicit DbUpdater(QSqlDatabase db, QObject *parent = 0);
    ~DbUpdater();

    void start();
    void commit();
    void rollback();
    bool exec(int version, QStringList queries);

private:
    QSqlDatabase db;
};

#endif // DBUPDATER_H
