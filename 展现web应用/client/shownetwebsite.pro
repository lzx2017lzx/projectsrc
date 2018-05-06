#-------------------------------------------------
#
# Project created by QtCreator 2018-03-14T11:33:48
#
#-------------------------------------------------

QT       += core gui widgets quick network webenginewidgets

greaterThan(QT_MAJOR_VERSION, 4): QT += widgets network webenginewidgets

TARGET = shownetwebsite
TEMPLATE = app

# The following define makes your compiler emit warnings if you use
# any feature of Qt which as been marked as deprecated (the exact warnings
# depend on your compiler). Please consult the documentation of the
# deprecated API in order to know how to port your code away from it.
DEFINES += QT_DEPRECATED_WARNINGS

# You can also make your code fail to compile if you use deprecated APIs.
# In order to do so, uncomment the following line.
# You can also select to disable deprecated APIs only up to a certain version of Qt.
#DEFINES += QT_DISABLE_DEPRECATED_BEFORE=0x060000    # disables all the APIs deprecated before Qt 6.0.0


SOURCES += main.cpp\
        mainwindow.cpp \
    loginregister.cpp \
    netwidget.cpp \
    writedata.cpp \
    socketclient.cpp \
    jsonmesseage.cpp \
    applicationwidget.cpp \
    writedata.cpp \
    socketclient.cpp \
    webwidget.cpp \
    thread.cpp \
    synchronizationthread.cpp \
    common.cpp

HEADERS  += mainwindow.h \
    loginregister.h \
    netwidget.h \
    socketclient.h \
    jsonmesseage.h \
    applicationwidget.h \
    writedata.h \
    socketclient.h \
    webwidget.h \
    thread.h \
    const.h \
    common.h \
    synchronizationthread.h

RESOURCES += \
    img.qrc

win32{
LIBS += -lws2_32
}

DISTFILES += \
    shownetwebsite.rc

INCLUDEPATH+="C:\Program Files (x86)\Windows Kits\10\Include\10.0.10240.0\ucrt"
RC_FILE += shownetwebsite.rc
