
#include <QStandardPaths>
#include <QStringBuilder>
#include <QFileInfo>
#include <QDir>

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
    static QString dbpath = QStandardPaths::writableLocation(QStandardPaths::DataLocation) % QString("/" DB_NAME);

    // directory is not automatically created if not exists
    // db.open() fails unless we create the directory tree
    QFileInfo fi(dbpath);
    fi.dir().mkpath(".");

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

bool Database::articleAdd(const QVariantMap values) {
    qDebug() << "db.articleAdd" << values["title"];

    QSqlQuery q;
    q.prepare("INSERT OR IGNORE INTO articles (id, type, date, timestamp, title, subtitle, nb_comments, icon, link, parent, content) "
              "VALUES (:id, :type, :date, :timestamp, :title, :subtitle, :nb_comments, :icon, :link, :parent, :content)");

    q.bindValue(":id"         , values["id"]);
    q.bindValue(":type"       , values.value("type", 0));
    q.bindValue(":date"       , values["date"]);
    q.bindValue(":timestamp"  , values["timestamp"]);
    q.bindValue(":title"      , values["title"]);
    q.bindValue(":subtitle"   , values.value("subtitle", QVariant())); // QVariant() is for NULL
    q.bindValue(":nb_comments", values["comments"]);
    q.bindValue(":icon"       , values.value("icon", QVariant()));
    q.bindValue(":link"       , values["link"]);
    q.bindValue(":parent"     , values.value("parent", -1));
    q.bindValue(":content"    , values.value("content", QVariant()));
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

bool Database::addComments(const int articleId, const QVariantList comments) {
    for(int i = 0; i < comments.size(); i++) {
        QVariantMap comment = comments.at(i).toMap();

        QSqlQuery q;
        q.prepare("INSERT OR IGNORE INTO comments VALUES (:id, :artid, :author, :date, :content)");
        q.bindValue(":artid"  , articleId);
        q.bindValue(":id"     , comment["num"]);
        q.bindValue(":author" , comment["author"]);
        q.bindValue(":date"   , comment["date"]);
        q.bindValue(":content", comment["content"]);
        if (!q.exec()) {
            qDebug() << "addComments failed:" << q.lastError().text();
        }
    }

    return true;
}


