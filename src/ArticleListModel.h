#ifndef ARTICLELISTMODEL_H
#define ARTICLELISTMODEL_H

#include <QObject>
#include <QSqlQueryModel>

class ArticleListModel : public QSqlQueryModel
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
        UnreadRole,
        NewCommentsRole,
        SectionRole
    };

    explicit ArticleListModel(QObject *parent = 0);
    QVariant data(const QModelIndex &index, int role) const;

protected:
    QHash<int, QByteArray> roleNames() const;

signals:

public slots:
    void updateModel();
    int getId(int row);
};

#endif // ARTICLELISTMODEL_H
