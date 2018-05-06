#include<sys/types.h>
#include<sys/socket.h>
#include<netinet/in.h>
#include<string.h>
#include<sys/mman.h>
#include<sys/socket.h>
#include<sys/stat.h>
#include<fcntl.h>
#include<stdlib.h>
#include<stdio.h>
#include<unistd.h>
#include<signal.h>
#include<string.h>
#include<errno.h>
#include<sys/mman.h>
#include<utime.h>
#include<dirent.h>
#include<string>
#include<iostream>
#include<fstream>
#include"WRITEREADAVOIDPASTE.h"
#include"CheckDir.h"
#include<pthread.h>
#include"log.h"
using namespace std;

int acceptfd=0;
void *CheckDir(void *dirname)
{
    int ret= checkdir((char *)dirname,vectorfilename);     
}

void *FunAccept(void *accepttemp)
{
    while(1)
    {
//    acceptfd=0;
    int fd=(intptr_t)accepttemp;
    cout<<"fd in FunAccept:"<<fd<<endl;
    struct sockaddr saddr;
    socklen_t socklen=0;
    acceptfd=accept(fd,&saddr,&socklen);//创建服务器和客户端之间通信的文件
    printf("after accept\n");
    if(acceptfd<0)
    {
        printf("communication fails.\n");
        return NULL;
    }

    sockaddr_in sin;
    memcpy(&sin,&saddr, sizeof(sin));

    char bufip[512]={0};
    int port=0;
    //  取得ip和端口号 
    strcpy(bufip, inet_ntoa(sin.sin_addr));
    port  =  sin.sin_port;
    cout<<"ip is:"<<bufip<<endl;
    cout<<"port:"<<port<<endl;
    }
}

void*FunWrite(void*)
{

    char buf[4096]="hello";
    while(1)
    {
        sem_wait(&sem_id2);
        if(vectorfilename.size()!=0&&(acceptfd!=0))
        {
            for(auto &temp:vectorfilename)
            {
                struct stat buffile;
                char *filename =(char*)temp.c_str();
                if (stat(filename, &buffile) < 0) {
                    printf("Mesg: %s\n", strerror(errno));
                    continue;
                }
                uint32_t lenfilename=(uint32_t)temp.size();
                mywritelen(acceptfd,lenfilename);
                cout<<"lenfilename:"<<lenfilename<<endl;
                int writelen;
                try
                {
                    writelen=mywrite(acceptfd,filename,lenfilename);        
                }catch(exception &e)
                {
                    cout<<"e.what():"<<e.what()<<endl;
                }
                cout<<"writelen:"<<writelen<<endl;
                cout<<"accpetfd:"<<acceptfd<<endl;
                int lenfile=buffile.st_size;

                char *data=(char*)malloc(lenfile+1);
                data[lenfile]='\0';

                // char *buffromclient= myreadbuf(newfd);
                // printf("buffromclient:%s\n",buffromclient);

                fstream OpenFile;
                OpenFile.open(filename,ios::in|ios::binary);
                OpenFile.read(data,lenfile);
                OpenFile.close();
                cout<<"data:"<<data<<endl;

                mywritelen(acceptfd,lenfile);
                cout<<"lenfile:"<<lenfile<<endl;
                writelen=0;
                writelen=mywrite(acceptfd,data,lenfile);        
                cout<<"writelne:"<<writelen<<endl;
                sleep(3);
                int retunlink=remove(filename);
                cout<<"retunlink:"<<retunlink<<endl;
                if(retunlink!=0)
                {
                    cout<<"errno:"<<errno<<endl;
                }
                free(data);
                data=NULL;
            }
            vectorfilename.clear();
        }
        sem_post(&sem_id1);
    }

}

int main(int argc,char**argv)
{
    signal(SIGPIPE, SIG_IGN);
    if(argc<2)
    {
        cout<<"USAGE EXE SENDFILE"<<endl;
        return -1;
    }
    //创建套接字
    int fd=socket(AF_INET,SOCK_STREAM,0);
    pthread_t pdt;
    pthread_t pdtaccept;
    pthread_t pdtwrite;
    pthread_create(&pdt,NULL,CheckDir,argv[1]);
    //设置结诟体，用来绑定IP和端口
    struct sockaddr_in addr;
    addr.sin_addr.s_addr=inet_addr("0.0.0.0");
    addr.sin_family=AF_INET;
    addr.sin_port=htons(10099);    

    //绑定地址端口信息到socket文件
    bind(fd,(struct sockaddr*)&addr,sizeof(addr));
    sem_init(&sem_id1,0,1);
    sem_init(&sem_id2,0,0);

    //监听
    listen(fd,10);//同时监听10个客户端
    pthread_create(&pdtaccept,NULL,FunAccept,(void*)(intptr_t)fd);
    pthread_create(&pdtwrite,NULL,FunWrite,NULL);


    pthread_join(pdt,NULL);
    pthread_join(pdtaccept,NULL);
    pthread_join(pdtwrite,NULL);
    return 0;

}
