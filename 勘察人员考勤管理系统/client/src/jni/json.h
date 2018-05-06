#ifndef JSON_H
#define JSON_H
#include"jni_def.h"
#include"cJSON.h"
class Json
{
public:
    Json();
    ~Json();

    void add(string key,string value);
    void add(string key,double value);
    void add(string key,int value);
    char* print();
    void parse(string json_buf);

    string getString(string key);
     cJSON * getObject(string key);
  //  int getInt(string key);
private:
    Json(const Json&);
    Json& operator=(const Json &);
    cJSON* root;
    char *buf;
};

#endif // JSON_H
