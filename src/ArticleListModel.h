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

#ifndef ARTICLELISTMODEL_H
#define ARTICLELISTMODEL_H

#include <QObject>
#include <QSqlTableModel>

class ArticleListModel : public QSqlTableModel
{
    Q_OBJECT
public:
    enum Roles {
        IdRole = Qt::UserRole + 1,
        TypeRole,
        DateRole,
        TimestampRole,
        TitleRole,
        SubtitleRole,
        NbCommentsRole,
        IconRole,
        LinkRole,
        ReadTimeRole,
        AuthorRole,
        PubDateRole,
        ContentRole,
        UnreadRole,
        NewCommentsRole,
        ParentRole,
        SectionRole
    };

    explicit ArticleListModel(QObject *parent = 0, QSqlDatabase db = QSqlDatabase());
    int columnCount(const QModelIndex &parent) const;
    QVariant data(const QModelIndex &index, int role) const;

protected:
    QHash<int, QByteArray> roleNames() const;

private:
    int column(const int role) const {
        return role - Qt::UserRole - 1;
    }
    QModelIndex index(const int row, const int role) const
    {
        return QSqlTableModel::index(row, this->column(role));
    }

signals:

public slots:
    int getId(int row);
    bool addArticle(const QVariantMap values);
    bool setContent(const int row, const QVariantMap values);
    bool toggleRead(const int row, const bool read);
    QVariantMap stats();
};

#endif // ARTICLELISTMODEL_H
