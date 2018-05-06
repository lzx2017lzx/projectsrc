#ifndef SYNCHRONIZATIONTHREAD_H
#define SYNCHRONIZATIONTHREAD_H

#include <QThread>
#include<QDebug>
#include"socketclient.h"
#include<QJsonArray>
#include<QJsonDocument>
#include<QJsonObject>
#include<QJsonValue>
#include"common.h"
class synchronizationThread : public QThread
{
    Q_OBJECT
public:
    explicit synchronizationThread(QThread *parent = 0);
    ~synchronizationThread();
    void run();
    socketclient *sct;

    void socketfunc(char *buf,char **recData,int &ret);
signals:
    void sendSynData();
public slots:
};

#endif // SYNCHRONIZATIONTHREAD_H
