#ifndef MYAPPLICATION_JNIDEF_H
#define MYAPPLICATION_JNIDEF_H
#include<jni.h>
#include<android/log.h>
#include<stdio.h>
#include<stdlib.h>
#include<list>
#include<string>
#include<algorithm>
#include<functional>
using namespace std;
static const char* tag="JNITAG";


jstring c2j(JNIEnv* env, string cstr);
string j2c(JNIEnv* env, jstring jstr);//string此时是c++的容器，需要编写mk文件后才能使得jni支持c++的容器

#define MyError(fmt, ...) __android_log_print(ANDROID_LOG_ERROR,tag,fmt,##__VA_ARGS__)
#define MyWarn(fmt, ...) __android_log_print(ANDROID_LOG_WARN,tag,fmt,##__VA_ARGS__)



#endif
