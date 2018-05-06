#ifndef CURL_H
#define CURL_H
#include"jni_def.h"
#include"curl/curl.h"
class Curl
{
public:
    Curl();
    ~Curl();
    CURLcode get(string url);
    CURLcode post(string url,char* data,int len=0);

    string resp_buf;
   // int resp_len;



//    {
//        string & str=*(string *)userdata;
//
//        int len=size*nmemb;
//        copy(ptr,ptr+len,back_inserter(str));
//
//        return len;
//    }
private:
static size_t callback1(char*ptr,size_t size,size_t nmemb,void *userdata);
    size_t callback(char*ptr,size_t size,size_t nmemb);

void setopt(const string& url);
    Curl(const Curl&);
    Curl& operator=(const Curl &);
    CURL * curl;
};

#endif // CURL_H
