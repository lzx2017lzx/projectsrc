#include "common.h"
namespace eims
{
namespace common
{

unordered_map<unsigned long int, lua_oper*> Common::luavms;

pthread_mutex_t Common::sql_locker;
pthread_mutex_t Common::xml_locker;
pthread_mutex_t Common::lua_locker;
pthread_mutex_t Common::ses_locker;
unsigned short Common::cur_sql_count = 0;
unsigned short Common::cur_xml_count = 0;
unsigned short Common::cur_ses_count = 0;
unsigned short Common::cur_lua_count = 0;

lua_oper* Common::lua_vm_grab(unsigned long int id)
{
	if(cur_lua_count > MAXTHREADS)
	{
		//lua的指针数已经大于线程数量，有异常，可能有泄漏
        //记录日志
        string log = "lua pointer's num is bigger then thread's num, memery maybe lost. current thread's count is:" + shove::convert::NumberToString(cur_lua_count);
		Global::logger->write_log(log, eLogLv.ERROR);
	}
	lua_oper* ret = NULL;
	pthread_mutex_lock(&lua_locker);
    if(Common::luavms.find(id) != Common::luavms.end())
    {
    	ret = Common::luavms[id];
    }
    else
    {
		ret = new lua_oper();
        ret->reset_scipt_folder(SCRIPT_FOLDER_PATH.c_str());
        ret->set_entrance_file(SCRIPT_ENTRANCE_FILE.c_str());
        int r = ret->load_lua_file();
        if(r != 0)
        {
            string log = "Lua vm create failed, reason: load lua file failed, code:";
            log.append(longlong2str(r));
			Global::logger->write_log(log, eLogLv.ERROR);
            delete ret;
            pthread_mutex_unlock(&lua_locker);
            return NULL;
        }
        Common::luavms[id] = ret;
        cur_lua_count++;

    }
    pthread_mutex_unlock(&lua_locker);
    return ret;
}


xml_oper* Common::xml_parser_grab(unsigned long int id)
{
    if(cur_xml_count > (unsigned)MAXTHREADS)
    {
        //xml的指针数已经大于线程数量，有异常，可能有泄漏
        //记录日志
        string log = "xml pointer's num is bigger then thread's num, memery maybe lost";
		Global::logger->write_log(log, eLogLv.ERROR);
    }
    xml_oper* ret = NULL;
    pthread_mutex_lock(&xml_locker);
    if(g_xml_parsers.find(id) != g_xml_parsers.end())
    {
    	ret = g_xml_parsers[id];
    }
    else
    {
    	ret = new xml_oper;
        g_xml_parsers[id] = ret;
        assert(g_xml_parsers[id] != NULL);
        cur_xml_count++;
    }
    pthread_mutex_unlock(&xml_locker);
    return ret;
}


//SqlConnect* Common::sql_oper_grab(unsigned long int id)
mysql_cnt* Common::sql_oper_grab(unsigned long int id)
{
    if(cur_sql_count > (unsigned)MAXTHREADS)
    {
        //db连接的指针数已经大于线程数量，有异常，可能有泄漏
        //记录日志
        string log = "sql pointer's num is bigger then thread's num, memery maybe lost";
		Global::logger->write_log(log, eLogLv.ERROR);
    }

	eims::db::mysql_cnt* ret = NULL;
    pthread_mutex_lock(&sql_locker);
    if(g_db_opers.find(id) != g_db_opers.end())//g_db_opers[id] == NULL)
    {
    	ret = g_db_opers[id];
    }
    else
    {
    	ret = new mysql_cnt();
        assert(ret != NULL);
        ret->set_options(MYSQL_OPT_CONNECT_TIMEOUT, (void*)&DB_CONNECTTIMEOUT);
        ret->set_options(MYSQL_OPT_READ_TIMEOUT, (void*)&DB_READTIMEOUT);
        ret->set_options(MYSQL_OPT_WRITE_TIMEOUT, (void*)&DB_WRITETIMEOUT);
        bool allow_recnt = true;
        ret->set_options(MYSQL_OPT_RECONNECT, (void*)&allow_recnt);
        if(ret->connect(DB_SERVER.c_str(), DB_USER.c_str(), DB_PASSWORD.c_str(), DB_DATANAME.c_str(), DB_PORT) != 0)
        {
        	pthread_mutex_unlock(&sql_locker);
        	Global::logger->write_log("数据库连接失败。" + (string)ret->get_error_reason(), eLogLv.ERROR);
        	return NULL;
        }
        g_db_opers[id] = ret;
        cur_sql_count++;
    }
    pthread_mutex_unlock(&sql_locker);
    return ret;
}

shove::security::ses* Common::ses_oper_grab(unsigned long int id)
{
    if(cur_ses_count > (unsigned)MAXTHREADS)
    {
        //ses加密解密的指针数已经大于线程数量，有异常，可能有泄漏
        //记录日志
        string log = "ses pointer's num is bigger then thread's num, memery maybe lost";
		Global::logger->write_log(log, eLogLv.ERROR);
    }
    shove::security::ses* ret = NULL;
	pthread_mutex_lock(&ses_locker);
	if(g_ses_opers.find(id) != g_ses_opers.end())
	{
		ret = g_ses_opers[id];
	}
	else
	{
		ret = new shove::security::ses();
		g_ses_opers[id] = ret;
		cur_ses_count++;
	}
	pthread_mutex_unlock(&ses_locker);
	return ret;
}


void Common::lua_vm_release(unsigned long int id)
{
    if(Common::luavms[id] != NULL)
    {
        delete Common::luavms[id];
    }
}

Common::~Common()
{
	//delete_all();
	pthread_mutex_unlock(&sql_locker);
	pthread_mutex_unlock(&xml_locker);
	pthread_mutex_unlock(&lua_locker);
	pthread_mutex_unlock(&ses_locker);
}

void Common::delete_all()
{
	for(LUAOPERS::iterator it = luavms.begin(); it != luavms.end(); it++)
	{
		delete it->second;
	}
	for(SQLOPERS::iterator it = g_db_opers.begin(); it != g_db_opers.end(); it++)
	{
		//it->second->DisConnect();
		it->second->close();
		delete it->second;
	}
	for(SESOPRES::iterator it = g_ses_opers.begin(); it != g_ses_opers.end(); it++)
	{
		delete it->second;
	}
	for(XMLOPERS::iterator it = g_xml_parsers.begin(); it != g_xml_parsers.end(); it++)
	{
		delete it->second;
	}
	luavms.clear();
	g_db_opers.clear();
	g_ses_opers.clear();
	g_xml_parsers.clear();
}

void Common::loadconfig()
{
    // 装载系统相关的配置项
    configure_file ini("eims_server_terminal_system.ini");

    MAXTHREADS = ini.read_int("MAXTHREADS");
    HOST_ADDRESS = ini.read_string("HOST_ADDRESS");
    HOST_PORT = ini.read_int("HOST_PORT");

    HTTPPORT = ini.read_int("HTTPPORT");
    HTTPTHREADS = ini.read_int("HTTPTHREADS");

    DB_MAXCONNECTION = ini.read_int("DB_MAXCONNECTION");
    DB_SERVER = ini.read_string("DB_SERVER");
    DB_DATANAME = ini.read_string("DB_DATANAME");
    DB_USER = utility::SES_Decrypt(ini.read_string("DB_USER"), SYSTEM_KEY);
    DB_PASSWORD = utility::SES_Decrypt(ini.read_string("DB_PASSWORD"), SYSTEM_KEY);
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

	SUBSCRIBEPORT = ini.read_int("SUBSCRIBEPORT");
	if(SUBSCRIBEPORT < 0) SUBSCRIBEPORT = 3005;

	SCRIPT_FOLDER_PATH = ini.read_string("SCRIPT_FOLDER_PATH");
	if(SCRIPT_FOLDER_PATH == "") SCRIPT_FOLDER_PATH = "./script";

    SCRIPT_ENTRANCE_FILE = ini.read_string("SCRIPT_ENTRANCE_FILE");
    if(SCRIPT_ENTRANCE_FILE == "") SCRIPT_ENTRANCE_FILE = "eims_main.lua";

    SCRIPT_ENTRANCE_FUNC = ini.read_string("SCRIPT_ENTRANCE_FUNC");
    if(SCRIPT_ENTRANCE_FUNC == "") SCRIPT_ENTRANCE_FUNC = "eims_main";

	//加载逻辑相关的配置项
//    configure_file iniL("eims_server_terminal_logic.ini");
//
//    INTERVAL_GET_DATA_COUNT = iniL.read_int("INTERVAL_GET_DATA_COUNT");
//    INTERVAL_GET_USER_MSG = iniL.read_int("INTERVAL_GET_USER_MSG");
//    INTERVAL_GET_NOTIFY = iniL.read_int("INTERVAL_GET_NOTIFY");
//    INTERVAL_GET_APPLICATIONS_NOTIFY = iniL.read_int("INTERVAL_GET_APPLICATIONS_NOTIFY");
//    INTERVAL_GET_ALL_SITES = iniL.read_int("INTERVAL_GET_ALL_SITES");
//    INTERVAL_GET_ALL_SITES_USINT = iniL.read_int("INTERVAL_GET_ALL_SITES_USINT");
//    INTERVAL_GET_APPLICATIONS = iniL.read_int("INTERVAL_GET_APPLICATIONS");
//    INTERVAL_GET_CONTROL_TYPES = iniL.read_int("INTERVAL_GET_CONTROL_TYPES");
//    INTERVAL_GET_NOTIFY_TYPES = iniL.read_int("INTERVAL_GET_NOTIFY_TYPES");
//    INTERVAL_GET_CONTROLS = iniL.read_int("INTERVAL_GET_CONTROLS");
//    INTERVAL_GET_TRADE_TYPES = iniL.read_int("INTERVAL_GET_TRADE_TYPES");
//    INTERVAL_GET_PROVINCES = iniL.read_int("INTERVAL_GET_PROVINCES");
//    INTERVAL_GET_CITYS = iniL.read_int("INTERVAL_GET_CITYS");
//    INTERVAL_GET_AREAS = iniL.read_int("INTERVAL_GET_AREAS");
//    INTERVAL_UPDATE_GET_USINGS = iniL.read_int("INTERVAL_UPDATE_GET_USINGS");
//
//    XINIUYUNRESURL = iniL.read_string("XINIUYUNRESURL");
}
}
}
