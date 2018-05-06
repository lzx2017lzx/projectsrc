#ifndef COMMON_H_INCLUDED
#define COMMON_H_INCLUDED

#include <sys/time.h>
#include <boost/unordered_map.hpp>

//#include <configure_file.h>
#include "../../frame/security/shove/configure_file.h"
#include "../xml/xml_oper.h"
#include "../lua/lua_oper.h"
//#include "../db/sql_connect.h"
#include "../db/mysql_cnt.h"

#include "global.h"
#include "tools.h"
#include "meta.h"
#include "consts.h"

#define LOG
#define LUALOADONCE
//#define _DEBUG

using namespace std;
using namespace eims::lua;
using namespace boost;
using namespace eims::meta;
using namespace eims::db;
using namespace eims::debug;
using namespace eims::global;

typedef unordered_map<unsigned long int, xml_oper*> XMLOPERS;
typedef unordered_map<unsigned long int, lua_oper*> LUAOPERS;
typedef unordered_map<unsigned long int, eims::db::mysql_cnt*> SQLOPERS;
typedef unordered_map<unsigned long int, shove::security::ses*> SESOPRES;

namespace eims
{
	namespace common
	{
		///XML解析指针集合，有几个线程就就会有几个XML_Oper
		static XMLOPERS g_xml_parsers;
		///MYSQL数据库指针集合，有几个线程就有几个MYSQL指针
		static SQLOPERS g_db_opers;
		///SES加密解密指针
		static SESOPRES g_ses_opers;

		///公有类
		class Common
		{
			static pthread_mutex_t sql_locker;
			static pthread_mutex_t xml_locker;
			static pthread_mutex_t lua_locker;
			static pthread_mutex_t ses_locker;
			static unsigned short cur_sql_count;
			static unsigned short cur_xml_count;
			static unsigned short cur_ses_count;
			static unsigned short cur_lua_count;
		public:

			/// ///////////////////////////////
			///	获取或创建一个LUA虚拟机
			///	当指定ID的虚拟机不存在时，则创建一个
			/// ///////////////////////////////
			static lua_oper* lua_vm_grab(unsigned long int id);

			/// ///////////////////////////////
			///	释放及删除一个虚拟机
			/// ///////////////////////////////
			static void lua_vm_release(unsigned long int id);

			/// ///////////////////////////////
			///	虚拟机保存的MAP数据结构
			/// ///////////////////////////////
			static LUAOPERS luavms;

		public:
			Common()
			{
				pthread_mutex_init(&sql_locker, NULL);
				pthread_mutex_init(&xml_locker, NULL);
				pthread_mutex_init(&lua_locker, NULL);
				pthread_mutex_init(&ses_locker, NULL);
			}
			~Common();

			///加载配置项
			static void loadconfig();

			///申请XML操作指针
			static xml_oper* xml_parser_grab(unsigned long int id);

			///申请MYSQL操作指针
			//static SqlConnect* sql_oper_grab(unsigned long int id);
			static mysql_cnt* sql_oper_grab(unsigned long int id);

			///ses加密指针获取
			static shove::security::ses* ses_oper_grab(unsigned long int id);

			///删除所有对象指针
			static void delete_all();
		};
	}
}
#endif // COMMON_H_INCLUDED
