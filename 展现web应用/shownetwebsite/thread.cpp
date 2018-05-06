#include "thread.h"

Thread::Thread(QThread *parent) : QThread(parent)
{
    sct=new socketclient();
    resp.insert("indexcmd",QJsonValue(HEARTBEAT));
    resp.insert("username", QString::fromStdString(userName));

}

void Thread::run()
{
    //很复杂的数据处理
    //需要耗时5s
    while(1)
    {
        sleep(5);
        qDebug()<<"sleep thread";


        QByteArray buf = QJsonDocument(resp).toJson();
        char *recData=NULL;
        int ret;

        socketfunc((char*)buf.data(),&recData,ret);

        if(ret>0)
        {
            printf("recData:%s\n",recData);
            free(recData);
        }else if(ret<0)
        {
            free(recData);
            closesocket(sct->sclient);
            sct->connectserver();
        }
    }
}

Thread::~Thread()
{
    closesocket(sct->sclient);
    delete sct;
}


void Thread::socketfunc(char *buf,char **recData,int &ret)
{
    ret=sct->writedata.WriteBuf(sct->sclient,buf);
    if(ret<0)
    {
        return;
    }

    *recData = sct->writedata.ReadBuf(sct->sclient,&ret);
    if(ret>0){
        recData[ret] = 0x00;
        std::cout<<"ret:"<<ret<<std::endl;
        printf("recData:%s\n",*recData);
    }

}
