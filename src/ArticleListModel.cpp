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

#include "ArticleListModel.h"
#include <QDateTime>
#include <QSqlRecord>

#include "database.h"

ArticleListModel::ArticleListModel(QObject *parent, QSqlDatabase db) : QSqlTableModel(parent, db)
{
    this->setEditStrategy(EditStrategy::OnRowChange);

    this->setTable("articles");

    this->setSort(DateRole- Qt::UserRole - 1, Qt::DescendingOrder);
    qDebug() << "articles model populating:" << this->selectStatement();

    this->update();
}

void ArticleListModel::update() {
    // Filtering articles.
    // Depends on user-defined filters.
    // Filters values are saved in _config_ table, with key like 'articles.filters.NAME'
    // where NAME is one of 'type' or 'status'
    QString filter = QString("type < 90");
    QString keyprefix = QString("articles.filters");

    // TODO: refactor*
    QMap<QString, QList<QString>> choices;
    QList<QString> types; types << "articles" << "lebrief";
    choices["type"] = types;
    QList<QString> status; status << "read" << "unread";
    choices["status"] = status;

    QMap<QString, QString> dbfields;
    dbfields["type"]     = "type";
    dbfields["status"]   = "unread";
    dbfields["tag"]      = "tag";
    dbfields["favorite"] = "star";

    QSqlQuery q;
    q.prepare("SELECT key, value FROM config WHERE key LIKE :key");
    q.bindValue(":key", QString("%1.%").arg(keyprefix));
    if (!q.exec()) {
        qDebug() << "failed to read filters from config table" << q.lastError().text();
        // NOTE: here we don't return. Thus we still apply basic filter
    }
    while (q.next()) {
        QString key   = q.value("key").toString().mid(keyprefix.length()+1);
        QString value = q.value("value").toString();

        // bool value. true == filter enabled
        if (key == "favorite") {
            if (value == "true") {
                filter += QString(" AND %1 = 1").arg(dbfields[key]);
            }
        } else if (value == "all") {
            // do nothing
        } else if (choices.contains(key)) {
            // we use value index in choices array as filter value
            QList<QString> alts = choices.value(key);
            if (alts.indexOf(q.value("value").toString()) >= 0) {
                filter += QString(" AND %1 = %2").arg(dbfields[key]).arg(alts.indexOf(q.value("value").toString()));
            }
        } else {
            // we use raw value
            filter += QString(" AND %1 = '%2'").arg(dbfields[key]).arg(value);
        }
    }

    //qDebug() << "filter:" << filter;
    QSqlTableModel::setFilter(filter);

    // updating datas (do query)
    this->select();
}

int ArticleListModel::columnCount(const QModelIndex &parent) const {
    // we add 1 calculated column (date part of article datetime)
    return QSqlTableModel::columnCount(parent) + 1;
}

QVariant ArticleListModel::data(const QModelIndex &index, int role) const {
    //qDebug() << "articlemodel::data" << index << role;
    if (role < Qt::UserRole) {
        return QSqlTableModel::data(index, role);
    } else if (role == SectionRole) {
        QString datetime = QSqlTableModel::data(this->index(index.row(),  DateRole),
                                                Qt::DisplayRole).toString();
        return QDateTime::fromString(datetime, "yyyy-MM-ddTHH:mm:ss.zzz").toString("yyyy-MM-dd");
    }

    QModelIndex idx = this->index(index.row(), role);
    return QSqlTableModel::data(idx, Qt::DisplayRole);
}

QHash<int, QByteArray> ArticleListModel::roleNames() const {
    qDebug() << "articlemodel::roleNames";

    QHash<int, QByteArray> roles;
    roles[IdRole]   = "id";
    roles[TypeRole] = "type";
    roles[DateRole] = "date";
    roles[TimestampRole] = "timestamp";
    roles[TitleRole] = "title";
    roles[SubtitleRole] = "subtitle";
    roles[NbCommentsRole] = "nbcomments";
    roles[IconRole] = "icon";
    roles[LinkRole] = "link";
    roles[ReadTimeRole] = "readtime";
    roles[AuthorRole] = "author";
    roles[PubDateRole] = "pubdate";
    roles[ContentRole] = "content";
    roles[UnreadRole] = "unread";
    roles[NewCommentsRole] = "new_comments";
    roles[ParentRole] = "parent";
    roles[TagRole] = "tag";
    roles[SubtagRole] = "subtag";
    roles[StarRole] = "star";
    roles[SubscriberRole] = "subscriber";
    roles[SectionRole] = "section";

    return roles;
}

