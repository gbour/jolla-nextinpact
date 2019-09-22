/*
    Copyright 2019 Guillaume Bour.
    This file is part of «NextINpact app».

    «NextINpact app» is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    any later version.

    «NextINpact app» is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with «NextINpact app».  If not, see <http://www.gnu.org/licenses/>.
*/

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

    QSqlDatabase getDatabase() const {
        return this->db;
    }
    Q_INVOKABLE QVariantMap getConfig(QString keyprefix);
    Q_INVOKABLE bool setConfig(QString key, QString value);
    Q_INVOKABLE qint64 size() const;
    Q_INVOKABLE void flush() const;
    Q_INVOKABLE bool cleanup() const;

private:
    QSqlDatabase db;
    bool init();
    bool migrate();
    bool storeMigration(QString dbpath);

public slots:
};

#endif // DATABASE_H
