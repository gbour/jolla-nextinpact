#ifndef DATABASE_H
#define DATABASE_H

#include <QObject>
#include <QDebug>

#include <QSqlDatabase>
#include <QSqlQuery>
#include <QSqlError>

class Database: public QObject
{
    Q_OBJECT
public:
    explicit Database(QObject *parent = 0);
    ~Database();
private:
    QSqlDatabase db;
    bool init();

public slots:
    bool articleAdd(const QVariantMap values);
    bool toggleRead(const int articleId, const bool read);

};

#endif // DATABASE_H
