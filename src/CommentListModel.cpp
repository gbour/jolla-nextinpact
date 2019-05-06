#include "CommentListModel.h"
#include <QDateTime>
#include <QSqlRecord>

#include "database.h"

CommentListModel::CommentListModel(QObject *parent, QSqlDatabase db) : QSqlTableModel(parent, db)
{
    this->setTable("comments");
    this->setSort(0, Qt::AscendingOrder);
}

/*
 * on setting articleId, we update TableModel filter and do the db query to
 * fill TableModel rows
 */
void CommentListModel::setArticle(const qint32 articleId, const qint32 articleType) {
    qDebug() << "set article:" << articleId << articleType;
    this->m_articleId = articleId;
    this->m_articleType = articleType;

    this->setFilter(QString("article_id=%1 AND article_type=%2").arg(articleId).arg(articleType));
    qDebug() << "comments model populating:" << this->selectStatement();
    this->select();
}

QVariant CommentListModel::data(const QModelIndex &index, int role) const {
    //qDebug() << "Commentmodel::data" << index << role;
    if (role < Qt::UserRole) {
        return QSqlTableModel::data(index, role);
    }

    int colId = role - Qt::UserRole - 1;
    QModelIndex idx = this->index(index.row(), colId);

    QVariant res = QSqlTableModel::data(idx, Qt::DisplayRole);
    return res;
}


QHash<int, QByteArray> CommentListModel::roleNames() const {
    qDebug() << "Commentmodel::roleNames";

    QHash<int, QByteArray> roles;
    roles[IdRole]          = "id";
    roles[ArticleIdRole]   = "article_id";
    roles[ArticleTypeRole] = "article_type";
    roles[AuthorRole]      = "author";
    roles[DateRole]        = "date";
    roles[ContentRole]     = "content";

    return roles;
}

int CommentListModel::getId(int row) {
    //qDebug() << "Commentmodel::getid" << row;
    return this->data(this->index(row, 0), IdRole).toInt();
}

bool CommentListModel::addComment(const QVariantMap comment) {
    qDebug() << "adding comment" << this->m_articleId << this->m_articleType;
    // rec is an empty record, with fieldnames already set
    QSqlRecord rec = this->record();

    rec.setValue("id"          , comment["num"]);
    rec.setValue("article_id"  , this->m_articleId);
    rec.setValue("article_type", this->m_articleType);
    rec.setValue("author"      , comment["author"]);
    rec.setValue("date"        , comment["date"]);
    rec.setValue("content"     , comment["content"]);

    // insert at the end.
    // NOTE: this is automatically refreshing the upper QML ListView
    bool ret = this->insertRecord(-1, rec);
    if (!ret) {
        qDebug() << "failed to inserted comment (artid " << this->m_articleId << ", id " << comment["num"] << rec << ")";
    }


    return ret;
}

