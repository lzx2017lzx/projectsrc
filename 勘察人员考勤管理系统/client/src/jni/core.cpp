#include<iostream>

using namespace std;
#include "core.h"
#include "cJSON.h"
#include"json.h"
#include"curl.h"


#include"WRITEREADAVOIDPASTE.h"
#include<arpa/inet.h>
#include<sys/types.h>
#include<sys/socket.h>
#include<netinet/in.h>
//#include<string.h>
#include<stdio.h>
#include<stdlib.h>
//#include<errno.h>
#include<string.h>
#include<sys/stat.h>
#include<fcntl.h>
#include<errno.h>
//#include<sys/epoll.h>
//#include<list>
//#include<map>
#include<arpa/inet.h>
//#include<pthread.h>
#include<unistd.h>

static const char * url="http://120.77.214.169:10099";

string lastError;

static int getGeohash(double lat,double lng)
{
    uint32_t lngLatBits = 0;

        double lngMin = -180;
        double lngMax = 180;
        double latMin = -90;
        double latMax = 90;


        for(int i=0; i<15; ++i)
        {
         lngLatBits <<=1;
                    double latMid = (latMax + latMin)/2;
                    if(lat > latMid)
                    {
                        lngLatBits += 1;
                        latMin = latMid;
                    }
                    else
                    {
                        latMax = latMid;
                    }
            lngLatBits<<=1;

            double lngMid = (lngMax + lngMin)/2;
            if(lng > lngMid)
            {
                lngLatBits += 1;
                lngMin = lngMid;
            }
            else
            {
                lngMax = lngMid;
            }


        }

        return lngLatBits;
}


#if 0
size_t write_callback(char*ptr,size_t size,size_t nmemb,void *userdata)
{
    string & str=*(string *)userdata;

    int len=size*nmemb;
    copy(ptr,ptr+len,back_inserter(str));

    return len;
}
#endif

bool GetNearbyDrivers(string username,double lat,double lng,void(*callback)(string,double,double))
{

                Json root;
                root.add("username",username);
                root.add("cmd","nearbyDriver");
                root.add("lat",lat);
                root.add("lng",lng);
                int geohash=getGeohash(lat,lng);
                root.add("geohash",geohash);

                MyError("login in core is working\n");
//建立socket文件
    int cl=socket(AF_INET,SOCK_STREAM,0);

    //建立绑定套接字的地址
    struct sockaddr_in addr;
    addr.sin_family=AF_INET;
    addr.sin_addr.s_addr=inet_addr("120.77.214.169");
    addr.sin_port=htons(10099);


    //连接socket文件和套接字
    if(connect(cl,(struct sockaddr*)&addr,sizeof(addr)))
    {
        MyError("connect fail");
        return false;
    }


MyError("connect success");
        // perror("connect:");

        char temp[4096]={0};
        strcpy(temp,root.print());
         mywritebuf(cl,temp);
         memset(temp,0,sizeof(temp));

        char *chartemp=myreadbuf(cl);

         MyError("myreadbuf return =%s",chartemp);
         Json resp;
            resp.parse(chartemp);

                 string result=resp.getString("response");
                    if(result=="ok")
                     {
                     //callback(curl.resp_buf);
                     #if 1
                     MyError("GetNearbyDrivers  ok");
                     cJSON*drivers=resp.getObject("drivers");
                       MyError("respgetobject:%s\n",cJSON_Print(drivers));
                     int drivercount=cJSON_GetArraySize(drivers);
                       MyError("drivercount:%d",drivercount);
                     for(int i=0;i<drivercount;i++)
                     {
                    cJSON*driver= cJSON_GetArrayItem(drivers,i);
                     const char*driverName=cJSON_GetObjectItem(driver,"name")->valuestring;
                     double lat=cJSON_GetObjectItem(driver,"lat")->valuedouble;
                     double lng=cJSON_GetObjectItem(driver,"lng")->valuedouble;
          MyError("dirverName:%s,lat:%lf,lng:%lf",driverName,lat,lng);
                         callback(driverName,lat,lng);
                     }
         #endif
                      free(chartemp);
                             close(cl);
                                 return true;
                     }


         free(chartemp);
         close(cl);
             return false;

#if 0
    Json req;
    req.add("cmd","nearbyDriver");
    req.add("username",username);
    req.add("lat",lat);
    req.add("lng",lng);
    int geohash=getGeohash(lat,lng);
    req.add("geohash",geohash);


   // Log.e(Jni.tag,"-----------------insetLocationListener-------------------");
   MyError("-----------------core.cppGetNearbyDrivers--------------------------");
      MyError("-----------------core.cppGetNearbyDrivers--------------------------");
       MyError("-----------------core.cppGetNearbyDrivers--------------------------");
            MyError("-----------------core.cppGetNearbyDrivers--------------------------");
    MyError("core.cpp GetNearbyDrivers lat %lf  lng:%lf\n",lat,lng);
    Curl curl;
    CURLcode ret=curl.post(url,req.print());

 if(ret!=CURLE_OK)
   {
            MyError("GetNearbyDrivers curl error return =%d",(int)ret);
             lastError="GetNearbyDrivers network error";
             return false;
   }

   Json resp;
   resp.parse(curl.resp_buf);

        string result=resp.getString("result");
           if(result=="ok")
            {
            //callback(curl.resp_buf);
            #if 1
            MyError("GetNearbyDrivers  ok");
            cJSON*drivers=resp.getObject("drivers");
            int drivercount=cJSON_GetArraySize(drivers);
            for(int i=0;i<drivercount;i++)
            {
           cJSON*driver= cJSON_GetArrayItem(drivers,i);
            const char*driverName=cJSON_GetObjectItem(driver,"name")->valuestring;
            double lat=cJSON_GetObjectItem(driver,"lat")->valuedouble;
            double lng=cJSON_GetObjectItem(driver,"lng")->valuedouble;

                callback(driverName,lat,lng);
            }
#endif
            return true;
            }
  lastError=resp.getString("reason");
            MyError("GetNearbyDrivers error:%s",lastError.c_str());
            return false;


#endif
}




