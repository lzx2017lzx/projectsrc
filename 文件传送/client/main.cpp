#include <iostream>
#include"socketclient.h"
#include<fstream>
#include<string>
#include<windows.h>
using namespace std;

const string dirstorage="F:/filefromaliyun/";//remember / and end with /";

int main(int argc, char *argv[])
{
    socketclient sc;
    string filenamestr;
    while(1)
    {
        cout<<"1"<<endl;
        char *filename=NULL;
        char *filedata=NULL;
        int ret=0;

        filename=sc.writedata.ReadBuf(sc.sclient,&ret);
        if(ret<0)
        {
            sc.connectserver();
            continue;
        }
        cout<<"ret:"<<ret<<endl;
        filenamestr=string(filename);
        printf("filename:%s\n",filename);
        auto pos=filenamestr.find_last_of("/");
        if(pos==string::npos)
        {
            break;
        }
        filenamestr=filenamestr.substr(pos+1,filenamestr.size());
        filedata=sc.writedata.ReadBuf(sc.sclient,&ret);
        if(ret<0)
        {
            sc.connectserver();
            continue;
        }

        printf("filedata:%s\n",filedata);
        filenamestr=dirstorage+filenamestr;
        printf("filenamestr:%s\n",filenamestr.c_str());
        cout<<"ret:"<<ret<<endl;
        fstream OpenFile;
        OpenFile.open(filenamestr.c_str(),ios::out | ios::trunc|ios::binary);
        OpenFile<<string(filedata,ret);
        OpenFile.close();
        cout << "Hello World!" << endl;
        free(filename);
        free(filedata);
        filename=NULL;
        filedata=NULL;
        Sleep(1);
    }
    return 0;
}
