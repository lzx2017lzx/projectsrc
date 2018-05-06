#ifndef SOCKETCLIENT_H
#define SOCKETCLIENT_H
#include<sys/types.h>
#include<stdio.h>
#include <stdlib.h>
//#include <unistd.h>
#include <QDebug>
#include"writedata.h"
#include<iostream>

class socketclient
{
    Q_OBJECT
public:
    socketclient();
    SOCKET sclient;
    struct sockaddr_in serAddr;
    WRITEDATA writedata;
    WSADATA data;
    WORD sockVersion;
    ~socketclient();
};

#endif // SOCKETCLIENT_H
