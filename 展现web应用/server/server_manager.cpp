#include "server_manager.h"

namespace lizongxin
{
namespace manager
{

void server_manager::initial()
{
	// 初始化随机种子
    srand((unsigned int)time(NULL));//random

    //加载配置文件
	Common::loadconfig();

}

void* tcp_recv(void* p)
{
	if(!p)
	{
		printf("Error: tcp 模块无法启动.\n");
		return NULL;
	}
	lizongxin::tcp::server* p_tcp = (lizongxin::tcp::server*)p;
	try
	{
		p_tcp->run();
	}
	catch (const std::exception& e)
	{
		return NULL;
	}
    return NULL;
}

void server_manager::run_service()
{
	//tcp通讯模块
	string tcp_port = lizongxin::convert::NumberToString<int>(HOST_PORT);
    m_p_tcp_svr_ = new lizongxin::tcp::server(HOST_ADDRESS, tcp_port, MAXTHREADS);
    LOG("server_manager","run_service","tcp_port:%s",tcp_port.c_str());
    if(!m_p_tcp_svr_ )
    {
    	printf("Error: tcp通讯模块无法正常启动，程序仍可运行。请检查端口是否被占用。\n");
    }

	pthread_t tcp_t;
	int rt = pthread_create(&tcp_t, NULL, tcp_recv, m_p_tcp_svr_);
	if(rt != 0)
    {
    	printf("Error: tcp通讯模块无法正常启动，程序仍可运行。请检查服务器内存是否足够。\n");
    }

	//等待线程退出
	pthread_join(tcp_t, 0);

	//删除所有全局指针
//    Common::delete_all();
    delete m_p_tcp_svr_; 
}
}
}
