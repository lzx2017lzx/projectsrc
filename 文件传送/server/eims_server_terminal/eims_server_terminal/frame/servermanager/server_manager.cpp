#include "server_manager.h"

namespace eims
{
namespace manager
{

void server_manager::initial()
{
	// 初始化随机种子
    srand((unsigned int)time(NULL));//random

    //加载配置文件
	Common::loadconfig();

	//日志类初始化
	if(!Global::logger->initialize(DEBUG_FILE))
	{
		printf("Warn: Logger initial failed.\n");
	}

	Global::logger->write_log("eims_server_terminal starting", eLogLv.INFO);
}

void* tcp_recv(void* p)
{
	if(!p)
	{
		printf("Error: tcp 模块无法启动.\n");
		return NULL;
	}
	eims::tcp::server* p_tcp = (eims::tcp::server*)p;
	try
	{
		p_tcp->run();
	}
	catch (const std::exception& e)
	{
		string log("tcp模块启动失败，");
		log.append(e.what());
		Global::logger->write_log(log, eLogLv.ERROR);
		return NULL;
	}
    return NULL;
}
void* http_recv(void* p)
{
	if(!p)
	{
		printf("Error: http 模块无法启动.\n");
		return NULL;
	}
	eims::http::server* p_http = (eims::http::server*)p;
	try
	{
		p_http->run();
	}
	catch (const std::exception& e)
	{
		string log("http模块启动失败，");
		log.append(e.what());
		Global::logger->write_log(log, eLogLv.ERROR);
		return NULL;
	}
    return NULL;
}

void server_manager::run_service()
{
	//tcp通讯模块
	string tcp_port = shove::convert::NumberToString<int>(HOST_PORT);
    m_p_tcp_svr_ = new eims::tcp::server(HOST_ADDRESS, tcp_port, MAXTHREADS);
    if(!m_p_tcp_svr_ )
    {
    	printf("Error: tcp通讯模块无法正常启动，程序仍可运行。请检查端口是否被占用。\n");
    }

    //http通讯模块
    string http_port = shove::convert::NumberToString<int>(HTTPPORT);
    m_p_http_svr_ = new eims::http::server(HOST_ADDRESS, http_port, "", HTTPTHREADS);
    if(!m_p_http_svr_ )
    {
    	printf("Error: http通讯模块无法正常启动，程序仍可运行。请检查端口是否被占用。\n");
    }

    if((!m_p_http_svr_) && (!m_p_tcp_svr_))
    {
    	printf("Error: http与tcp模块均无法启动，请检查配置文件是否有误!\n");
    	Global::logger->quit();
		delete Global::logger;
		Global::logger = NULL;
    	return;
    }

	//启动两个守护线程用于启动TCP和HTTP
	pthread_t tcp_t, http_t;
	int rt = pthread_create(&tcp_t, NULL, tcp_recv, m_p_tcp_svr_);
	if(rt != 0)
    {
    	printf("Error: tcp通讯模块无法正常启动，程序仍可运行。请检查服务器内存是否足够。\n");
    }
	int rh = pthread_create(&http_t, NULL, http_recv, m_p_http_svr_);
	if(rh != 0)
	{
		printf("Error: http通讯模块无法正常启动，程序仍可运行。请检查服务器内存是否足够。\n");
	}
	if((rt != 0) && (rh != 0))
	{
		printf("Error: tcp与http通讯模块均无法正常启动。\n");
		Global::logger->quit();
		delete Global::logger;
		Global::logger = NULL;
    	return;
	}

	//等待线程退出
	pthread_join(tcp_t, 0);
	pthread_join(http_t, 0);

	//删除所有全局指针
    Common::delete_all();
    delete m_p_tcp_svr_; delete m_p_http_svr_;
    Global::logger->write_log("server exiting normal", eLogLv.INFO);
    Global::logger->quit();
	delete Global::logger;
	Global::logger = NULL;
}
}
}
