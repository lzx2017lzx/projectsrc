#include "socketclient.h"

socketclient::socketclient()
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

    serAddr.sin_family = AF_INET;
    serAddr.sin_port = htons(10099);
    serAddr.sin_addr.S_un.S_addr = inet_addr("120.77.214.169");

    if(connect(sclient, (sockaddr *)&serAddr, sizeof(serAddr)) == SOCKET_ERROR)
    {  //¡¨Ω” ß∞‹
        printf("connect error !");
        closesocket(sclient);
        return;
    }
}

socketclient::~socketclient()
{
    closesocket(sclient);
    WSACleanup();
}
