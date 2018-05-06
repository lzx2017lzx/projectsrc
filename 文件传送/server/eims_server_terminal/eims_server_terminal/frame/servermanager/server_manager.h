#ifndef SERVER_MANAGER_H
#define SERVER_MANAGER_H

#include <ctime>
#include "../common/consts.h"
#include "../common/common.h"
#include "../io/tcp/tcp_server.h"
#include "../io/http/http_server.hpp"

using namespace eims::common;

namespace eims
{
	namespace manager
	{
		///框架的服务管理类
		class server_manager
		{
			public:
				///构造
				server_manager(){ };
				///析构
				~server_manager(){ };

				///初始化
				void initial();
				///运行服务
				void run_service();

			private:
				///TCP服务的指针
				eims::tcp::server* m_p_tcp_svr_;
				///HTTP服务的指针
				eims::http::server* m_p_http_svr_;
		};
	}
}
#endif // SERVER_MANAGER_H
