#ifndef THREAD_H
#define THREAD_H

#include <QThread>
#include"socketclient.h"
#include<QJsonArray>
#include<QJsonDocument>
#include<QJsonObject>
#include<QJsonValue>
#include"common.h"
class Thread : public QThread
{
    Q_OBJECT
public:
    explicit Thread(QThread *parent = 0);
    ~Thread();
    void run();
    socketclient *sct;
    QJsonObject resp;
    void Thread::socketfunc(char *buf,char **recData,int &ret);
signals:
    void isDone();
public slots:
};

#endif // THREAD_H
