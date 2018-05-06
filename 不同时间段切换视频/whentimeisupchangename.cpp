#include <iostream>
#include<vector>
#include<string>
#include<stdio.h>
#include<unistd.h>
#include<sys/types.h>
#include<sys/mman.h>
#include<sys/socket.h>
#include<sys/stat.h>
#include<fcntl.h>
#include<stdio.h>
#include<stdlib.h>
#include<stdio.h>
#include<unistd.h>
#include<string.h>
#include<errno.h>
#include<sys/mman.h>
#include<utime.h>
#include<dirent.h>
#include"make_log.h"
using namespace std;

char filename[1024];

void getsrcname(string srcname)
{
    filename[0]=0; 
    DIR *dir=opendir(srcname.c_str());//如果是文件不是目录，是否要考虑判断dir是不是NULL
    if(dir==NULL)
        return;
    struct dirent * pdir=readdir(dir);
    while(1)
    {

        if(pdir==NULL)
        {   
            break;
        }
        if(pdir->d_type==DT_REG)
        {
            strcat(filename,pdir->d_name);
            printf("filename:%s\n",filename);
        }
        pdir=readdir(dir);
    }
    closedir(dir);
}

int IsInitiateState()
{
    if(strstr(filename,"e0281.mp4")&&strstr(filename,"e082b.mp4bc"))
    {
        return 1;
    }else if(strstr(filename,"e0281.mp4")&&strstr(filename,"e0281.mp4bc"))
    {
        return 2;
    }
    return 3;
}
int main(int argc, char *argv[])
{
    time_t t;
    t=time(NULL);
    struct tm *lt;  
    int ii = time(&t);  
    lt=localtime(&t);
//    cout<<"hour:"<<lt->tm_hour<<endl;
//    cout<<"minute:"<<lt->tm_min<<endl;
//    cout<<"sec:"<<lt->tm_sec<<endl;
    int sec=lt->tm_sec;
    int min=lt->tm_min;
    int hour=lt->tm_hour;
// bool flag1=false;
  //  bool flag2=true;
    int statedir;
    char *arr=(char*)malloc(10);
   
#if 1
    while(1)
    {
        t=time(NULL);
        ii=time(&t);
        lt=localtime(&t);
        sec=lt->tm_sec;
        min=lt->tm_min;
        hour=lt->tm_hour;
        cout<<"hour:"<<hour<<endl;       
        arr[0]=0;
        sprintf(arr,"%d",hour);
       // printf("%s",arr);
        LOG("whentimeisupchangename","whentimeisupchangename","hour:%s",arr);
//        cout<<"sec:"<<sec<<endl;       
        getsrcname("/var/www/html/lmth");
        statedir=IsInitiateState();
       // cout<<"statedir:"<<statedir<<endl;
        printf("statedir:%d\n",statedir);
        if(((hour>22 && hour<24)||(hour>0&&hour<6)) && statedir==1)
        {
            FILE *ptr=popen("mv /var/www/html/lmth/e0281.mp4 /var/www/html/lmth/e0281.mp4bc && mv /var/www/html/lmth/e082b.mp4bc /var/www/html/lmth/e0281.mp4","w");
            fclose(ptr);
           // cout<<"sec:"<<sec<<endl;
            printf("hour > 22 and hour < 24 statedir:%d\n",statedir);
        }
        else if((hour>6&&hour<22) && statedir==2)
        {
            FILE *ptr=popen("mv /var/www/html/lmth/e0281.mp4 /var/www/html/lmth/e082b.mp4bc && mv /var/www/html/lmth/e0281.mp4bc /var/www/html/lmth/e0281.mp4","w");
            fclose(ptr);
            cout<<"sec:"<<sec<<endl;
            printf("statedir:%d\n",statedir);
        }


#if 0
        if(hour>23&&hour<24&&flag2==true)
        {
            FILE *ptr=popen("mv /var/www/html/lmth/37305.mp4 /var/www/html/lmth/37306.mp4 && mv /var/www/html/lmth/37305.mp4bc /var/www/html/lmth/37305.mp4","w");
            fclose(ptr);
            cout<<"ii%120"<<endl;
            flag1=true;
            flag2=false;
        }else if(flag1==true)
        {
            FILE *ptr=popen("mv /var/www/html/lmth/37305.mp4 /var/www/html/lmth/37305.mp4bc && mv /var/www/html/lmth/37306.mp4 /var/www/html/lmth/37305.mp4","w");
            fclose(ptr);
            cout<<"ii%180"<<endl;
            flag1=false;
            flag2=true;
        }
#endif
        sleep(1);
    }
#endif
    //while(1)
    //{
    //   popen("touch gettimestampabc","w");
    //       popen("chmod 0777 gettimestampabc","w");

    //}
    //printf("t:%d\n",t);
    //    cout<<"t:"<<t<<endl;
#if 0
    t=time(NULL);
    lt=localtime(&t);
    char nowtime[24]={0};
    strftime(nowtime,24,"%Y-%m-%d %H:%M:%S", lt);
    cout<<"ii:"<<ii<<endl;
    cout<<"nowtime:"<<nowtime<<endl;
#endif

    return 0;
}
