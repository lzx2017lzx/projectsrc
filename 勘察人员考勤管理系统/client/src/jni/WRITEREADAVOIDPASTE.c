#include"WRITEREADAVOIDPASTE.h"

int mywrite(int fd,char buf[],int len)
{
    int writelen=0;
    while(writelen!=len)
    {
        int ret=write(fd,buf+writelen,len-writelen);
        if(ret>0)writelen+=ret;
        else if(ret<=0)
        {
            if(errno==EINTR)continue;
            break;
        }
    }
    return writelen;
}


int mywritelen(int fd,uint32_t len)
{
    len=htonl(len);
    return mywrite(fd,(char*)&len,sizeof(len));
}

void mywritebuf(int fd,char *buf)
{
    uint32_t len=strlen(buf);
    mywritelen(fd,len);
    mywrite(fd,(char*)buf,len);
}

//读报文
int myread(int fd,char buf[],int len)
{
    int readlen=0;
    while(readlen!=len)
    {
        int ret=read(fd,buf+readlen,len-readlen);
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

int myreadlen(int fd,uint32_t *len)
{
    int ret=myread(fd,(char*)len,sizeof(uint32_t));
    *len=ntohl(*len);
    return ret;
}
char * myreadbuf(int fd)
{
    //先读出长度
    uint32_t len;
    myreadlen(fd,&len);

    char *buf=(char*)malloc(len+1);
    buf[len]=0;
    myread(fd,buf,len);
    return buf;
}
