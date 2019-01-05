
#include <QStandardPaths>
#include <QStringBuilder>

#include <src/database.h>

Database::Database(QObject *parent) : QObject(parent)
{
    this->init();
}

Database::~Database()
{}

bool Database::init()
{
    //qDebug() << QSqlDatabase::drivers();
    //TODO: check QSLITE driver is present ?
    static QString dbpath = QStandardPaths::writableLocation(QStandardPaths::DataLocation) % QString("/" DB_NAME);

    this->db = QSqlDatabase::addDatabase("QSQLITE");
    this->db.setDatabaseName(dbpath);
    if (!this->db.open()) {
        qDebug() << "cannot open sqlite database:" << this->db.lastError();
        return false;
    }

    QSqlQuery query;
    query.exec("CREATE TABLE IF NOT EXISTS config ("
                    "key   TEXT PRIMARY KEY,"
                    "value TEXT"
               ")");
    query.exec("INSERT OR IGNORE INTO config VALUES (\"version\", \"" DB_VERSION "\")");

    query.exec("CREATE TABLE IF NOT EXISTS articles ("
                    "id INTEGER PRIMARY KEY,"
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
                    "new_comments INTEGER DEFAULT 1"
               ")");
    qDebug() << query.lastError().text();

    //query.exec("INSERT INTO foobar VALUES (NULL, 'plop')");
    return true;
}

bool Database::articleAdd(const QVariantMap values) {
    qDebug() << "db.articleAdd" << values["title"];

    QSqlQuery q;
    q.prepare("INSERT OR IGNORE INTO articles (id, date, timestamp, title, subtitle, nb_comments, icon, link) "
              "VALUES (:id, :date, :timestamp, :title, :subtitle, :nb_comments, :icon, :link)");

    q.bindValue(":id"         , values["id"]);
    q.bindValue(":date"       , values["date"]);
    q.bindValue(":timestamp"  , values["timestamp"]);
    q.bindValue(":title"      , values["title"]);
    q.bindValue(":subtitle"   , values["subtitle"]);
    q.bindValue(":nb_comments", values["comments"]);
    q.bindValue(":icon"       , values["icon"]);
    q.bindValue(":link"       , values["link"]);
    bool ret = q.exec();
    if (!ret) {
        qDebug() << "insert failed:" << q.lastError().text();
        return false;
    }

    qDebug() << "inserted rows: " << q.numRowsAffected();
    if (q.numRowsAffected() > 0) {
        return true;
    }

    q.prepare("UPDATE articles SET nb_comments = :nb_comments, new_comments = 1 "
              "WHERE id = :id AND nb_comments < :nb_comments");
    q.bindValue(":id"         , values["id"]);
    q.bindValue(":nb_comments", values["comments"]);
    ret = q.exec();
    if (!ret) {
        qDebug() << "update failed:" << q.lastError().text();
        return false;
    }

    qDebug() << "updated rows: " << q.numRowsAffected();
    return ret;
}

bool Database::toggleRead(const int articleId, const bool read) {
    qDebug() << articleId << "marked as read";

    QSqlQuery q;
    q.prepare("UPDATE articles SET unread = :unread WHERE id = :id");
    q.bindValue(":id", articleId);
    q.bindValue(":unread", read ? 0 : 1);
    bool ret = q.exec();
    if (!ret) {
        qDebug() << "toggleRead failed:" << q.lastError().text();
        return false;
    }

    return true;
}

QVariant Database::getContent(const int articleId) {
    QVariantMap result;// = new QVariantMap();

    QSqlQuery q;
    q.prepare("SELECT title, subtitle, readtime, author, pubdate, content FROM articles WHERE id = :id");
    q.bindValue(":id", articleId);
    if (!q.exec() || !q.first()) {
        qDebug() << "getContent failed:" << q.lastError().text();
        return QVariant(); // NULL value
    }

    result["title"]    = q.value("title");
    result["subtitle"] = q.value("subtitle");
    result.insert("readtime", q.value("readtime"));
    result.insert("author"  , q.value("author"));
    result.insert("pubdate" , q.value("pubdate"));
    result.insert("content" , q.value("content"));

    return result;
}

bool Database::setContent(const int articleId, const QVariantMap values) {
    QSqlQuery q;
    q.prepare("UPDATE articles SET "
        "readtime = :readtime, "
        "author   = :author, "
        "pubdate  = :pubdate, "
        "content  = :content "
        "WHERE id = :id");
    q.bindValue(":readtime", values["readtime"]);
    q.bindValue(":author", values["author"]);
    q.bindValue(":pubdate", values["pubdate"]);
    q.bindValue(":content", values["content"]);
    q.bindValue(":id", articleId);
    if (!q.exec()) {
        qDebug() << "setContent failed:" << q.lastError().text();
        return false;
    }

    return true;
}


