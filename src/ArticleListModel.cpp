#include "ArticleListModel.h"
#include <QDateTime>

#include "database.h"

ArticleListModel::ArticleListModel(QObject *parent) : QSqlQueryModel(parent)
{
    this->updateModel();
}

QVariant ArticleListModel::data(const QModelIndex &index, int role) const {
    //qDebug() << "articlemodel::data" << index << role;
    int colId = role - Qt::UserRole - 1;
    QModelIndex idx = this->index(index.row(), colId);

    QVariant res = QSqlQueryModel::data(idx, Qt::DisplayRole);
    return res;
}

QHash<int, QByteArray> ArticleListModel::roleNames() const {
    qDebug() << "articlemodel::roleNames";

    QHash<int, QByteArray> roles;
    roles[IdRole]   = "id";
    roles[DateRole] = "date";
    roles[TimestampRole] = "timestamp";
    roles[TitleRole] = "title";
    roles[SubtitleRole] = "subtitle";
    roles[NbCommentsRole] = "nbcomments";
    roles[IconRole] = "icon";
    roles[LinkRole] = "link";
    roles[UnreadRole] = "unread";
    roles[NewCommentsRole] = "new_comments";
    roles[SectionRole] = "section";

    return roles;
}

void ArticleListModel::updateModel() {
    //qDebug() << "articlemodel::update";
    this->setQuery("SELECT id, date, timestamp, title, subtitle, nb_comments, icon, link, unread, "
        "new_comments, DATE(date) AS section "
        "FROM articles ORDER BY date DESC");
}

int ArticleListModel::getId(int row) {
    //qDebug() << "articlemodel::getid" << row;
    return this->data(this->index(row, 0), IdRole).toInt();
}
