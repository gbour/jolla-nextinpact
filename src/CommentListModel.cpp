#include "CommentListModel.h"
#include <QDateTime>

#include "database.h"

CommentListModel::CommentListModel(QObject *parent) : QSqlQueryModel(parent)
{
    //this->updateModel();
}

void CommentListModel::setArticleId(const qint32 articleId) {
    qDebug() << "set articleId:" << articleId;
    this->m_articleId = articleId;
}

QVariant CommentListModel::data(const QModelIndex &index, int role) const {
    //qDebug() << "Commentmodel::data" << index << role;
    int colId = role - Qt::UserRole - 1;
    QModelIndex idx = this->index(index.row(), colId);

    QVariant res = QSqlQueryModel::data(idx, Qt::DisplayRole);
    return res;
}

QHash<int, QByteArray> CommentListModel::roleNames() const {
    qDebug() << "Commentmodel::roleNames";

    QHash<int, QByteArray> roles;
    roles[IdRole]      = "id";
    roles[AuthorRole]  = "author";
    roles[DateRole]    = "date";
    roles[ContentRole] = "content";

    return roles;
}

void CommentListModel::updateModel() {
    int rowCount = this->rowCount();

    QSqlQuery q;
    q.prepare("SELECT id, author, date, content FROM comments "
              "WHERE artid = :artid "
              "ORDER BY id ASC");
    q.bindValue(":artid", this->m_articleId);
    if (!q.exec()) {
        qDebug() << "updateModel failed:" << q.lastError().text();
        return;
    }


    //NOTE: q.size() is not supported by SQLite
    int count = -1;
    if (q.last()) {
        count = q.at() + 1;
        q.first();
    }

    qDebug() << "UPD" << rowCount << count << (count-rowCount-1);
    if (count <= rowCount) {
        return;
    }

    this->beginInsertRows(QModelIndex(), rowCount, count-rowCount-1);
    this->setQuery(q);
    this->endInsertRows();
    qDebug() << "updateModel:" << q.lastQuery() << this->m_articleId << q.size() << q.lastError().text() << this->rowCount();

}

int CommentListModel::getId(int row) {
    //qDebug() << "Commentmodel::getid" << row;
    return this->data(this->index(row, 0), IdRole).toInt();
}
