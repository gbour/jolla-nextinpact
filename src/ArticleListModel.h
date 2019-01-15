#ifndef ARTICLELISTMODEL_H
#define ARTICLELISTMODEL_H

#include <QObject>
#include <QSqlQueryModel>

class ArticleListModel : public QSqlQueryModel
{
    Q_OBJECT
    Q_PROPERTY(qint32 type READ type WRITE setType)
public:
    enum Roles {
        IdRole = Qt::UserRole + 1,
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
    qint32 type() const {
        return m_type;
    }
    void setType(const qint32 type) {
        this->m_type = type;
    }

protected:
    QHash<int, QByteArray> roleNames() const;
    qint32 m_type;

signals:

public slots:
    void updateModel();
    int getId(int row);
};

#endif // ARTICLELISTMODEL_H