int ArticleListModel::getId(int row) {
    //qDebug() << "articlemodel::getid" << row;
    return this->data(this->index(row, IdRole), IdRole).toInt();
}

/*
 * For now on, we continue to add article directly into database using QSqlQuery instead of
 * insertRecord(QSqlRecord) for 2 reasons:
 * - some inserted articles must not be displayed (original LeBrief)
 * - it is hard to respect articles order
 *
 * As QSqlTableModel cannot "re-filter" and "re-sort" items on the fly,
 * after having added all articles, we reload items from database with select() command
 *
 */
bool ArticleListModel::addArticle(const QVariantMap values) {
    qDebug() << "adding article id" << values["id"] << "," << values["title"];

    QSqlQuery q;
    q.prepare("INSERT OR IGNORE INTO articles (id, type, date, timestamp, title, subtitle, nb_comments, icon, link, author, parent, content, tag, subtag, subscriber) "
              "VALUES (:id, :type, :date, :timestamp, :title, :subtitle, :nb_comments, :icon, :link, :author, :parent, :content, :tag, :subtag, :subscriber)");

    q.bindValue(":id"         , values["id"]);
    q.bindValue(":type"       , values.value("type", 0));
    q.bindValue(":date"       , values["date"]);
    q.bindValue(":timestamp"  , values["timestamp"]);
    q.bindValue(":title"      , values["title"]);
    q.bindValue(":subtitle"   , values.value("subtitle", QVariant())); // QVariant() is for NULL
    q.bindValue(":nb_comments", values["comments"]);
    q.bindValue(":icon"       , values.value("icon", QVariant()));
    q.bindValue(":link"       , values["link"]);
    q.bindValue(":author"     , values["author"]);
    q.bindValue(":parent"     , values.value("parent", -1));
    q.bindValue(":content"    , values.value("content", QVariant()));
    q.bindValue(":tag"        , values.value("tag", QVariant()));
    q.bindValue(":subtag"     , values.value("subtag", QVariant()));
    q.bindValue(":subscriber" , values.value("subscriber", false));
    bool ret = q.exec();
    if (!ret) {
        qDebug() << "insert failed:" << q.lastError().text();
        return false;
    }

    qDebug() << "inserted rows: " << q.numRowsAffected();
    if (q.numRowsAffected() > 0) {
        return true;
    }

    // if article already exists
    q.prepare("UPDATE articles SET nb_comments = :nb_comments, new_comments = 1 "
              "WHERE id = :id AND type = :type AND nb_comments < :nb_comments");
    q.bindValue(":id"         , values["id"]);
    q.bindValue(":type"       , values.value("type", 0));
    q.bindValue(":nb_comments", values["comments"]);
    ret = q.exec();
    if (!ret) {
        qDebug() << "update failed:" << q.lastError().text();
        return false;
    }

    qDebug() << "updated rows: " << q.numRowsAffected();
    return ret;
}

bool ArticleListModel::setContent(const int row, const QVariantMap values) {
    //NOTE: needs to set an edit strategy w/ setEditStrategy().
    //this->setData(this->index(row, ReadTimeRole), values["readtime"]);
    //this->setData(this->index(row, AuthorRole)  , values["author"]);
    //this->setData(this->index(row, PubDateRole) , values["pubdate"]);
    this->setData(this->index(row, ContentRole) , values["content"]);
    //this->setData(this->index(row, TagRole)     , values["tag"]);
    //this->setData(this->index(row, SubtagRole)  , values["subtag"]);

    return this->submit();
}

bool ArticleListModel::toggleRead(const int row, const bool read) {
    this->setData(this->index(row, UnreadRole), !read);
    return this->submit();
}

bool ArticleListModel::toggleFavorite(const int row, const bool favorite) {
    this->setData(this->index(row, StarRole), !favorite);
    return this->submit();
}

