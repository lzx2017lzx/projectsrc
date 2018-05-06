#include "socketclient.h"

socketclient::socketclient()
{
    connectserver();
}

socketclient::~socketclient()
{
    closesocket(sclient);
    WSACleanup();
}

void socketclient::connectserver()
{
    sockVersion = MAKEWORD(2, 2);
    if(WSAStartup(sockVersion, &data)!=0)
    {
        return;
    }

    sclient = socket(AF_INET, SOCK_STREAM, IPPROTO_TCP);
    if(sclient == INVALID_SOCKET)
    {
        printf("invalid socket!");
        return;
    }
    unsigned long ul=1;
    int ret;
    ret=ioctlsocket(sclient,FIONBIO,(unsigned long *)&ul);//

    serAddr.sin_family = AF_INET;
    serAddr.sin_port = htons(10099);
    serAddr.sin_addr.S_un.S_addr = inet_addr("120.77.214.169");

    if(connect(sclient, (sockaddr *)&serAddr, sizeof(serAddr)) == SOCKET_ERROR)
    {  //连接失败
       // printf("connect error !");
        perror("connect fail");

        closesocket(sclient);
        return;
    }
}
