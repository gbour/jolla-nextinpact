#ifndef COMMENTLISTMODEL_H
#define COMMENTLISTMODEL_H

#include <QObject>
#include <QSqlTableModel>

class CommentListModel : public QSqlTableModel
{
    Q_OBJECT
    Q_PROPERTY(qint32 articleId READ articleId WRITE setArticleId)
public:
    //NOTE; with QSqlTableModel, all table fields are returned
    enum Roles {
        IdRole = Qt::UserRole + 1,
        ArtIdRole,
        AuthorRole,
        DateRole,
        ContentRole
    };

    explicit CommentListModel(QObject *parent = 0, QSqlDatabase db = QSqlDatabase());
    Q_INVOKABLE QVariant data(const QModelIndex &index, int role=Qt::DisplayRole) const;
    Q_INVOKABLE bool addComment(const QVariantMap comment);

    void setArticleId(const qint32 articleId);
    qint32 articleId() const {
        return m_articleId;
    }

private:
    qint32 m_articleId;
    QHash<int, QByteArray> roles;

protected:
    QHash<int, QByteArray> roleNames() const;

signals:

public slots:
    int getId(int row);
};

#endif // COMMENTLISTMODEL_H
