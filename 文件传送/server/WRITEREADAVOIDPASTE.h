#include<sys/types.h>
#include<sys/socket.h>
#include<netinet/in.h>
#include<string.h>
#include<stdio.h>
#include<stdlib.h>
#include<errno.h>
#include<string.h>
#include<sys/stat.h>
#include<fcntl.h>
#include<errno.h>
#include<sys/epoll.h>
#include<list>
#include<map>
#include<arpa/inet.h>
#include<pthread.h>
#include<unistd.h>
#include"common.h"
#ifdef __cplusplus
extern "C"
{
#endif

int mywrite(int fd,char buf[],int len);
int mywritelen(int fd,uint32_t len);
void mywritebuf(int fd,char buf[]);
//读报文
int myread(int fd,char buf[],int len);
int myreadlen(int fd,uint32_t *len);
char * myreadbuf(int fd);

#ifdef __cplusplus
}
#endif
