import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects
import QtQuick.Dialogs
import Player

Window {
    id:win
    minimumWidth: 480
    maximumWidth: 480
    minimumHeight: 480
    maximumHeight: 480
    visible: true
    title: qsTr("音乐播放器")
    flags: Qt.Window | Qt.FramelessWindowHint
    FolderDialog {
        id: folderDialog
        title: "选择音乐文件夹"
        onAccepted: {
            var path = folderDialog.selectedFolder.toString()
            path = path.replace(/^(file:\/{3})|(qrc:\/{2})|(http:\/{2})/, "")
            musicplayer.appdata_store(path, true)
            musicplayer.start()
            playbutton.icon.source = "qrc:/icon/pause.png"
            playbutton.state = "PLAYING"
        }
    }
    Rectangle {
        id: panel
        width: Window.width
        height: Window.width
        Layout.fillWidth: true
        Layout.fillHeight: true
        anchors.top: parent.top
        Image {
            id: img
            mipmap: true
            width: panel.width
            height: panel.height
            fillMode: Image.PreserveAspectCrop
            anchors.horizontalCenter: parent.horizontalCenter
            source: "image://ablum/" + Date.now()
            Rectangle {
                id: titlebar
                width: Window.width
                height: Window.width / 4
                anchors.top: parent.top
                gradient: Gradient {
                    GradientStop {
                        position: 1.0
                        color: "transparent"
                    }
                    GradientStop {
                        position: 0.0
                        color: "black"
                    }
                }
                RoundButton {
                    id: minbutton
                    icon.width: 12
                    icon.height: 12
                    icon.source: "qrc:/icon/min.png"
                    anchors.right: closebutton.left
                    background: Rectangle {
                        visible: false
                    }
                    MouseArea {
                        hoverEnabled: true
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            win.visibility = Window.Minimized
                        }
                    }
                }
                RoundButton {
                    id: closebutton
                    icon.width: 12
                    icon.height: 12
                    anchors.right: parent.right
                    icon.source: "qrc:/icon/close.png"
                    background: Rectangle {
                        visible: false
                    }
                    MouseArea {
                        hoverEnabled: true
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            Qt.quit()
                        }
                    }
                }
            }
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
            onMoved: musicplayer.set_pos(musicpos.value)
            MouseArea {
                hoverEnabled: true
                anchors.fill: parent
                onEntered: {
                    poshandle.visible = true
                }
                onExited: {
                    poshandle.visible = false
                }
            }
            handle: Rectangle {
                id: poshandle
                visible: false
                x: musicpos.leftPadding + musicpos.visualPosition
                   * (musicpos.availableWidth - width)
                y: musicpos.topPadding + musicpos.availableHeight / 2 - height / 2
                implicitWidth: 14
                implicitHeight: 14
                radius: 8
                color: musicpos.pressed ? "#f0f0f0" : "#f6f6f6"
                border.color: "#bdbebf"
            }
            Label {
                id: time
                anchors.verticalCenter: parent.verticalCenter
                anchors.right: parent.left
                anchors.rightMargin: 5
                font.pixelSize: 12
                color: "white"
            }
            Label {
                id: durationtime
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: parent.right
                anchors.leftMargin: 5
                font.pixelSize: 12
                color: "white"
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
                    time.text = (`${pos_m}:${pos_ms.padStart(4, 0)}`)
                    durationtime.text = (`${dur_m}:${dur_ms.padStart(4, 0)}`)
                }
                onNo_playlist: {
                    folderDialog.open()
                }
            }
            RoundButton {
                id: playmode
                icon.source: "qrc:/icon/order.png"
                icon.width: 32
                icon.height: 32
                background: Rectangle {
                    visible: false
                }
                MouseArea {
                    id: playmode_mousearea
                    hoverEnabled: true
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                }
                state: "order"
                states: [
                    State {
                        name: "shuffle"
                        PropertyChanges {
                            target: playmode_mousearea
                            onClicked: {
                                playmode.icon.source = "qrc:/icon/order.png"
                                musicplayer.play_mode(2)
                                playmode.state = "order"
                            }
                        }
                    },
                    State {
                        name: "order"
                        PropertyChanges {
                            target: playmode_mousearea
                            onClicked: {
                                playmode.icon.source = "qrc:/icon/repeat.png"
                                musicplayer.play_mode(1)
                                playmode.state = "repeat"
                            }
                        }
                    },
                    State {
                        name: "repeat"
                        PropertyChanges {
                            target: playmode_mousearea
                            onClicked: {
                                playmode.icon.source = "qrc:/icon/shuffle.png"
                                musicplayer.play_mode(3)
                                playmode.state = "shuffle"
                            }
                        }
                    }
                ]
            }
            RoundButton {
                id: prebutton
                icon.name: "pre"
                icon.source: "qrc:/icon/pre.png"
                icon.width: 32
                icon.height: 32
                background: Rectangle {
                    visible: false
                }
                MouseArea {
                    hoverEnabled: true
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onEntered: {
                        prebutton.icon.source = "qrc:/icon/_pre.png"
                    }
                    onExited: {
                        prebutton.icon.source = "qrc:/icon/pre.png"
                    }
                    onClicked: {
                        if (playbutton.state !== "NOMEDIA") {
                            musicplayer.previous()
                        }
                    }
                }
            }
            RoundButton {
                id: playbutton
                icon.name: "play"
                icon.source: "qrc:/icon/play.png"
                icon.width: 32
                icon.height: 32
                background: Rectangle {
                    visible: false
                }
                MouseArea {
                    id: playbutton_mousearea
                    hoverEnabled: true
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                }
                state: "NOMEDIA"
                states: [
                    State {
                        name: "PLAYING"
                        PropertyChanges {
                            target: playbutton_mousearea
                            onEntered: {
                                playbutton.icon.source = "qrc:/icon/_pause.png"
                            }
                            onExited: {
                                playbutton.icon.source = "qrc:/icon/pause.png"
                            }
                            onClicked: {
                                musicplayer.pause()
                                playbutton.icon.source = "qrc:/icon/play.png"
                                playbutton.state = "PAUSE"
                            }
                        }
                    },
                    State {
                        name: "PAUSE"
                        PropertyChanges {
                            target: playbutton_mousearea
                            onEntered: {
                                playbutton.icon.source = "qrc:/icon/_play.png"
                            }
                            onExited: {
                                playbutton.icon.source = "qrc:/icon/play.png"
                            }
                            onClicked: {
                                musicplayer.play()
                                playbutton.icon.source = "qrc:/icon/pause.png"
                                playbutton.state = "PLAYING"
                            }
                        }
                    },
                    State {
                        name: "NOMEDIA"
                        PropertyChanges {
                            target: playbutton_mousearea
                            onEntered: {
                                playbutton.icon.source = "qrc:/icon/_play.png"
                            }
                            onExited: {
                                playbutton.icon.source = "qrc:/icon/play.png"
                            }
                            onClicked: {
                                musicplayer.start()
                                playbutton.icon.source = "qrc:/icon/pause.png"
                                playbutton.state = "PLAYING"
                            }
                        }
                    }
                ]
            }
            RoundButton {
                id: nextbutton
                icon.name: "next"
                icon.width: 32
                icon.height: 32
                icon.source: "qrc:/icon/next.png"
                background: Rectangle {
                    visible: false
                }
                MouseArea {
                    hoverEnabled: true
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onEntered: {
                        nextbutton.icon.source = "qrc:/icon/_next.png"
                    }
                    onExited: {
                        nextbutton.icon.source = "qrc:/icon/next.png"
                    }
                    onClicked: {
                        if (playbutton.state !== "NOMEDIA") {
                            musicplayer.next()
                        }
                    }
                }
            }
            RoundButton {
                id: filechoosebutton
                icon.width: 32
                icon.height: 32
                icon.source: "qrc:/icon/musicfile.png"
                background: Rectangle {
                    visible: false
                }
                MouseArea {
                    hoverEnabled: true
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        folderDialog.open()
                    }
                }
            }
        }
    }
}
