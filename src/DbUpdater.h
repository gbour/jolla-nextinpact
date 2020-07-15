/*
    Copyright 2020 Guillaume Bour.
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
