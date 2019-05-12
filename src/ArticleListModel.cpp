/*
    Copyright 2019 Guillaume Bour.
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
    roles[TypeRole] = "type";
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
    //this->setQuery("SELECT *, DATE(date) AS section FROM articles ORDER BY date DESC");
    this->setQuery("SELECT id, type, date, timestamp, title, subtitle, nb_comments, icon, link, unread, "
                   "new_comments, DATE(date) AS section "
                   "FROM articles WHERE type < 90 ORDER BY date DESC");
}

int ArticleListModel::getId(int row) {
    //qDebug() << "articlemodel::getid" << row;
    return this->data(this->index(row, 0), IdRole).toInt();
}
