
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

    this->db = QSqlDatabase::addDatabase("QSQLITE");
    this->db.setDatabaseName("jolla-nextinpact");
    if (!this->db.open()) {
        qDebug() << "cannot open sqlite database";
        return false;
    }

    QSqlQuery query;
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
                    // bool flags
                    "unread INTEGER,"
                    "new_comments INTEGER"
               ")");
    qDebug() << query.lastError().text();

    //query.exec("INSERT INTO foobar VALUES (NULL, 'plop')");
    return true;
}

bool Database::articleAdd(const QVariantMap values) {
    qDebug() << "db.articleAdd" << values["title"];

    QSqlQuery q;
    q.prepare("INSERT OR IGNORE INTO articles (id, date, timestamp, title, subtitle, nb_comments, icon, link, unread) "
              "VALUES (:id, :date, :timestamp, :title, :subtitle, :nb_comments, :icon, :link, :unread)");

    q.bindValue(":id"         , values["id"]);
    q.bindValue(":date"       , values["date"]);
    q.bindValue(":timestamp"  , values["timestamp"]);
    q.bindValue(":title"      , values["title"]);
    q.bindValue(":subtitle"   , values["subtitle"]);
    q.bindValue(":nb_comments", values["comments"]);
    q.bindValue(":icon"       , values["icon"]);
    q.bindValue(":link"       , values["link"]);
    q.bindValue(":unread"     , true);
    bool ret = q.exec();
    if (!ret) {
        qDebug() << "insert failed:" << q.lastError().text();
        return false;
    }

    qDebug() << "inserted rows: " << q.numRowsAffected();
    if (q.numRowsAffected() > 0) {
        return true;
    }

    return ret;
}


