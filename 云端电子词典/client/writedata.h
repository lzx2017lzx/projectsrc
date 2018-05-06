#ifndef WRITEDATA_H
#define WRITEDATA_H
//#include<QtWebSockets/QtWebSockets>
//#include <QMainWindow>
//#include <QTcpSocket>
#include <winsock2.h>
#include<qDebug>
//#include<errno.h>
//#include<unistd.h>

class WRITEDATA
{

public:
    WRITEDATA();
    int WriteLen(int fd,unsigned long len);
    int WriteBuf(int fd,const char* buf);
    int MyWrite(int fd,char buf[],int len);

    int ReadLen(int fd,unsigned long *len);
    char * ReadBuf(int fd,int *ret);
    int MyRead(int fd,char buf[],int len);
};

#endif // WRITEDATA_H
