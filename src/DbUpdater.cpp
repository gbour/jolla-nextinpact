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

#include <QDebug>
#include <QSqlQuery>
#include <QSqlError>

#include "src/DbUpdater.h"

DbUpdater::DbUpdater(QSqlDatabase db, QObject *parent) : QObject(parent)
{
    this->db = db;
}

DbUpdater::~DbUpdater() {
}

void DbUpdater::start() {
    // disable FK constraint before starting transaction
    QSqlQuery q;
    q.exec("PRAGMA foreign_keys = OFF");
    q.finish();

    QSqlDatabase::database().transaction();
}

void DbUpdater::commit() {
      QSqlDatabase::database().commit();

      // enable back FK constraint
      QSqlQuery q;
      q.exec("PRAGMA foreign_keys = ON");
      q.finish();
}

void DbUpdater::rollback() {
    QSqlDatabase::database().rollback();
}

bool DbUpdater::exec(int version, QStringList queries) {
    bool ret;
    QSqlQuery q;

    qDebug() << "upgrading db schema (to version" << version << ")";
    this->start();

    for(int i = 0; i < queries.size(); i++) {
        qDebug() << "  exec" << queries.at(i);
        ret = q.exec(queries.at(i));
        if (!ret) {
            qDebug() << "  . failed: " << queries.at(i) << ", error " << q.lastError().text();
            this->rollback();
            return false;
        }

        q.finish();
    }

    // check foreign key contraints
    ret = q.exec("PRAGMA foreign_key_check");
    if (!ret) {
        qDebug() << "  . `PRAGMA foreign_key_check` failed: " << q.lastError();
        this->rollback();
        return false;
    }
    if (q.next()) {
        qDebug() << "  . FK conflicts:";
        do {
            qDebug() << "    -" << q.value(0).toString() << q.value(1).toLongLong() <<
                        q.value(2).toString();
        } while (q.next());

        this->rollback();
        return false;
    }
    q.finish();


    // updating db version
    q.prepare("UPDATE config SET value=:version WHERE key='version'");
    q.bindValue(":version", version);
    if (!q.exec()) {
        qDebug() << "upgrade version field failed:" << q.lastError().text();
        this->rollback();
        return false;
    }
    q.finish();

    this->commit();
    qDebug() << "  . succeed";
    return true;
}


