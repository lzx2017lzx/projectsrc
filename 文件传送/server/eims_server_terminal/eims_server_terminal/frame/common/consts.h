#ifndef EIMS_CONSTS_H
#define EIMS_CONSTS_H

#include <string>

//#define OS_WINDOWS
#define OS_LINUX

#ifdef OS_WINDOWS
typedef long long bigint;
typedef unsigned long long ubigint;
#else
typedef long bigint;
typedef unsigned long ubigint;
#endif

using namespace std;

//Core System
extern int MAXTHREADS;
extern string HOST_ADDRESS;
extern int HOST_PORT;

//http 通讯端口
extern int HTTPPORT;
//http 处理线程
extern int HTTPTHREADS;

extern int DB_MAXCONNECTION;
extern string DB_SERVER;
extern string DB_DATANAME;
extern string DB_USER;
extern string DB_PASSWORD;
extern int DB_PORT;
extern int DB_MAX_IDLE_TIME;
extern int DB_CONNECTTIMEOUT;
extern int DB_READTIMEOUT;
extern int DB_WRITETIMEOUT;

extern string DEBUG_FILE;
//日志打印开关
extern int LOGPRINT;
//日志订阅功能开关
extern int LOGSUBSCRIBE;
//日志订阅端口
extern int SUBSCRIBEPORT;
//日志记录等级
extern int LOGWRITELEVEL;


//Logic Business
//extern int INTERVAL_GET_DATA_COUNT;
//extern int INTERVAL_GET_USER_MSG;
//extern int INTERVAL_GET_NOTIFY;
//extern int INTERVAL_GET_APPLICATIONS_NOTIFY;
//extern int INTERVAL_GET_ALL_SITES;
//extern int INTERVAL_GET_ALL_SITES_USINT;
//extern int INTERVAL_GET_APPLICATIONS;
//extern int INTERVAL_GET_CONTROL_TYPES;
//extern int INTERVAL_GET_NOTIFY_TYPES;
//extern int INTERVAL_GET_CONTROLS;
//extern int INTERVAL_GET_TRADE_TYPES;
//extern int INTERVAL_GET_PROVINCES;
//extern int INTERVAL_GET_CITYS;
//extern int INTERVAL_GET_AREAS;
//extern int INTERVAL_UPDATE_GET_USINGS;
//extern string XINIUYUNRESURL;

//Logic Script
extern string SCRIPT_FOLDER_PATH;
extern string SCRIPT_ENTRANCE_FILE;
extern string SCRIPT_ENTRANCE_FUNC;

#endif // EIMS_CONSTS_H
