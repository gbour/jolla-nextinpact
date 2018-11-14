
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
                    "hour TEXT,"
                    "title TEXT,"
                    "subtitle TEXT,"
                    "nb_comments INTEGER,"
                    // base64 serialized image, including 'data:image/png;base64,' scheme
                    "icon BLOB,"
                    "unread INTEGER"
               ")");
    qDebug() << query.lastError().text();

    //query.exec("INSERT INTO foobar VALUES (NULL, 'plop')");
    return true;
}

bool Database::articleAdd(QVariantMap values) {
    //qDebug() << "db.articleAdd" << values;
    //qDebug() << values.keys() << values["subtitle"] << values["date"] << values["id"];

    QSqlQuery q;
    q.prepare("INSERT INTO articles (id, date, hour, title, subtitle, nb_comments, unread) "
              "VALUES (:id, :date, :hour, :title, :subtitle, :nb_comments, :unread)");

    q.bindValue(":id"         , values["id"]);
    q.bindValue(":date"       , values["date"]);
    q.bindValue(":hour"       , values["hour"]);
    q.bindValue(":title"      , values["title"]);
    q.bindValue(":subtitle"   , values["subtitle"]);
    q.bindValue(":nb_comments", values["comments"]);
    q.bindValue(":unread", true);
    bool ret = q.exec();

    return ret;
}


