#ifndef COMMENTLISTMODEL_H
#define COMMENTLISTMODEL_H

#include <QObject>
#include <QSqlQueryModel>

class CommentListModel : public QSqlQueryModel
{
    Q_OBJECT
    Q_PROPERTY(qint32 articleId READ articleId WRITE setArticleId)
public:
    enum Roles {
        IdRole = Qt::UserRole + 1,
        AuthorRole,
        DateRole,
        ContentRole
    };

    explicit CommentListModel(QObject *parent = 0);
    QVariant data(const QModelIndex &index, int role) const;
    void setArticleId(const qint32 articleId);
    qint32 articleId() const {
        return m_articleId;
    }

private:
    qint32 m_articleId;

protected:
    QHash<int, QByteArray> roleNames() const;

signals:

public slots:
    void updateModel();
    int getId(int row);
};

#endif // COMMENTLISTMODEL_H
