#include "player.h"
QMediaPlayer player;
QAudioOutput audioOutput;
QStringList Filelist;
int music_num=0;
int current_music_num=0;
int value=0;
m_info Musicinfo;
QImage image;
ablumimage::ablumimage()
    : QQuickImageProvider(QQuickImageProvider::Image)
{

}

QImage ablumimage::requestImage(const QString &id, QSize *size, const QSize &requestedSize)
{
    return image;
}

void musicplayer::next()
{
    if(current_music_num<music_num)
    {
        current_music_num++;
        player.setSource(QUrl::fromLocalFile(Filelist.at(current_music_num)));
        player.play();
    }
}

void musicplayer::find()
{
    qDebug()<<"start find!";
    QDir dir;
    dir.setPath("*****DIR YOU WANT*****");
    QDirIterator file(dir,QDirIterator::Subdirectories);
    while (file.hasNext())
    {
    file.next();
    QFileInfo info=file.fileInfo();
    if (info.isFile())
    {
    Filelist.append(info.absoluteFilePath());
    music_num++;
    }
    }  
}

void musicplayer::start()
{
    player.setAudioOutput(&audioOutput);
    player.setSource(QUrl::fromLocalFile(Filelist.at(current_music_num)));
    player.play();
    connect(&player,&QMediaPlayer::mediaStatusChanged,this,&musicplayer::end_next);
    connect(&player,&QMediaPlayer::durationChanged,this,&musicplayer::get_metadata);
    connect(&player,&QMediaPlayer::positionChanged,this,&musicplayer::get_pos);
    qDebug()<<"start!";
}

void musicplayer::previous()
{
    if(current_music_num>0)
    {
        current_music_num--;
        player.setSource(QUrl::fromLocalFile(Filelist.at(current_music_num)));
        player.play();
    }
}

void musicplayer::end_next()
{
    if(player.mediaStatus()==6)
    {
        if(current_music_num<music_num)
        {
            current_music_num++;
            player.setSource(QUrl::fromLocalFile(Filelist.at(current_music_num)));
            player.play();
        }
    }
}

void musicplayer::get_metadata()
{
    QMediaMetaData info=player.metaData();
    Musicinfo.Author=info.stringValue(info.Author);
    Musicinfo.Title=info.stringValue(info.Title);
    Musicinfo.AlbumTitle=info.stringValue(info.AlbumTitle);
    image=info.value(info.ThumbnailImage).value<QImage>();
    qDebug()<<image;
    emit metadata_get();
}

void musicplayer::get_pos()
{
    Musicinfo.Pos=player.position();
    Musicinfo.Dur=player.duration();
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
    map.insert("Author",Musicinfo.Author);
    map.insert("Title",Musicinfo.Title);
    map.insert("Ablum",Musicinfo.AlbumTitle);
    return map;
}

QVariantMap musicplayer::give_pos(void)
{
   QVariantMap Map;
   Map.clear();
   Map.insert("pos",player.position());
   Map.insert("dur",player.duration());
   return Map;
}

void musicplayer::set_pos(qreal pos)
{
    player.setPosition(pos*player.duration());
}

