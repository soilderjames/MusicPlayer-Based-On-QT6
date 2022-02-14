QT += quick
QT += quickcontrols2
QT += multimedia
QT += widgets
QT += core
QT += sql
SOURCES += \
        main.cpp \
        player.cpp \

resources.files = main.qml 
resources.prefix = /$${TARGET}
RESOURCES += resources \
    UI.qrc

# Additional import path used to resolve QML modules in Qt Creator's code model
QML_IMPORT_PATH =

# Additional import path used to resolve QML modules just for Qt Quick Designer
QML_DESIGNER_IMPORT_PATH =

# Default rules for deployment.
qnx: target.path = /tmp/$${TARGET}/bin
else: unix:!android: target.path = /opt/$${TARGET}/bin
!isEmpty(target.path): INSTALLS += target

HEADERS += \
    player.h \

win32:CONFIG(release, debug|release): LIBS += -L$$PWD/taglib/ -ltag
else:win32:CONFIG(debug, debug|release): LIBS += -L$$PWD/taglib/ -ltag
else:unix: LIBS += -L$$PWD/taglib/ -ltag

unix|win32: LIBS += -L$$PWD/zlib/ -llibzlib.dll

INCLUDEPATH += $$PWD/taglib/taglib
INCLUDEPATH += $$PWD/taglib/taglib/ape
INCLUDEPATH += $$PWD/taglib/taglib/asf
INCLUDEPATH += $$PWD/taglib/taglib/flac
INCLUDEPATH += $$PWD/taglib/taglib/it
INCLUDEPATH += $$PWD/taglib/taglib/mod
INCLUDEPATH += $$PWD/taglib/taglib/mp4
INCLUDEPATH += $$PWD/taglib/taglib/mpc
INCLUDEPATH += $$PWD/taglib/taglib/mpeg
INCLUDEPATH += $$PWD/taglib/taglib/ogg
INCLUDEPATH += $$PWD/taglib/taglib/riff
INCLUDEPATH += $$PWD/taglib/taglib/s3m
INCLUDEPATH += $$PWD/taglib/taglib/toolkit
INCLUDEPATH += $$PWD/taglib/taglib/trueaudio
INCLUDEPATH += $$PWD/taglib/taglib/xm
INCLUDEPATH += $$PWD/taglib/taglib/wavpack
DEPENDPATH += $$PWD/taglib/taglib
DEPENDPATH += $$PWD/taglib/taglib/
DEPENDPATH += $$PWD/taglib/taglib/ape
DEPENDPATH += $$PWD/taglib/taglib/asf
DEPENDPATH += $$PWD/taglib/taglib/flac
DEPENDPATH += $$PWD/taglib/taglib/it
DEPENDPATH += $$PWD/taglib/taglib/mod
DEPENDPATH += $$PWD/taglib/taglib/mp4
DEPENDPATH += $$PWD/taglib/taglib/mpc
DEPENDPATH += $$PWD/taglib/taglib/mpeg
DEPENDPATH += $$PWD/taglib/taglib/ogg
DEPENDPATH += $$PWD/taglib/taglib/riff
DEPENDPATH += $$PWD/taglib/taglib/s3m
DEPENDPATH += $$PWD/taglib/taglib/toolkit
DEPENDPATH += $$PWD/taglib/taglib/trueaudio
DEPENDPATH += $$PWD/taglib/taglib/xm
DEPENDPATH += $$PWD/taglib/taglib/wavpack


