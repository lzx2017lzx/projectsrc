#include "common.h"
namespace lizongxin
{
    namespace common
    {

        pthread_mutex_t Common::sql_locker;
        unsigned short Common::cur_sql_count = 0;


        //SqlConnect* Common::sql_oper_grab(unsigned long int id)

        Common::~Common()
        {
            //delete_all();
            pthread_mutex_unlock(&sql_locker);
        }


        void Common::loadconfig()
        {
            // 装载系统相关的配置项
            configure_file ini("lizongxin_server_terminal_system.ini");
            MAXTHREADS = ini.read_int("MAXTHREADS");
            HOST_ADDRESS = ini.read_string("HOST_ADDRESS");
            HOST_PORT = ini.read_int("HOST_PORT");
            LOG("common.cpp","loadconfig","%d",HOST_PORT);
            HTTPPORT = ini.read_int("HTTPPORT");
            HTTPTHREADS = ini.read_int("HTTPTHREADS");

            DB_MAXCONNECTION = ini.read_int("DB_MAXCONNECTION");
            DB_SERVER = ini.read_string("DB_SERVER");
            DB_DATANAME = ini.read_string("DB_DATANAME");
            DB_PORT = ini.read_int("DB_PORT");
            DB_MAX_IDLE_TIME = ini.read_int("DB_MAX_IDLE_TIME");
            DB_CONNECTTIMEOUT = ini.read_int("DB_CONNECTTIMEOUT");
            DB_READTIMEOUT = ini.read_int("DB_READTIMEOUT");
            DB_WRITETIMEOUT = ini.read_int("DB_WRITETIMEOUT");

            DEBUG_FILE = ini.read_string("DEBUG_FILE");
            LOGWRITELEVEL = ini.read_int("LOGWRITELEVEL");
            if(LOGWRITELEVEL < 0) LOGWRITELEVEL = 4;

            LOGPRINT = ini.read_int("LOGPRINT");

            LOGSUBSCRIBE = ini.read_int("LOGSUBSCRIBE");
            if(LOGSUBSCRIBE < 0) LOGSUBSCRIBE = 4;

        }
    }
}
