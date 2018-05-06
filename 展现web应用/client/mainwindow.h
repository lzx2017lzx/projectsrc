#ifndef MAINWINDOW_H
#define MAINWINDOW_H

#include <QMainWindow>
#include<string>
#include<cstring>
#include<cstdlib>
#include<cstdio>
#include<QJsonArray>
#include<QJsonDocument>
#include<QJsonObject>
#include<QJsonValue>
#include<vector>
#include<list>
#include"synchronizationthread.h"
#include"applicationwidget.h"
#include"loginregister.h"
#include"netwidget.h"
#include"socketclient.h"
#include"webwidget.h"
#include"common.h"
#include"thread.h"
using namespace std;
class MainWindow : public QMainWindow
{
    Q_OBJECT

public:
    MainWindow(QWidget *parent = 0);
    ~MainWindow();
    void timerEvent(QTimerEvent *event);
    loginregister *lrt;
    netwidget*nwt;
    socketclient*sct;
    Thread *threadwin;
    synchronizationThread*sytT;

    void socketfunc(char *buf,char **recData,int &ret);
    list<ApplicationWidget*>vApW;
    void createvApwInstance(QString strgraph,QString text,QString url);
    int checkcreatevApwInstance(QString text);
    void createWebApplication(QString username,bool isloginregister);
    webwidget *newwebwidget;
    bool eventFilter(QObject *watched, QEvent *event);

private:
    int timerid1;
    int timerid2;
    int timerid3;

public slots:
    void clickslotslogin();
    void clickslotsregister();
    void showweb(QString);
    void handleSynData();
};

#endif // MAINWINDOW_H
