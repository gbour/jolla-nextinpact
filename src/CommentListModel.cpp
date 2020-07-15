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

    return QSqlTableModel::data(idx, Qt::DisplayRole);
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
    // rec is an empty record, with fieldnames already set
    QSqlRecord rec = this->record();

    //NOTE: why are we not using anymore CommentListModel articleId and articleType values ?
    //      There's only 1 CommentListModel instance running in QML (`commentsModel`),
    //      and if a user rapidly switch from a first article comments to a second article comments,
    //      and network is slow;
    //      when first article comments are finally downloaded and ready to be inserted in database,
    //      then CommentsListModel articleId and articleType values are those of the second article.
    QVariantMap article = comment["article"].toMap();
    qDebug() << "adding comment to article " << article["id"];

    rec.setValue("id"          , comment["num"]);
    rec.setValue("article_id"  , article["id"]);
    rec.setValue("article_type", article["type"]);
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

int CommentListModel::count() const {
    QSqlQuery q;
    q.prepare("SELECT COUNT(*) FROM comments");
    if (!q.exec()) {
        qDebug() << "failed to count comments:" << q.lastError().text();
        return -1;
    }

    q.next();
    return q.value(0).toInt();
}

