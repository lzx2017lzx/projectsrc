#include "consts.h"


int MAXTHREADS = 4;
string HOST_ADDRESS = "0.0.0.0:3000";
int HOST_PORT = 3000;

//http 通讯端口
int HTTPPORT = 3005;
//http 处理线程
int HTTPTHREADS = 4;

int DB_MAXCONNECTION = 256;
string DB_SERVER = "localhost";
string DB_DATANAME = "shoveeims3";
string DB_USER = "eims3";
string DB_PASSWORD = "iloveeims3";
int DB_PORT = 3306;
int DB_MAX_IDLE_TIME = 0;
int DB_CONNECTTIMEOUT = 10;
int DB_READTIMEOUT = 5;
int DB_WRITETIMEOUT = 20;

#ifdef OS_WINDOWS
string DEBUG_FILE = "D:\\Debug.txt";
#else
string DEBUG_FILE = "/var/log/eims3server.log";
#endif
int LOGPRINT = 1;
int LOGSUBSCRIBE = 1;
int SUBSCRIBEPORT = 3333;
int LOGWRITELEVEL = 6;

//int INTERVAL_GET_DATA_COUNT = 5;
//int INTERVAL_GET_USER_MSG = 40;
//int INTERVAL_GET_NOTIFY = 10;
//int INTERVAL_GET_APPLICATIONS_NOTIFY = 15;
//int INTERVAL_GET_ALL_SITES = 20;
//int INTERVAL_GET_ALL_SITES_USINT = 25;
//int INTERVAL_GET_APPLICATIONS = 35;
//int INTERVAL_GET_CONTROL_TYPES = 1200;
//int INTERVAL_GET_NOTIFY_TYPES = 1300;
//int INTERVAL_GET_CONTROLS = 30;
//int INTERVAL_GET_TRADE_TYPES = 3000;
//int INTERVAL_GET_PROVINCES = 4000;
//int INTERVAL_GET_CITYS = 6000;
//int INTERVAL_GET_AREAS = 9000;
//int INTERVAL_UPDATE_GET_USINGS = 5000;
//
//string XINIUYUNRESURL = "http://test-site.xiniuyun.com/resources";

//Logic Script
string SCRIPT_FOLDER_PATH = "";
string SCRIPT_ENTRANCE_FILE = "";
string SCRIPT_ENTRANCE_FUNC = "";
