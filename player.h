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
#include <QRandomGenerator>
#include <QSqlDatabase>
#include <QSqlError>
#include <QSqlQuery>
#include <tag.h>
#include <fileref.h>
#include <tpropertymap.h>
#include <audioproperties.h>
#include <QTime>
#include <QCursor>

class ablumimage : public QQuickImageProvider
{
public:
    ablumimage();
    QImage requestImage(const QString &id, QSize *size, const QSize &requestedSize);
};

class musicplayer : public QObject
{
public:
    musicplayer(QObject *parent = 0);
    ~musicplayer();
    QMediaPlayer player;
    QAudioOutput audioOutput;
    QVariantList list;
    QRandomGenerator shuffler;

private:
    struct m_info
    {
        QString Url;
        QString Title;
        QString Author;
        QString Album;
        qint64 Dur;
    };
    qint64 music_num = 0;
    qint64 current_music_num = 0;
    bool shuffle =false;
    bool loop=false;
    m_info Musicinfo;

    Q_OBJECT
public:    
    Q_INVOKABLE QVariantMap give_metadata(void);
    Q_INVOKABLE QVariantMap give_pos(void);
signals:
    void metadata_get();
    void pos_get();
    void no_playlist();

public slots:
    void start();
    void set_pos(qreal);
    void end_next();
    void get_metadata();
    void get_pos();
    void next();
    void previous();
    void pause();
    void play();
    void play_mode(int);
    void appdata_store(QUrl url,bool newfolder);
};

/*窗口抖动解决：https://stackoverflow.com/questions/39088835/dragging-frameless-window-jiggles-in-qml*/
class CursorPosProvider : public QObject
{
    Q_OBJECT
public:
    explicit CursorPosProvider(QObject *parent = nullptr) : QObject(parent)
    {
    }
    virtual ~CursorPosProvider() = default;

    Q_INVOKABLE QPointF cursorPos()
    {
        return QCursor::pos();
    }
};
#endif // PLAYER_H
