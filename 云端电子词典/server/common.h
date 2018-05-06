#ifndef COMMON_H_INCLUDED
#define COMMON_H_INCLUDED

#include <sys/time.h>
#include <map>

#include "configure_file.h"
//#include "../db/sql_connect.h"
//#include "mysql_cnt.h"

//#include "global.h"
#include "consts.h"
#include"log.h"
#include"convert.h"

//#define _DEBUG

using namespace std;

//typedef unordered_map<unsigned long int, lizongxin::db::mysql_cnt*> SQLOPERS;
namespace lizongxin
{
    namespace common
    {
        ///MYSQL数据库指针集合，有几个线程就有几个MYSQL指针
        //		static SQLOPERS g_db_opers;

        ///公有类
        class Common
        {
            static pthread_mutex_t sql_locker;
            static unsigned short cur_sql_count;

            public:
            Common()
            {
                pthread_mutex_init(&sql_locker, NULL);
            }
            ~Common();

            ///加载配置项
            static void loadconfig();


            ///申请MYSQL操作指针
            //static SqlConnect* sql_oper_grab(unsigned long int id);
            //			static mysql_cnt* sql_oper_grab(unsigned long int id);

            ///删除所有对象指针
//            static void delete_all();
        };
    }
}
#endif // COMMON_H_INCLUDED