QVariantMap ArticleListModel::stats() {
    // returns statistics regarding articles (cover page)
    // - total articles
    // - unread articles
    QVariantMap stats;

    QSqlQuery q;
    q.prepare(
        "SELECT 'unread' AS key, count(*) AS value FROM articles WHERE type < 99 AND unread = 1 UNION "
        "SELECT 'total', count(*) FROM articles WHERE type < 99");
    if (!q.exec()) {
        qDebug() << "failed to get articles stats:" << q.lastError().text();
        return stats;
    }

    while (q.next()) {
        stats[q.value("key").toString()] = q.value("value");
    }

    return stats;
}

QVariantMap ArticleListModel::stats2() const {
    // returns overall statistics (stats page)
    // - read/unread/total articles
    // - read/unread/total lebrief
    QVariantMap stats;

    QSqlQuery q;
    q.prepare(
        "SELECT CASE type WHEN 0 THEN 'article' ELSE 'lebrief' END AS type, "
               "CASE unread WHEN 0 THEN 'read' ELSE 'unread' END AS read, "
               "COUNT(*) AS value FROM articles WHERE type < 99 GROUP BY type, unread UNION "
        "SELECT CASE type WHEN 0 THEN 'article' ELSE 'lebrief' END AS type, "
               "'total' AS read, COUNT(*) AS value FROM articles WHERE type < 99 GROUP BY type");
    if (!q.exec()) {
        qDebug() << "failed to get articles stats2:" << q.lastError().text();
        return stats;
    }

    while (q.next()) {
        stats[QString("%1-%2").arg(q.value("type").toString()).arg(q.value("read").toString())] = q.value("value").toInt();

    }

    return stats;
}

bool ArticleListModel::v7MigrateArticle(const QVariantMap values) {
    qDebug() << "migrate article from v6 to v7 if exists: " << values["id"] << "," << values["title"];

    int count = 0;
    QSqlQuery q, q2, q3;
    q.exec("PRAGMA foreign_keys = OFF");
    q.finish();

    q.prepare("SELECT id FROM articles WHERE title = :title");
    q.bindValue(":title", values["title"]);
    if (!q.exec()) {
        qDebug() << QString("failed searching article") << q.lastError().text();
        q.finish();

        q.exec("PRAGMA foreign_keys = ON");
        q.finish();
        return false;
    }

    //NOTE: q.size() not supported by sqlite
    q2.prepare("UPDATE articles SET id=:id, nb_comments=:nb_comments, icon=:icon, tag=:tag, subtag=:subtag, subscriber=:subscriber, date=:date, author=:author, timestamp='', link='' WHERE id=:oldid");
    q3.prepare("UPDATE comments SET article_id=:new_id WHERE article_id=:old_id");

    while (q.next()) {
        count++;
        qDebug() << "  . updating, from id" << q.value("id") << "to" << values["id"];
        if (q.value("id") == values["id"]) {
            // already the same
            qDebug() << "    - same ids, skipping";
            continue;
        }

        // Updating article
        q2.bindValue(":oldid", q.value("id"));
        q2.bindValue(":id", values["id"]);
        q2.bindValue(":nb_comments", values["comments"]);
        q2.bindValue(":icon", values["icon"]);
        q2.bindValue(":tag", values["tag"]);
        q2.bindValue(":subtag", values["subtag"]);
        q2.bindValue(":subscriber", values["subscriber"]);
        q2.bindValue(":date", values["date"]);
        q2.bindValue(":author", values["author"]);

        if(!q2.exec()) {
            qDebug() << "    - articles update failed:" << q2.lastError().text();
            continue;
        }
        qDebug() << "    - articles rows affected:" << q2.numRowsAffected();


        // Updating comments
        q3.bindValue(":old_id", q.value("id"));
        q3.bindValue(":new_id", values["id"]);
        if(!q3.exec()) {
            qDebug() << "    - comments update failed:" << q3.lastError().text();
            continue;
        }
        qDebug() << "    - comments rows affected:" << q3.numRowsAffected();
    }
    q.finish();

    q.exec("PRAGMA foreign_keys = ON");
    q.finish();

    switch (count) {
    case 0:
        qDebug() << "   . article not found, inserting";
        return this->addArticle(values);
    case 1:
        break;
    default:
        qDebug() << "  . more than 1 matching article found, entering the twilight zone @@@";
    }

    return true;
}
