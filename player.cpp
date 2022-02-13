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
        current_music_num = shuffler.bounded(0, music_num);
    }
    if (player.playbackState() == 1)
    {
        player.setSource(QUrl::fromLocalFile(Filelist.at(current_music_num)));
        player.play();
    }
    else
    {
        player.setSource(QUrl::fromLocalFile(Filelist.at(current_music_num)));
    }
}
void musicplayer::start(QUrl url)
{
    const QStringList filefilter = {"*.mp3", "*.wav", "*.m4a", "*.wma", "*.flac", "*.aac", "*.ape"};
    if (player.mediaStatus() == 0)
    {
        qDebug() << "start find!";
        QDir dir;
        dir.setPath(url.toString());
        QDirIterator file(dir.absolutePath(), filefilter, QDir::Files, QDirIterator::Subdirectories);
        while (file.hasNext())
        {
            file.next();
            QFileInfo info = file.fileInfo();
            if (info.isFile())
            {
                Filelist.append(info.absoluteFilePath());
                music_num++;
            }
        }
        player.setAudioOutput(&audioOutput);
        player.setSource(QUrl::fromLocalFile(Filelist.at(current_music_num)));
        player.play();
        connect(&player, &QMediaPlayer::mediaStatusChanged, this, &musicplayer::end_next);
        connect(&player, &QMediaPlayer::durationChanged, this, &musicplayer::get_metadata);
        connect(&player, &QMediaPlayer::positionChanged, this, &musicplayer::get_pos);
    }
    else
    {
        qDebug() << "change dir!";
        QDir dir;
        dir.setPath(url.toString());
        QDirIterator file(dir.absolutePath(), filefilter, QDir::Files, QDirIterator::Subdirectories);
        Filelist.clear();
        current_music_num = 0;
        music_num = 0;
        while (file.hasNext())
        {
            file.next();
            QFileInfo info = file.fileInfo();
            if (info.isFile())
            {
                Filelist.append(info.absoluteFilePath());
                music_num++;
            }
        }
        player.setSource(QUrl::fromLocalFile(Filelist.at(current_music_num)));
        player.play();
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
        current_music_num = shuffler.bounded(0, music_num);
    }
    if (player.playbackState() == 1)
    {
        player.setSource(QUrl::fromLocalFile(Filelist.at(current_music_num)));
        player.play();
    }
    else
    {
        player.setSource(QUrl::fromLocalFile(Filelist.at(current_music_num)));
    }
}

void musicplayer::end_next()
{
    if (player.mediaStatus() == 6&&loop==false)
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
            current_music_num = shuffler.bounded(0, music_num);
        }
        player.setSource(QUrl::fromLocalFile(Filelist.at(current_music_num)));
        player.play();
    }
}

void musicplayer::get_metadata()
{
    QMediaMetaData info = player.metaData();
    Musicinfo.Author = info.stringValue(info.Author);
    Musicinfo.Title = info.stringValue(info.Title);
    Musicinfo.AlbumTitle = info.stringValue(info.AlbumTitle);
    image = info.value(info.ThumbnailImage).value<QImage>();
    qDebug() << image;
    emit metadata_get();
}

void musicplayer::get_pos()
{
    Musicinfo.Pos = player.position();
    Musicinfo.Dur = player.duration();
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
    map.insert("Ablum", Musicinfo.AlbumTitle);
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
    switch(mode)
    {
    case 1: {shuffle =false;loop=true;player.setLoops(-1);qDebug() << "loop mode";break;}
    case 2: {shuffle = false;loop=false;player.setLoops(1);qDebug() << "order mode";break;}
    case 3: {shuffle = true;loop=false;player.setLoops(1);qDebug() << "shuffle mode";break;}
    }
}
