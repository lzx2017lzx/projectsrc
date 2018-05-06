#ifndef HANDLEMESSAGE_H
#define HANDLEMESSAGE_H
#include<iostream>
#include<string>
#include"mysqllib.h"
#include"const.h"
#include"json.h"
#define RETURN(word)    string strword(word);unsigned int lengthword=strword.length();\
                        char * chartemp=new char[lengthword+1];\
                        strcpy(chartemp,strword.c_str());\
                    *result_len=lengthword+1;\
                    return chartemp;

using namespace std;
namespace lizongxin
{
class HandleMessage 
{                                                                                                
    public:                                                                                          
        HandleMessage();                                                                            
        ~HandleMessage();                                                                           
        ///消息处理主循环                                                                            
        char* handle_message(char* input, size_t len, size_t* result_len, string ip);                

        Json json;
        char arr[1024];
        double d1;
        mysqllib*mysqltool;

};                                                                                               
}
#endif 
