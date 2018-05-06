#include "mainwindow.h"

MainWindow::MainWindow(QWidget *parent)
    : QMainWindow(parent)
{

    // nwt=new netwidget();
    lrt=new loginregister();
    lrt->close();
    newwebwidget=new webwidget();
    newwebwidget->close();

    sct=new socketclient();
    //    threadwin=new Thread();
    //    threadwin->start();

    sytT=new synchronizationThread();
    sytT->start();
    //    this->installEventFilter(this);


    setCentralWidget(lrt);
    connect(lrt->button1, SIGNAL(clicked()),
            this, SLOT(clickslotslogin()));

    connect(lrt->button2, SIGNAL(clicked()),
            this, SLOT(clickslotsregister()));

    connect(sytT, SIGNAL(sendSynData()),
            this, SLOT(handleSynData()));

}

MainWindow::~MainWindow()
{
    delete nwt;
    delete lrt;
    delete sct;
    //    //停止线程
    //    threadwin->quit();

    //    //等待线程处理完手头工作
    //    threadwin->wait();
    //    delete threadwin;

    //停止线程
    sytT->quit();

    //等待线程处理完手头工作
    sytT->wait();
    delete sytT;

    for(list<ApplicationWidget*>::iterator it=vApW.begin();it!=vApW.end();it++)
    {
        if(*it!=NULL)
        {
            delete(*it);
            *it=NULL;
        }
    }
    delete newwebwidget;
}

void MainWindow::timerEvent(QTimerEvent *event)
{
#if 0
    if(event->timerId()==timerid1)
    {
        takeCentralWidget();
        setCentralWidget(nwt);
        qDebug()<<"1";
        //nwt->show();
        //lrt->close();
    }else if(event->timerId()==timerid2)
    {
        takeCentralWidget();
        setCentralWidget(lrt);
        qDebug()<<"2";
        //nwt->close();
        // lrt->show();
    }else if(event->timerId()==timerid3)
    {
        // qDebug()<<"3";
    }
#endif
}

void MainWindow:: clickslotslogin()
{

    qDebug()<<"clickslots works";

    QString username=lrt->edit1->text();
    QString password=lrt->edit2->text();

    char*recData=NULL;
    int ret=0;


    QJsonObject resp;
    resp.insert("indexcmd",QJsonValue(LOGINCMD));
    resp.insert("username", username);
    resp.insert("password", password);
    QByteArray buf = QJsonDocument(resp).toJson();
    socketfunc((char*)buf.data(),&recData,ret);

    qDebug()<<"username:"<<username;
    qDebug()<<"password:"<<password;
    if(ret>0)
    {
        printf("recData:%s\n",recData);
        QJsonDocument doc = QJsonDocument::fromJson(QByteArray(recData));
        const QJsonObject &obj=doc.object();
        short int ret = obj.value("return").toInt();

        if(ret==1)
        {
            qDebug()<<"login success";
            takeCentralWidget();
            lrt->close();
            // setCentralWidget(nwt);
            // nwt->show();
            this->setFixedHeight(300);
            this->setFixedWidth(500);
            userName=username.toStdString();
            createWebApplication(username,true);

        }else if(ret==-3)
        {
            qDebug()<<"password error";
        }else if(ret==-10)
        {
            qDebug()<<"server error";
        }else if(ret==-1000)
        {
            qDebug()<<"unknow error";
        }
        free(recData);
    }
}

void MainWindow:: clickslotsregister()
{

    qDebug()<<"clickslots works";

    QString username=lrt->edit1->text();
    QString password=lrt->edit2->text();

    char*recData=NULL;
    int ret=0;

    QJsonObject resp;
    resp.insert("indexcmd",QJsonValue(REGISTERCMD));
    resp.insert("username", username);
    resp.insert("password", password);
    QByteArray buf = QJsonDocument(resp).toJson();

    socketfunc((char*)buf.data(),&recData,ret);

    qDebug()<<"username:"<<username;
    qDebug()<<"password:"<<password;
    if(ret>0)
    {
        printf("recData:%s\n",recData);

        QJsonDocument doc = QJsonDocument::fromJson(QByteArray(recData));
        const QJsonObject &obj=doc.object();
        short int ret = obj.value("return").toInt();

        if(ret==2)
        {
            qDebug()<<"login success";
            takeCentralWidget();
            lrt->close();
            // setCentralWidget(nwt);
            // nwt->show();
            this->setFixedHeight(300);
            this->setFixedWidth(500);
            createWebApplication(username,true);
        }else if(ret==-100)
        {
            qDebug()<<"user exist";
        }else if(ret==-2)
        {
            qDebug()<<"register error";
        }else if(ret==-1000)
        {
            qDebug()<<"unknow error";
        }

        free(recData);
    }

}

void MainWindow::socketfunc(char *buf,char **recData,int &ret)
{
    sct->writedata.WriteBuf(sct->sclient,buf);

    *recData = sct->writedata.ReadBuf(sct->sclient,&ret);
    if(ret>0){
        recData[ret] = 0x00;
        cout<<"ret:"<<ret<<endl;
        printf("recData:%s\n",*recData);
    }

}

void MainWindow::createvApwInstance(QString strgraph,QString text,QString url)
{
    QString str(strgraph);

    ApplicationWidget *temp=new ApplicationWidget(this,str,text,url);
    temp->setGeometry(vApW.size()*90,0,80,100);
    temp->show();
    connect(temp, SIGNAL(sigClick(QString)),
            this, SLOT(showweb(QString)));
    //  temp->installEventFilter(this);
    vApW.push_back(temp);

}

