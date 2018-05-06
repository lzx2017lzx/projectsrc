#include "json.h"

Json::Json()
{
    root=cJSON_CreateObject();
    buf=NULL;
}

Json::~Json()
{
    cJSON_Delete(root);
    if(buf) free(buf);
}

void Json::add(string key, string value)
{
    cJSON_AddStringToObject(root,key.c_str(),value.c_str());
}
void Json::add(string key,double value)
{
    cJSON_AddNumberToObject(root,key.c_str(),value);
}

void Json::add(string key,int value)
{
    cJSON_AddNumberToObject(root,key.c_str(),value);
}


char* Json::print()
{
    if(buf!=NULL)free(buf);

    buf=cJSON_Print(root);
    return buf;
}

void Json::parse(string json_buf)
{
    cJSON* obj=cJSON_Parse(json_buf.c_str());
    if(obj==NULL)return;

    cJSON_Delete(root);
    root=obj;
}

string Json::getString(string key)
{
   cJSON*obj= cJSON_GetObjectItem(root,key.c_str());
    return obj->valuestring;
}

cJSON*Json::getObject(string key)
{
    cJSON *obj=cJSON_GetObjectItem(root,key.c_str());
    return obj;
}
