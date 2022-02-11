#ifndef PLAYER_H
#define PLAYER_H
#include <QMediaPlayer>
#include <QFile>
#include <QDir>
#include <QAudioOutput>
#include <QDirIterator>
#include <QStringList>
#include <QThread>
#include <QMediaMetaData>
#include <QQuickImageProvider>


struct m_info
{
    QString Title;
    QString Author;
    QString AlbumTitle;
    QImage img;
    qint64 Pos;
    qint64 Dur;
};

class ablumimage : public QQuickImageProvider
{
    public:
    ablumimage();
    QImage requestImage(const QString &id, QSize *size, const QSize &requestedSize);
};

class musicplayer : public QObject
{
    Q_OBJECT
    public:
    Q_INVOKABLE void find();
    Q_INVOKABLE void start();
    Q_INVOKABLE QVariantMap give_metadata(void);
    Q_INVOKABLE QVariantMap give_pos(void);
    Q_INVOKABLE void set_pos(qreal);

    signals:
    void metadata_get();
    void pos_get();

    public slots:
    void end_next();
    void get_metadata();
    void get_pos();
    void next();
    void previous();
    void pause();
    void play();
};

#endif // PLAYER_H