void MainWindow::createWebApplication(QString username,bool isloginregister)
{
    char*recData=NULL;
    int ret=0;

    QJsonObject resp;
    resp.insert("indexcmd",QJsonValue(CREATEWEBAPPLICATIONCMD));
    resp.insert("username", username);
    //            resp.insert("password", password);
    QByteArray buf = QJsonDocument(resp).toJson();

    socketfunc((char*)buf.data(),&recData,ret);

    qDebug()<<"username:"<<username;
    if(ret>0)
    {
        printf("recData:%s\n",recData);

        QJsonDocument doc = QJsonDocument::fromJson(QByteArray(recData));
        const QJsonObject &obj=doc.object();
        short int ret = obj.value("return").toInt();

        qDebug()<<"retget url:"<<ret;


        if(ret==3)
        {
            //result_buf={"descrip":{"0":{"id":"1","img":"iVB","webname":"aweb","weburl":"www.baidu.com"}},"return":3};
            const QJsonObject &desobj=obj.value("descrip").toObject();
            int count=desobj.count();
            qDebug()<<"count:"<<count;
            for(int i=0;i<count;i++)
            {
                const QJsonObject &rowobj=desobj.value(QString::number(i,10)).toObject();
                QString img=rowobj.value("img").toString();
                QString name=rowobj.value("webname").toString();
                QString weburl=rowobj.value("weburl").toString();
                if((!isloginregister)&&checkcreatevApwInstance(name)<0)
                {
                    continue;
                }
                createvApwInstance(img,name,weburl);
            }
        }else if(ret==-100)
        {
            qDebug()<<"user exist";
        }else if(ret==-2)
        {
            qDebug()<<"register error";
        }else if(ret==-1000)
        {
            qDebug()<<"unknow error";
        }

        free(recData);
        recData=NULL;
    }
    free(recData);
}


void MainWindow::showweb(QString url)
{
    qDebug()<<"before showweb";
    newwebwidget->showweb(url);
    //  newwebwidget->show();
    qDebug()<<"after showweb";
}

bool MainWindow::eventFilter(QObject *watched, QEvent *event)
{
    if(watched==this)
    {
        // qDebug()<<"hello world";
        return true;
    }

    for(list<ApplicationWidget*>::iterator it=vApW.begin();it!=vApW.end();it++)
    {
        if(*it==watched)
        {

            if(event->type()==QEvent::MouseButtonPress)
            {
                emit (*it)->sigClick((*it)->url);
                return true;
            }
        }
    }

    if(watched==lrt)
    {
        return true;
    }
    return MainWindow::eventFilter(watched, event);
}

void MainWindow::handleSynData()
{
    qjoflag=false;
    qDebug()<<"it is hadleing synData";
    int count=qjo.count();
    qDebug()<<"count:"<<count;
    list<ApplicationWidget*>::iterator it=vApW.begin();
    int i=0;
    for(i=0;i<count;i++)
    {
        const QJsonObject &rowobj=qjo.value(QString::number(i,10)).toObject();
        QString img=rowobj.value("img").toString();
        QString name=rowobj.value("webname").toString();
        QString weburl=rowobj.value("weburl").toString();
        if(it==vApW.end())
        {
            break;
        }
        if((*it)->labeltext->text().compare(name)!=0)
        {
            delete(*it);
            vApW.erase(it);
            it=vApW.begin();
            i--;
        }else
        {

            if(it==vApW.end())
            {
                break;
            }
            it++;
        }

        //        if(checkcreatevApwInstance(name)<0)
        //        {
        //            continue;
        //        }
        //        createvApwInstance(img,name,weburl);
    }

    if(i<count)
    {
        for(int j=i;j<count;j++)
        {
            const QJsonObject &rowobj=qjo.value(QString::number(j,10)).toObject();
            QString img=rowobj.value("img").toString();
            QString name=rowobj.value("webname").toString();
            QString weburl=rowobj.value("weburl").toString();
            createvApwInstance(img,name,weburl);
        }
    }

    if(it!=vApW.end())
    {
        for(;it!=vApW.end();)
        {
            list<ApplicationWidget*>::iterator itor=it;
            it++;
            delete(*itor);
            vApW.erase(itor);
        }
    }


    while(1)
    {
        //send synsuccess flag
        QJsonObject resp;
        resp.insert("indexcmd",QJsonValue(RESPONSYN));
        resp.insert("username", QString::fromStdString(userName));
        //            resp.insert("password", password);
        int ret;
        QByteArray buf = QJsonDocument(resp).toJson();
        char*recData=NULL;

        socketfunc((char*)buf.data(),&recData,ret);

        cout<<"username:"<<userName;
        if(ret>0)
        {
            printf("recData:%s\n",recData);
            QJsonDocument doc = QJsonDocument::fromJson(QByteArray(recData));
            const QJsonObject &obj=doc.object();
            short int ret = obj.value("return").toInt();
            if(ret==9)
            {
                printf("responssyn:%s\n",recData);
                qjo=QJsonObject();
            }else if(ret==-1000||ret==-10)
            {
                continue;
            }
            break;
        }else if(ret<0)// rebuild connection
        {
            sct->connectserver();
        }
    }
    qjoflag=true;
}

int MainWindow::checkcreatevApwInstance(QString text)
{

    for(list<ApplicationWidget*>::iterator it=vApW.begin();it!=vApW.end();it++)
    {
        if(*it!=NULL)
        {
            if((*it)->labeltext->text().compare(text)==0)
            {
                return -1;
            }
        }
    }

    return 0;
}
