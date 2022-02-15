#include "player.h"
QImage image;
ablumimage::ablumimage()
    : QQuickImageProvider(QQuickImageProvider::Image)
{
}

QImage ablumimage::requestImage(const QString &id, QSize *size, const QSize &requestedSize)
{
    return image;
}

musicplayer::musicplayer(QObject *parent) : QObject(parent)
{
}
musicplayer::~musicplayer()
{
}

void musicplayer::next()
{
    if (!shuffle)
    {
        if (current_music_num < music_num)
        {
            current_music_num++;
        }
    }
    else
    {
        shuffler.seed(QTime::currentTime().msec());
        current_music_num = shuffler.bounded(0, music_num);
    }
    if (player.playbackState() == 1)
    {
        Musicinfo=list.at(current_music_num).value<m_info>();
        player.setSource(QUrl::fromLocalFile(Musicinfo.Url));
        player.play();
    }
    else
    {
        Musicinfo=list.at(current_music_num).value<m_info>();
        player.setSource(QUrl::fromLocalFile(Musicinfo.Url));
    }
}

void musicplayer::previous()
{
    if (!shuffle)
    {
        if (current_music_num > 0)
        {
            current_music_num--;
        }
    }
    else
    {
        shuffler.seed(QTime::currentTime().msec());
        current_music_num = shuffler.bounded(0, music_num);
    }
    if (player.playbackState() == 1)
    {
        Musicinfo=list.at(current_music_num).value<m_info>();
        player.setSource(QUrl::fromLocalFile(Musicinfo.Url));
        player.play();
    }
    else
    {
        Musicinfo=list.at(current_music_num).value<m_info>();
        player.setSource(QUrl::fromLocalFile(Musicinfo.Url));
    }
}

void musicplayer::end_next()
{
    if (player.mediaStatus() == 6 && loop == false)
    {
        if (!shuffle)
        {
            if (current_music_num < music_num)
            {
                current_music_num++;
            }
        }
        else
        {
            shuffler.seed(QTime::currentTime().msec());
            current_music_num = shuffler.bounded(0, music_num);
        }
        Musicinfo=list.at(current_music_num).value<m_info>();
        player.setSource(QUrl::fromLocalFile(Musicinfo.Url));
        player.play();
    }
}

void musicplayer::get_metadata()
{
    QMediaMetaData info = player.metaData();
    image = info.value(info.ThumbnailImage).value<QImage>();
    emit metadata_get();
}

void musicplayer::get_pos()
{
    emit pos_get();
}

void musicplayer::pause()
{
    player.pause();
}

void musicplayer::play()
{
    player.play();
}

QVariantMap musicplayer::give_metadata(void)
{
    QVariantMap map;
    map.clear();
    map.insert("Author", Musicinfo.Author);
    map.insert("Title", Musicinfo.Title);
    map.insert("Ablum", Musicinfo.Album);
    return map;
}

QVariantMap musicplayer::give_pos(void)
{
    QVariantMap Map;
    Map.clear();
    Map.insert("pos", player.position());
    Map.insert("dur", player.duration());
    return Map;
}

void musicplayer::set_pos(qreal pos)
{
    player.setPosition(pos * player.duration());
}

void musicplayer::play_mode(int mode)
{
    switch (mode)
    {
    case 1:
    {
        shuffle = false;
        loop = true;
        player.setLoops(-1);
        qDebug() << "loop mode";
        break;
    }
    case 2:
    {
        shuffle = false;
        loop = false;
        player.setLoops(1);
        qDebug() << "order mode";
        break;
    }
    case 3:
    {
        shuffle = true;
        loop = false;
        player.setLoops(1);
        qDebug() << "shuffle mode";
        break;
    }
    }
}

void musicplayer::appdata_store(QUrl url, bool newfolder)
{
    const QStringList filefilter = {"*.mp3", "*.wav", "*.m4a", "*.wma", "*.flac", "*.aac", "*.ape"};
    QDir dir;
    QSqlDatabase mediadatabase;
    mediadatabase = QSqlDatabase::addDatabase("QSQLITE", "store");
    mediadatabase.setDatabaseName("metadata.db");
    if (!mediadatabase.open())
    {
        qDebug() << "Error: Failed to connect database." << mediadatabase.lastError();
    }
    else
    {
        qDebug() << "Succeed to connect database.";
    }
    QSqlQuery query(mediadatabase);
    if (newfolder == true)
    {
        if (!query.exec("drop table playlist"))
        {
            qDebug() << query.lastError();
        }
        else
        {
            qDebug() << "table cleared";

        }
        if (!query.exec("create table playlist (id, url,title,artist,album,duration)"))
        {
            qDebug() << "Error: Fail to create table." << query.lastError();
            return;
        }
        else
        {
            qDebug() << "Table created!";
        }
    }
    dir.setPath(url.toString());
    QDirIterator file(dir.absolutePath(), filefilter, QDir::Files, QDirIterator::Subdirectories);
    while (file.hasNext())
    {
        file.next();
        QFileInfo info = file.fileInfo();
        if (info.isFile())
        {
            TagLib::FileRef f(info.absoluteFilePath().toStdWString().data());
            TagLib::String artist = f.tag()->artist();
            TagLib::String title = f.tag()->title();
            TagLib::String album = f.tag()->album();
            TagLib::ulonglong duration=f.audioProperties()->length();
            query.prepare("INSERT INTO playlist (id, url,title,artist,album,duration) "
                          "VALUES (?, ?, ?, ?, ? ,?)");
            query.addBindValue(music_num);
            query.addBindValue(info.absoluteFilePath());
            query.addBindValue(QString::fromStdWString(title.toWString()));
            query.addBindValue(QString::fromStdWString(artist.toWString()));
            query.addBindValue(QString::fromStdWString(album.toWString()));
            query.addBindValue(duration);
            music_num++;
            if (!query.exec())
            {
                qDebug() << query.lastError();
                mediadatabase.close();
                return;
            }
        }
    }
    mediadatabase.close();
}
void musicplayer::start()
{
    QSqlDatabase mediadatabase;
    mediadatabase = QSqlDatabase::addDatabase("QSQLITE", "read");
    mediadatabase.setDatabaseName("metadata.db");
    if (!mediadatabase.open())
    {
        qDebug() << "Error: Failed to connect database." << mediadatabase.lastError();
    }
    else
    {
        qDebug() << "Succeed to connect database.";
    }
    QSqlQuery query(mediadatabase);
    if (!query.exec("select * from playlist"))
    {
        qDebug() << query.lastError();
        emit no_playlist();
        mediadatabase.close();
        return;
    }
    else
    {
        while(query.next())
        {
            /*将音频信息打包为结构体写入链表*/
            m_info music_info;
            QVariant info_pack;
            music_info.Url = query.value(1).toString();
            music_info.Title = query.value(2).toString();
            music_info.Author = query.value(3).toString();
            music_info.Album = query.value(4).toString();
            music_info.Dur = query.value(5).toULongLong();
            info_pack.setValue(music_info);
            list.append(info_pack);
            music_num++;
        }
    }
    player.setAudioOutput(&audioOutput);
    /*从链表中读取第一个结构体*/
    Musicinfo=list.at(current_music_num).value<m_info>();
    player.setSource(QUrl::fromLocalFile(Musicinfo.Url));
    player.play();
    connect(&player, &QMediaPlayer::mediaStatusChanged, this, &musicplayer::end_next);
    connect(&player, &QMediaPlayer::durationChanged, this, &musicplayer::get_metadata);
    connect(&player, &QMediaPlayer::positionChanged, this, &musicplayer::get_pos);
}
