#include "CommentListModel.h"
#include <QDateTime>
#include <QSqlRecord>

#include "database.h"

CommentListModel::CommentListModel(QObject *parent, QSqlDatabase db) : QSqlTableModel(parent, db)
{
    this->setTable("comments");
}

/*
 * on setting articleId, we update TableModel filter and do the db query to
 * fill TableModel rows
 */
void CommentListModel::setArticleId(const qint32 articleId) {
    qDebug() << "set articleId:" << articleId;
    this->m_articleId = articleId;

    this->setFilter(QString("artid='%1'").arg(articleId));
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
    roles[IdRole]      = "id";
    roles[ArtIdRole]   = "artid";
    roles[AuthorRole]  = "author";
    roles[DateRole]    = "date";
    roles[ContentRole] = "content";

    return roles;
}

int CommentListModel::getId(int row) {
    //qDebug() << "Commentmodel::getid" << row;
    return this->data(this->index(row, 0), IdRole).toInt();
}

bool CommentListModel::addComment(const QVariantMap comment) {
    // rec is an empty record, with fieldnames already set
    QSqlRecord rec = this->record();

    rec.setValue("artid"  , this->articleId());
    rec.setValue("id"     , comment["num"]);
    rec.setValue("author" , comment["author"]);
    rec.setValue("date"   , comment["date"]);
    rec.setValue("content", comment["content"]);

    // insert at the end.
    // NOTE: this is automatically refreshing the upper QML ListView
    bool ret = this->insertRecord(-1, rec);
    if (!ret) {
        qDebug() << "failed to inserted comment (artid " << this->articleId() << ", id " << comment["num"] << ")";
    }


    return ret;
}