bool Reg(string username,string password)
{
//        cJSON*root=cJSON_CreateObject();
//        cJSON_AddStringToObject(root,"username",username.c_str());
//        cJSON_AddStringToObject(root,"password",password.c_str());
//        cJSON_AddStringToObject(root,"cmd","register");

//        char *buf=cJSON_Print(root);
//        cJSON_Delete(root);

 Json root;
        root.add("username",username);
        root.add("password",password);
        root.add("cmd","register");
    //建立socket文件
    int cl=socket(AF_INET,SOCK_STREAM,0);

    //建立绑定套接字的地址
    struct sockaddr_in addr;
    addr.sin_family=AF_INET;
    addr.sin_addr.s_addr=inet_addr("120.77.214.169");
    addr.sin_port=htons(10099);


    //连接socket文件和套接字
    if(connect(cl,(struct sockaddr*)&addr,sizeof(addr)))
    {
        perror("connect");
        return false;
    }
         perror("connect:");

        char temp[4096]={0};
        strcpy(temp,root.print());
         mywritebuf(cl,temp);
         memset(temp,0,sizeof(temp));

        char *chartemp=myreadbuf(cl);

         MyError("myreadbuf return =%s",chartemp);
         cJSON* roottemp=cJSON_Parse(chartemp);
             if(roottemp==NULL)
             MyError("cJSON Parse wrong.\n");

          cJSON *obj=cJSON_GetObjectItem(roottemp,"response");
             if(!strcmp(obj->valuestring,"register success"))
             {
                 MyError("register ok");
                 free(chartemp);
                          close(cl);
                           return  true;
             }else
             {
             MyError("register fail:%s\n",obj->valuestring);
             free(chartemp);
                      close(cl);
                      return false;
             }

#if 0
        Json root;
        root.add("username",username);
        root.add("password",password);
        root.add("cmd","register");

       // uint32_t len=strlen(root.print());
       // len=htonl(len);

            Curl curl;
           CURLcode ret= curl.post(url,root.print());
           //CURLcode ret= curl.post(url,(char*)&len);
//            if(ret!=CURLE_OK)
//            {
//MyError("curl error return =%d",(int)ret);
//          lastError="network error";
//           return false;
//
//            }

            ret= curl.post(url,root.print());
            if(ret!=CURLE_OK)
                        {
            MyError("curl error return =%d",(int)ret);
                      lastError="network error";
                       return false;

                        }
            //curl.resp_buf;
            Json resp;
            resp.parse(curl.resp_buf);
            string result=resp.getString("result");
            if(result=="ok")
            {
            MyError("register ok");
            return true;
            }

            lastError=resp.getString("reason");
            MyError("register error:%s",lastError.c_str());
            return false;

//CURL*curl=curl_easy_init();
//        curl_easy_setopt(curl,CURLOPT_URL,"http://119.29.97.137:10099");
//        curl_easy_setopt(curl,CURLOPT_POSTFIELDS,root.print());
//
//        string str;
//        curl_easy_setopt(curl,CURLOPT_WRITEFUNCTION,write_callback);
//        curl_easy_setopt(curl,CURLOPT_WRITEDATA,&str);
//
//
//        CURLcode ret=curl_easy_perform(curl);
//        free(buf);
//
//        if(ret!=CURLE_OK)
//        {
//            MyError("curl error return =%d",(int)ret);
//           lastError="network error";
//            return false;
//        }
//
//          MyError("curl perform ok");
//        {
//            cJSON*root=cJSON_Parse(str.c_str());
//            cJSON*result=cJSON_GetObjectItem(root,"result");
//            if(result&&strcmp(result->valuestring,"ok")==0)
//            {
//
//                cJSON_Delete(root);
//                MyError("register ok");
//                return true;
//            }
//            else
//            {
//                cJSON*reason=cJSON_GetObjectItem(root,"reason");
//                MyError("error is:%s",reason->valuestring);
//                lastError=reason->valuestring;
//            }
//
//            cJSON_Delete(root);
//
//        }


       // free(buf);
       // return true;


#endif

}


