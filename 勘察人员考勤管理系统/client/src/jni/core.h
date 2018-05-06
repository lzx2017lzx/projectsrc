#ifndef MYAPPLICATION3_CORE_H
#define MYAPPLICATION3_CORE_H
#include"jni_def.h"

extern string lastError;



bool Login(string username,string password,bool isDriver,double lat,double lng);
bool Reg(string username,string password);
bool GetNearbyDrivers(string username,
                double lat,
                double lng,
                void(*callback)(string,double,double));


#endif
