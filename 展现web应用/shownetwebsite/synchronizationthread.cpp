#include "synchronizationthread.h"

synchronizationThread::synchronizationThread(QThread *parent) : QThread(parent)
{
    sct=new socketclient();

}

void synchronizationThread::run()
{
    //很复杂的数据处理
    //需要耗时5s
    while(1)
    {
        sleep(5);

        QJsonObject testsynresp;
        QJsonObject synresp;
        testsynresp.insert("indexcmd",QJsonValue(TESTSYTCMD));
        testsynresp.insert("username", QString::fromStdString(userName));

        synresp.insert("indexcmd",QJsonValue(SYTCMD));
        synresp.insert("username", QString::fromStdString(userName));
        qDebug()<<"sleep thread"<<"username"<<QString::fromStdString(userName);

        if(qjoflag)
        {
            if(userName.size()!=0)
            {
                QByteArray buf = QJsonDocument(testsynresp).toJson();
                char *recData=NULL;
                int ret;

                socketfunc((char*)buf.data(),&recData,ret);

                if(ret>0)
                {
                    printf("recData:%s\n",recData);

                    QJsonDocument doc = QJsonDocument::fromJson(QByteArray(recData));
                    const QJsonObject &obj=doc.object();
                    short int ret = obj.value("return").toInt();
                    if(ret==TESTSYNRESPSUC)
                    {
                        const QJsonObject &rowobj=obj.value("descrip").toObject();
                        const QJsonObject &finobj=rowobj.value("0").toObject();
                        //   qDebug()<<"finobj.tostring()"<<finobj.take("state").toString();
                        QString stateint=finobj.value("state").toString();
                        //                    qDebug()<<"rowobj.count(),finobj.count()"<<rowobj.count()<<finobj.count()<<"stateint:"<<stateint;
                        //                    qDebug()<<"name:"<<finobj.value("username").toString();
                        //                    qDebug()<<"state:"<<finobj.value("state").toString();
                        if(stateint.compare("1")==0)
                        {

                            QByteArray buf = QJsonDocument(synresp).toJson();
                            char *recData=NULL;
                            int ret;

                            socketfunc((char*)buf.data(),&recData,ret);
                            if(ret>0)
                            {
                                printf("recData:%s\n",recData);

                                QJsonDocument doc = QJsonDocument::fromJson(QByteArray(recData));
                                const QJsonObject &obj=doc.object();
                                short int ret = obj.value("return").toInt();
                                qjo=obj.value("descrip").toObject();
                                if(ret==8)
                                {
                                    qDebug()<<"before emit";
                                    // qjo=desobj;
                                    if(qjoflag)
                                    emit sendSynData();
                                }
                            }
                        }
                    }


                    free(recData);
                }else if(ret<0)
                {
                    free(recData);
                    closesocket(sct->sclient);
                    sct->connectserver();
                }
            }
        }
    }
}

synchronizationThread::~synchronizationThread()
{
    closesocket(sct->sclient);
    delete sct;
}


void synchronizationThread::socketfunc(char *buf,char **recData,int &ret)
{
    ret=sct->writedata.WriteBuf(sct->sclient,buf);
    if(ret<0)
    {
        return;
    }

    *recData = sct->writedata.ReadBuf(sct->sclient,&ret);
    if(ret>0&&(*recData!=NULL)){
        std::cout<<"ret:"<<ret<<std::endl;
        printf("recData:%s\n",*recData);
    }

}