bool Login(string username,string password,bool isDriver,
    double lat,double lng)
{

 MyError("-----------------Login--------------------------");
 MyError("-----------------Login--------------------------");
 MyError("-----------------Login--------------------------");
 MyError("-----------------Login--------------------------");
//        cJSON*root=cJSON_CreateObject();
//        cJSON_AddStringToObject(root,"username",username.c_str());
//        cJSON_AddStringToObject(root,"password",password.c_str());
//        cJSON_AddStringToObject(root,"cmd","register");

//        char *buf=cJSON_Print(root);
//        cJSON_Delete(root);
Json root;


                root.add("username",username);
                root.add("password",password);
                root.add("type",isDriver?"d":"p");
                root.add("cmd","login");
                root.add("lat",lat);
                root.add("lng",lng);
                int geohash=getGeohash(lat,lng);
                root.add("geohash",geohash);

                MyError("login in core is working\n");
//建立socket文件
    int cl=socket(AF_INET,SOCK_STREAM,0);

    //建立绑定套接字的地址
    struct sockaddr_in addr;
    addr.sin_family=AF_INET;
    addr.sin_addr.s_addr=inet_addr("120.77.214.169");
    addr.sin_port=htons(10099);


    //连接socket文件和套接字
    if(connect(cl,(struct sockaddr*)&addr,sizeof(addr)))
    {
        MyError("connect failur");
        return false;
    }
     MyError("connect success");
        // perror("connect:");

        char temp[4096]={0};
        strcpy(temp,root.print());
         mywritebuf(cl,temp);
         memset(temp,0,sizeof(temp));

        char *chartemp=myreadbuf(cl);

         MyError("myreadbuf return =%s",chartemp);
         cJSON* roottemp=cJSON_Parse(chartemp);
             if(roottemp==NULL)
             MyError("cJSON Parse wrong.\n");

          cJSON *obj=cJSON_GetObjectItem(roottemp,"response");

             if(!strcmp(obj->valuestring,"login success"))
             {
                 MyError("login ok");
                 free(chartemp);
                 close(cl);
                 return true;
             }else
             {
             MyError("login fail:%s\n",obj->valuestring);

         free(chartemp);
         close(cl);
             return false;
             }
     return 0;
#if 0
        Json root;
        root.add("username",username);
        root.add("password",password);
        root.add("type",isDriver?"d":"p");
        root.add("cmd","login");
        root.add("lat",lat);
        root.add("lng",lng);
        int geohash=getGeohash(lat,lng);
        root.add("geohash",geohash);

        MyError("login in core is working\n");
            Curl curl;
           CURLcode ret= curl.post(url,root.print());
            if(ret!=CURLE_OK)
            {
MyError("curl error return =%d",(int)ret);
          lastError="network error";
//          for(int i=0;i<100;i++)
//          {
//          ret= curl.post(url,root.print());
//           MyError("curl error return =%d",(int)ret);
//
//          }

           return false;

            }

            //curl.resp_buf;
            Json resp;
            resp.parse(curl.resp_buf);
            string result=resp.getString("result");
            if(result=="ok")
            {
            MyError("Login ok");
            return true;
            }

            lastError=resp.getString("reason");
            MyError("Login error:%s",lastError.c_str());
            return false;
#endif
//CURL*curl=curl_easy_init();
//        curl_easy_setopt(curl,CURLOPT_URL,"http://119.29.97.137:10099");
//        curl_easy_setopt(curl,CURLOPT_POSTFIELDS,root.print());
//
//        string str;
//        curl_easy_setopt(curl,CURLOPT_WRITEFUNCTION,write_callback);
//        curl_easy_setopt(curl,CURLOPT_WRITEDATA,&str);
//
//
//        CURLcode ret=curl_easy_perform(curl);
//        free(buf);
//
//        if(ret!=CURLE_OK)
//        {
//            MyError("curl error return =%d",(int)ret);
//           lastError="network error";
//            return false;
//        }
//
//          MyError("curl perform ok");
//        {
//            cJSON*root=cJSON_Parse(str.c_str());
//            cJSON*result=cJSON_GetObjectItem(root,"result");
//            if(result&&strcmp(result->valuestring,"ok")==0)
//            {
//
//                cJSON_Delete(root);
//                MyError("register ok");
//                return true;
//            }
//            else
//            {
//                cJSON*reason=cJSON_GetObjectItem(root,"reason");
//                MyError("error is:%s",reason->valuestring);
//                lastError=reason->valuestring;
//            }
//
//            cJSON_Delete(root);
//
//        }


       // free(buf);
       // return true;




}
#if 0
bool Login(string username,string password)
{
    cJSON*root=cJSON_CreateObject();
    cJSON_AddStringToObject(root,"username",username.c_str());
    cJSON_AddStringToObject(root,"password",password.c_str());
    cJSON_AddStringToObject(root,"cmd","login");

    char *buf=cJSON_Print(root);
    cJSON_Delete(root);

    CURL*curl=curl_easy_init();
    curl_easy_setopt(curl,CURLOPT_URL,"http://120.77.214.169:10099");
    curl_easy_setopt(curl,CURLOPT_POSTFIELDS,buf);

    string str;
    curl_easy_setopt(curl,CURLOPT_WRITEFUNCTION,write_callback);
    curl_easy_setopt(curl,CURLOPT_WRITEDATA,&str);


    CURLcode ret=curl_easy_perform(curl);
    if(ret!=CURLE_OK)
    {
        MyError("curl error return =%d",(int)ret);
       lastError="network error";
        return false;
    }

      MyError("curl perform ok");
    {
        cJSON*root=cJSON_Parse(str.c_str());
        cJSON*result=cJSON_GetObjectItem(root,"result");
        if(result&&strcmp(result->valuestring,"ok")==0)
        {

            cJSON_Delete(root);
            MyError("login ok");
            return true;
        }
        else
        {
            cJSON*reason=cJSON_GetObjectItem(root,"reason");
            MyError("error is:%s",reason->valuestring);
            lastError=reason->valuestring;
        }

        cJSON_Delete(root);

    }


   // free(buf);
    return true;
}
#endif
