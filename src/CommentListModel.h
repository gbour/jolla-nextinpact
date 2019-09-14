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

#ifndef COMMENTLISTMODEL_H
#define COMMENTLISTMODEL_H

#include <QObject>
#include <QSqlTableModel>

class CommentListModel : public QSqlTableModel
{
    Q_OBJECT
    Q_PROPERTY(qint32 articleId READ articleId)
    Q_PROPERTY(qint32 articleType READ articleType)
public:
    //NOTE; with QSqlTableModel, all table fields are returned
    enum Roles {
        IdRole = Qt::UserRole + 1,
        ArticleIdRole,
        ArticleTypeRole,
        AuthorRole,
        DateRole,
        ContentRole
    };

    explicit CommentListModel(QObject *parent = 0, QSqlDatabase db = QSqlDatabase());
    Q_INVOKABLE QVariant data(const QModelIndex &index, int role=Qt::DisplayRole) const;
    Q_INVOKABLE bool addComment(const QVariantMap comment);

    Q_INVOKABLE void setArticle(const qint32 articleId, const qint32 articleType);
    qint32 articleId() const {
        return m_articleId;
    }
    qint32 articleType() const {
        return m_articleType;
    }
    Q_INVOKABLE int count() const;

private:
    qint32 m_articleId;
    qint32 m_articleType;
    QHash<int, QByteArray> roles;

protected:
    QHash<int, QByteArray> roleNames() const;

signals:

public slots:
    int getId(int row);
};

#endif // COMMENTLISTMODEL_H
