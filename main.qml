import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects
import Player

Window {
    minimumWidth: 480
    maximumWidth: 480
    minimumHeight: 480
    maximumHeight: 480
    visible: true
    title: qsTr("音乐播放器")
    Rectangle {
        id: panel
        width: Window.width
        height: Window.width
        Layout.fillWidth: true
        Layout.fillHeight: true
        anchors.top: parent
        Image {
            id: img
            mipmap: true
            width: panel.width
            height: panel.height
            fillMode: Image.PreserveAspectCrop
            anchors.horizontalCenter: parent.horizontalCenter
            source: "image://ablum/" + Date.now()
        }
    }
    Rectangle {
        id: playbar
        width: Window.width
        height: Window.width / 2
        anchors.bottom: parent.bottom
        gradient: Gradient {
            GradientStop {
                position: 0.0
                color: "transparent"
            }
            GradientStop {
                position: 1.0
                color: "black"
            }
        }
        Slider {
            id: musicpos
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: controlbar.top
            anchors.bottomMargin: 5
            width: Window.width * 4 / 5
            to: 1.0
            onMoved:musicplayer.set_pos(musicpos.value);
            Label {
                id: time
                anchors.verticalCenter: parent.verticalCenter
                anchors.right: parent.left
                anchors.rightMargin: 5
                font.pixelSize: 12
                color:"white"
            }
            Label {
                id: durationtime
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: parent.right
                anchors.leftMargin: 5
                font.pixelSize: 12
                color:"white"
            }
        }
        RowLayout {
            id: info
            spacing: 8
            Layout.alignment: Qt.AlignHCenter
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: musicpos.top
            anchors.bottomMargin: 5
            Label {
                id: author
                font.pixelSize: 22
                color: "white"
                wrapMode: Label.WordWrap
            }
            Label {
                id: title
                font.pixelSize: 22
                color: "white"
                wrapMode: Label.WordWrap
            }
            Label {
                id: ablum
                font.pixelSize: 22
                color: "white"
                wrapMode: Label.WordWrap
            }
        }
        RowLayout {
            id: controlbar
            spacing: 8
            Layout.alignment: Qt.AlignHCenter
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 20
            Player {
                id: musicplayer
                onMetadata_get: {
                    var musicinfo = musicplayer.give_metadata()
                    author.text = musicinfo.Author
                    title.text = musicinfo.Title
                    ablum.text = musicinfo.Ablum
                    img.source = "image://ablum/" + Date.now()
                }
                onPos_get: {
                    var info = musicplayer.give_pos()
                    musicpos.value = info.pos / info.dur
                    var pos_m = Math.floor(info.pos / 60000)
                    var pos_ms = (info.pos / 1000 - pos_m * 60).toFixed(1)
                    var dur_m = Math.floor(info.dur / 60000)
                    var dur_ms = (info.dur / 1000 - dur_m * 60).toFixed(1)
                    time.text=(`${pos_m}:${pos_ms.padStart(4, 0)}`)
                    durationtime.text=(`${dur_m}:${dur_ms.padStart(4, 0)}`)
                }
            }
            RoundButton {
                id: prebutton
                icon.name: "pre"
                icon.source: "qrc:/icon/pre.png"
                icon.width: 32
                icon.height: 32
                onClicked: {
                    musicplayer.previous()
                    playbutton.icon.source = "qrc:/icon/pause.png"
                }
                onPressed: {
                    icon.source = "qrc:/icon/_pre.png"
                }
                onPressedChanged: {
                    icon.source = "qrc:/icon/pre.png"
                }
            }
            RoundButton {
                id: playbutton
                icon.name: "play"
                icon.source: "qrc:/icon/play.png"
                icon.width: 32
                icon.height: 32
                state: "STOP"
                states: [
                    State {
                        name: "PLAYING"
                        PropertyChanges {
                            target: playbutton
                            onClicked: {
                                musicplayer.pause()
                                icon.source = "qrc:/icon/play.png"
                                playbutton.state = "PAUSE"
                            }
                            onPressed: {
                                icon.source = "qrc:/icon/_play.png"
                            }
                            onPressedChanged: {
                                icon.source = "qrc:/icon/play.png"
                            }
                        }
                    },
                    State {
                        name: "PAUSE"
                        PropertyChanges {
                            target: playbutton
                            onClicked: {
                                musicplayer.play()
                                icon.source = "qrc:/icon/pause.png"
                                playbutton.state = "PLAYING"
                            }
                            onPressed: {
                                icon.source = "qrc:/icon/_pause.png"
                            }
                            onPressedChanged: {
                                icon.source = "qrc:/icon/pause.png"
                            }
                        }
                    },
                    State {
                        name: "STOP"
                        PropertyChanges {
                            target: playbutton
                            onClicked: {
                                musicplayer.find()
                                musicplayer.start()
                                icon.source = "qrc:/icon/pause.png"
                                playbutton.state = "PLAYING"
                            }
                        }
                    }
                ]
            }
            RoundButton {
                id: nextbutton
                icon.name: "next"
                icon.source: "qrc:/icon/next.png"
                icon.width: 32
                icon.height: 32
                onClicked: {
                    musicplayer.next()
                    playbutton.icon.source = "qrc:/icon/pause.png"
                }
                onPressed: {
                    icon.source = "qrc:/icon/_next.png"
                }
                onPressedChanged: {
                    icon.source = "qrc:/icon/next.png"
                }
            }
        }
    }
}
