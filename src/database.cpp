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

#include <QStandardPaths>
#include <QStringBuilder>
#include <QFileInfo>
#include <QDir>

// nemo notifications
#include "notification.h"

#include <src/database.h>
#include <src/DbUpdater.h>

Database::Database(QObject *parent) : QObject(parent)
{
    this->init();
    this->migrate();
}

Database::~Database()
{}

bool Database::init()
{
    //qDebug() << QSqlDatabase::drivers();
    //TODO: check QSLITE driver is present ?
    static QString dbpath = QStandardPaths::writableLocation(QStandardPaths::AppDataLocation) % QString("/" DB_NAME);

    // directory is not automatically created if not exists
    // db.open() fails unless we create the directory tree
    QFileInfo fi(dbpath);
    fi.dir().mkpath(".");

    // Temporary: copy database from old path if exists.
    // Will be removed in future versions.
    this->storeMigration(dbpath);

    this->db = QSqlDatabase::addDatabase("QSQLITE");
    this->db.setDatabaseName(dbpath);
    if (!this->db.open()) {
        qDebug() << "cannot open sqlite database" << dbpath << ":" << this->db.lastError();
        return false;
    }

    QSqlQuery query;
    // SET PRAGMAS
    query.exec("PRAGMA foreign_keys = ON");
    query.finish();

    query.exec("CREATE TABLE IF NOT EXISTS config ("
                    "key   TEXT PRIMARY KEY,"
                    "value TEXT"
               ")");
    query.prepare("INSERT OR IGNORE INTO config VALUES (\"version\", :version)");
    query.bindValue(":version", DB_VERSION);
    query.exec();
    query.finish();

    query.exec("CREATE TABLE IF NOT EXISTS articles ("
                    "id INTEGER,"
                    // article type: 0: news, 1: brief
                    "type INTEGER DEFAULT 0,"

                    "date TEXT,"
                    "timestamp TEXT,"
                    "title TEXT,"
                    "subtitle TEXT,"
                    "nb_comments INTEGER,"
                    // base64 serialized image, including 'data:image/png;base64,' scheme
                    "icon BLOB,"
                    // link to original article
                    "link TEXT,"
                    // article details
                    "readtime TEXT,"
                    "author TEXT,"
                    "pubdate TEXT,"
                    "content TEXT,"
                    // bool flags
                    "unread INTEGER DEFAULT 1,"
                    "new_comments INTEGER DEFAULT 1,"
                    // parent article ('brief' articles only, -1 for no parent)
                    "parent INTEGER DEFAULT -1,"
                    "PRIMARY KEY (id, type)"
               ")");
    qDebug() << query.lastError().text();
    query.finish();

    query.exec("CREATE TABLE IF NOT EXISTS comments ("
                    "id INTEGER,"
                    "article_id INTEGER,"
                    "article_type INTEGER,"
                    "author TEXT,"
                    "date TEXT,"
                    "content TEXT,"

                    "PRIMARY KEY (id, article_id, article_type),"
                    "FOREIGN KEY (article_id, article_type) REFERENCES articles (id, type) ON DELETE CASCADE"
               ")");
    qDebug() << query.lastError().text();
    query.finish();
    //query.exec("INSERT INTO foobar VALUES (NULL, 'plop')");
    return true;
}

bool Database::migrate() {
    QSqlQuery q;
    DbUpdater *updater = new DbUpdater(this->db);

    q.prepare("SELECT value FROM config WHERE key='version'");
    if (!q.exec() || !q.first()) {
        qDebug() << "failed to read config table:" << q.lastError().text();
        return false;
    }
    int version = q.value("value").toInt();
    q.finish();

    qDebug() << "version current: " << version << ", target: " << DB_VERSION;
    if (version == DB_VERSION) {
        return true;
    }

    // Upgrading from version 1 to 2
    // NOTE: `comments` is a new table
    if (version < 2) {
        QStringList queries = {
            "ALTER TABLE articles ADD COLUMN readtime TEXT",
            "ALTER TABLE articles ADD COLUMN author TEXT",
            "ALTER TABLE articles ADD COLUMN pubdate TEXT",
            "ALTER TABLE articles ADD COLUMN content TEXT"
        };
        if (!updater->exec(2, queries)) {
			return false;
		}
    }

    if (version < 3) {
        /*
         * PRIMARY KEY update cannot be done with ALTER TABLE command
         * we need to create a new table, copy data from old one and finally delete the old table
         * see https://www.sqlite.org/lang_altertable.html#otheralter
         */
        QStringList queries = {
            "CREATE TABLE IF NOT EXISTS new_articles ("
                "id INTEGER, type INTEGER DEFAULT 0, date TEXT, timestamp TEXT, title TEXT,"
                "subtitle TEXT, nb_comments INTEGER, icon BLOB, link TEXT, readtime TEXT,"
                "author TEXT, pubdate TEXT, content TEXT, unread INTEGER DEFAULT 1,"
                "new_comments INTEGER DEFAULT 1, parent INTEGER DEFAULT -1,"
                "PRIMARY KEY (id, type))",
            "INSERT INTO new_articles "
                "SELECT id, 0, date, timestamp, title, subtitle, nb_comments, icon, link, readtime,"
                "author, pubdate, content, unread, new_comments, -1 FROM articles",

            "CREATE TABLE IF NOT EXISTS new_comments ("
                "id INTEGER, article_id INTEGER, article_type INTEGER, author TEXT, date TEXT,"
                "content TEXT,"
                "PRIMARY KEY (id, article_id, article_type),"
                "FOREIGN KEY (article_id, article_type) REFERENCES articles (id, type) "
                    "ON DELETE CASCADE)",
            "INSERT INTO new_comments "
                "SELECT id, artid, 0, author, date, content FROM comments",

            "DROP TABLE articles",
            "DROP TABLE comments",
            "ALTER TABLE new_articles RENAME TO articles",
            "ALTER TABLE new_comments RENAME TO comments"
        };
        if (!updater->exec(3, queries)) {
            return false;
        }
    }

    return true;
}

