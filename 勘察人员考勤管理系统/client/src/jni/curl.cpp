#include "curl.h"

Curl::Curl()
{
    curl=curl_easy_init();
//    resp_buf=NULL;
//    resp_len=0;
}

Curl::~Curl()
{
    curl_easy_cleanup(curl);
}

CURLcode Curl::get(string url)
{

setopt(url);

    return curl_easy_perform(curl);
}

CURLcode Curl::post(string url, char *data, int len)
{

    setopt(url);
   curl_easy_setopt(curl,CURLOPT_POSTFIELDS,data);
   if(len!=0)
    curl_easy_setopt(curl,CURLOPT_POSTFIELDSIZE,len);

    return curl_easy_perform(curl);
}

size_t Curl:: callback1(char*ptr,size_t size,size_t nmemb,void *userdata)
{
    Curl*This=(Curl*)userdata;
   return This->callback(ptr,size,nmemb);

}
size_t Curl::callback(char*ptr,size_t size,size_t nmemb)
{
    copy(ptr,ptr+size*nmemb,back_inserter(resp_buf));
    return size*nmemb;
}
void Curl::setopt(const string& url)
{
resp_buf.clear();
 curl_easy_setopt(curl,CURLOPT_URL,url.c_str());
    curl_easy_setopt(curl,CURLOPT_WRITEFUNCTION,Curl::callback1);
   curl_easy_setopt(curl,CURLOPT_WRITEDATA,this);

}

