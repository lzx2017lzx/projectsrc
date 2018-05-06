#include"jni_def.h"
#include "core.h"

#if 1
//方法二
jstring c2j(JNIEnv* env, string cstr)
{
    return env->NewStringUTF(cstr.c_str());
}
string j2c(JNIEnv* env, jstring jstr)//string此时是c++的容器，需要编写mk文件后才能使得jni支持c++的容器
{
    string ret;
    jclass stringClass = env->FindClass("java/lang/String");
    jmethodID getBytes = env->GetMethodID(stringClass, "getBytes", "(Ljava/lang/String;)[B");

    // 把参数用到的字符串转化成java的字符
    jstring arg = c2j(env, "utf-8");

    jbyteArray jbytes = (jbyteArray)env->CallObjectMethod(jstr, getBytes, arg);

    // 从jbytes中，提取UTF8格式的内容
    jsize byteLen = env->GetArrayLength(jbytes);
    jbyte* JBuffer = env->GetByteArrayElements(jbytes, JNI_FALSE);

    // 将内容拷贝到C++内存中
    if(byteLen > 0)
    {
        char* buf = (char*)JBuffer;
        std::copy(buf, buf+byteLen, back_inserter(ret));
    }

    // 释放
    env->ReleaseByteArrayElements(jbytes, JBuffer, 0);
    return ret;
}
#endif
extern "C"
 jboolean Java_com_daheiche_heiche_Jni_login(JNIEnv*env,jobject obj,jstring username,
 jstring password,jboolean isDriver,jdouble lat,jdouble lng)
{
    string cUser=j2c(env,username);
    string cPass=j2c(env,password);
    MyError("2");
    return Login(cUser,cPass,(bool)isDriver,(double)lat,(double)lng);

}
static JNIEnv* gEnv=NULL;
static jobject gObj=NULL;
//public native Boolean getNearbyDrivers(String username,double lat,double lng);
static void callback(string name,double lat,double lng)
//static void callback(string json_buf)
{
JNIEnv *env=gEnv;
jobject obj=gObj;
    jclass clazz=env->FindClass("com/daheiche/heiche/Jni");
  // jclass clazz=gEnv->GetObjectClass(gObj);
 // if(clazz==NULL)
  //  clazz = env->GetObjectClass(obj);
   //jmethodID method=gEnv->GetMethodID(clazz,"nearbyDrivers","(Ljava/lang/String;)V");
   jmethodID method=env->GetMethodID(clazz,"nearByDrivers","(Ljava/lang/String;DD)V");
   if(method)
   env->CallVoidMethod(obj,method,c2j(env,name),lat,lng);//根据method所指向的函数的返回值类型，如果是
   //void就必须使用CallVoidMethod
   else
    MyError("find methodID null");
    //jmethodID jmethodID=env->GetMethodID(clazz,"NearByDriver","(Ljava/lang/String;DD)V");
MyError("before CallVoidMethod\n");
//gEnv->CallVoidMethod(gObj,method,c2j(gEnv,json_buf));
MyError("during callback\n");

    MyError("find methodID null");
}
extern "C"
 jboolean Java_com_daheiche_heiche_Jni_getNearbyDrivers(JNIEnv*env,jobject obj,
 jstring username,jdouble lat,jdouble lng)
{
    if(gEnv==NULL)
    {
    gEnv=env;
        gObj=obj;
    }

     MyError("-----------------Java_com_daheiche_heiche_Jni_getNearbyDrivers--------------------------");
          MyError("-----------------Java_com_daheiche_heiche_Jni_getNearbyDrivers--------------------------");
           MyError("-----------------Java_com_daheiche_heiche_Jni_getNearbyDrivers--------------------------");
                MyError("-----------------Java_com_daheiche_heiche_Jni_getNearbyDrivers--------------------------");
    MyError("before jni.cpp GetNearbyDrivers\n");
    MyError("lat：%s\n",j2c(env,username).c_str());
    MyError("lat：%lf\n",(double)lat);
    MyError("lng：%lf\n",(double)lng);

    GetNearbyDrivers(j2c(env,username),lat,lng,callback);
        MyError("after jni.cpp GetNearbyDrivers\n");

       return (jboolean)true;
}


extern "C"
 jboolean Java_com_daheiche_heiche_Jni_reg(JNIEnv*env,jobject obj,
 jstring username,jstring password)
{
    string cUser=j2c(env,username);
    string cPass=j2c(env,password);
    return Reg(cUser,cPass);

}

extern "C"
jstring Java_com_daheiche_heiche_Jni_lastError(JNIEnv*env,jobject obj)
{
    return c2j(env,lastError);

}