/*
 * storeMigration is when migrating from openrepos NextInpact application to harbour-nextinpact
 * Jolla store application.
 * The purpose is to copy legacy database to use it in the new application
 * (database format is exactly the same).
 */
bool Database::storeMigration(QString dbpath) {
    if (QFileInfo::exists(dbpath)) {
        return true;
    }

    QString legacyDb = QString("%1/NextInpact/NextInpact/nextinpact.db").\
            arg(QStandardPaths::writableLocation(QStandardPaths::GenericDataLocation));
    if (!QFileInfo::exists(legacyDb)) {
        return true;
    }

    QString body = QString(
        "We successfully imported your NextInpact database \"%1\" to harbour-nextinpact.\n"
        "You can now uninstall NextInpact application and delete the legacy database.").arg(legacyDb);
    bool ret = QFile::copy(legacyDb, dbpath);
    if (!ret) {
        body = QString(
            "Legacy database import from \"%1\" failed. "
            "You can do it manually by copying the database in \"%2/\" directory.").arg(
               legacyDb, QStandardPaths::writableLocation(QStandardPaths::AppDataLocation)
        );
    }
    QString summary = ret ? "Data migration succeed !" : "Data migration failed !";

    Notification *notif = new Notification();
    notif->setAppIcon("harbour-nextinpact");
    notif->setAppName("NextInpact");
    notif->setMaxContentLines(20);
    notif->setSummary(summary);
    notif->setBody(body);

    notif->publish();
    return ret;
}

QVariantMap Database::getConfig(QString keyprefix) {
    QVariantMap config;

    QSqlQuery q;
    q.prepare("SELECT key, value FROM config WHERE key LIKE :key");
    q.bindValue(":key", QString("%1.%").arg(keyprefix));
    if (!q.exec()) {
        qDebug() << QString("failed to get %1 config:").arg(keyprefix) << q.lastError().text();
        return config;
    }

    while (q.next()) {
        // NOTE: we remove the key prefix for result key
        config[q.value("key").toString().mid(keyprefix.length()+1)] = q.value("value");
    }

    return config;
}

bool Database::setConfig(QString key, QString value) {

    QSqlQuery q;
    q.prepare("INSERT OR REPLACE INTO config VALUES (:key, :value)");
    q.bindValue(":key", key);
    q.bindValue(":value", value);
    if (!q.exec()) {
        qDebug() << QString("failed to set %1 config:").arg(key) << q.lastError().text();
        return false;
    }

    return true;
}

/*
 * Returns database file size
 */
qint64 Database::size() const {
    // TODO: duplicated code. TO BE FACTORIZED
    static QString dbpath = QStandardPaths::writableLocation(QStandardPaths::AppDataLocation) % QString("/" DB_NAME);

    // directory is not automatically created if not exists
    // db.open() fails unless we create the directory tree
    QFileInfo fi(dbpath);
    return fi.size();
}

// DELETE ALL ARTICLES AND COMMENTS
void Database::flush() const {
    QSqlQuery q;
    q.exec("DELETE FROM comments");
    q.exec("DELETE FROM articles");
    if (!q.exec("VACUUM FULL")) {
        qDebug() << QString("VACUUM FULL failed:") << q.lastError().text();
    }
}

bool Database::cleanup() const {
    QSqlQuery q;

    if (!q.exec("SELECT value FROM config WHERE key = 'cleanup.frequency'")) {
        qDebug() << "Failed to get cleanup frequency:" << q.lastError().text();
        return false;
    }

    int freq = 0;
    if (q.first()) {
        freq = q.value("value").toInt();
    }

    if (freq == 0) {
        qDebug() << "db cleanup disabled";
        return true;
    }

    qDebug() << QString("Cleaning database:: deleting articles & comments older than %1 days").arg(freq);
    if (!q.exec(QString("DELETE FROM articles WHERE date <= DATETIME('now', 'start of day', '-%1 month')").arg(freq))) {
        qDebug() << "Failed to clean articles:" << q.lastError().text();
        return false;
    }
    qDebug() << q.lastQuery() << QString("%1 rows deleted").arg(q.numRowsAffected());

    return true;
}

