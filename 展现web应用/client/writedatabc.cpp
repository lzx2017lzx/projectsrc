#include "writedata.h"

WRITEDATA::WRITEDATA()
{

}

int WRITEDATA::WriteLen(int fd,unsigned long len)
{
    len=htonl(len);
    return MyWrite(fd,(char*)&len,sizeof(len));
}

int WRITEDATA::WriteBuf(int fd,const char* buf)
{
    unsigned long len=strlen(buf);
    WriteLen(fd,len);
    return MyWrite(fd,(char*)buf,len);
}

int WRITEDATA::MyWrite(int fd,char buf[],int len)
{

    int writelen=0;
    while(writelen!=len)
    {
        int ret=send(fd,buf+writelen,len-writelen,0);
        if(ret>0)writelen+=ret;
        else if(ret<=0)
        {
            if(errno==EINTR)continue;
            break;
        }
    }
    return writelen;

}

int WRITEDATA::ReadLen(int fd,unsigned long *len)
{
    int ret=MyRead(fd,(char*)len,sizeof(unsigned long));
    *len=ntohl(*len);
    return ret;
}

char * WRITEDATA::ReadBuf(int fd,int *ret)
{
    //先读出长度
    unsigned long len;
    *ret=ReadLen(fd,&len);
    if(*ret<0)
    {
        return NULL;
    }
    char *buf=(char*)malloc(len+1);
    buf[len]=0;
    *ret=MyRead(fd,buf,len);
    if(*ret<0)
    {
        return NULL;
    }
    return buf;
}

int WRITEDATA::MyRead(int fd,char buf[],int len)
{
    int readlen=0;
    while(readlen!=len)
    {
        int ret=recv(fd,buf+readlen,len-readlen,0);
        if(ret>0)
        {
            readlen+=ret;
        }else if(ret<0)
        {
            if(errno==EINTR)
                continue;
            return ret;
        }else if(ret==0)
        {
            break;
        }

    }
    return readlen;
}

