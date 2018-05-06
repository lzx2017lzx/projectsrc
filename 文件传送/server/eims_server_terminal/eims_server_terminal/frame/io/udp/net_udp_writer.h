#ifndef UDPWRITTER_H
#define UDPWRITTER_H
#include <iostream>
#include <stdio.h>
#include <sys/socket.h>
#include <unistd.h>
#include <sys/types.h>
#include <sys/time.h>
#include <netinet/in.h>
#include <stdlib.h>
#include <time.h>
#include <string.h>
#include <stdlib.h>
#include <map>
#include <pthread.h>
#include<signal.h>

#include "../../common/meta.h"

using namespace std;
using namespace eims::meta;

namespace eims
{
	namespace network
	{
		///订阅客户端的缓存信息
		struct client
		{
			///订阅等级
			int sub_lev;
			///客户端地址信息
			sockaddr_in addr;
			///最近的活跃时间
			unsigned long int ac_time;
		};

		/// //////////////////////////////////////////////////////
		///
		///	该类目前只是用于日志的订阅，日志通过UDP向外输出
		///
		/// ///////////////////////////////////////////////////////
		class udp_writter
		{
			public:
				///互斥锁
				static pthread_mutex_t locker;
				///订阅客户端集合
				static map<int, client> clients;

			public:
				///构造
				udp_writter();
				///析构
				~udp_writter();
				///初始化
				bool initial(int port);
				///停止订阅
				void stop();
				///发送日志
				bool write_to_sock(string log);

				///获取本地开放的UDP端口
				inline int get_port();
				///获取运行状态
				inline bool get_state();
				///获取通讯套接字
				inline int get_sock();

			private:
				///运行状态
				bool m_run_;
				///本地地址结构体
				sockaddr_in m_localAddr_;
				///本地套接字
				int m_sock_;
				///接收线程
				pthread_t m_recv_t_;
				///本地开放端口
				int m_port_;
		};
	}
}
#endif // UDPWRITTER_H
