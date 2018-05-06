#include "net_udp_writer.h"

namespace eims
{
	namespace network
	{
		///互斥锁
		pthread_mutex_t udp_writter::locker;
		///订阅客户端集合
		map<int, client> udp_writter::clients;

		udp_writter::udp_writter()
		{
			//ctor
			m_run_ = true;
			m_recv_t_ = 0;
		}

		udp_writter::~udp_writter()
		{
			//dtor
		}

		unsigned long int get_time_now()
		{
			struct timeval tv;
			gettimeofday(&tv,NULL);
			unsigned long int t_now = tv.tv_sec * 1000 + tv.tv_usec / 1000;
			return t_now;
		}

		void* sub_log(void* p)
		{
			udp_writter* up = (udp_writter*)p;
			while(up->get_state())
			{
				client cl;
				char buffer[3];
				memset(buffer, 0x0, 3);
				socklen_t remoteAddrLength = sizeof(cl.addr);
				int result = recvfrom(up->get_sock(), &buffer, 2, 0, (struct sockaddr *)&cl.addr, &remoteAddrLength);
				if (result < 2)
				{
					continue;
				}

				//开始订阅
				if(((buffer[0] == 'S') || (buffer[0] == 's')) || ((buffer[0] == 'U') || (buffer[0] == 'u')))
				{
					//printf("receive a sub request\n");
					pthread_mutex_lock(&(up->locker));
					int remoteport = cl.addr.sin_port;
					int remoteip = cl.addr.sin_addr.s_addr;
					cl.ac_time = get_time_now();
					cl.sub_lev = buffer[1];
					up->clients[remoteip + remoteport] = cl;
					pthread_mutex_unlock(&(up->locker));
				}
				//停止订阅
				else if((buffer[0] == 'E') || (buffer[0] == 'e'))
				{
					//printf("receive a sub cancel\n");
					pthread_mutex_lock(&(up->locker));
					int remoteport = cl.addr.sin_port;
					int remoteip = cl.addr.sin_addr.s_addr;
					cl.ac_time = 0;
					up->clients[remoteip + remoteport] = cl;
					pthread_mutex_unlock(&(up->locker));
				}
				//心跳保活
				else
				{
					//printf("receive a sub keep\n");
					pthread_mutex_lock(&(up->locker));
					int remoteport = cl.addr.sin_port;
					int remoteip = cl.addr.sin_addr.s_addr;
					up->clients[remoteip + remoteport].ac_time = get_time_now();
					pthread_mutex_unlock(&(up->locker));
				}
				//返回状态
				string log;
				log.append(convert::TimeToString()).append(" tid: ").append(longlong2str(pthread_self())).append(": [").append(longlong2str(7)).append("]: ").append("your command operator ok\n");

				sendto(up->get_sock(), log.c_str(), log.length(),0, (struct sockaddr *)&(cl.addr) ,remoteAddrLength);
			}
			return NULL;
		}

		bool udp_writter::initial(int port)
		{
			m_port_ = port;
			pthread_mutex_init(&locker, 0);

			m_sock_ = socket(AF_INET, SOCK_DGRAM, 0);
			if(m_sock_ <= 0)
			{
				printf("log subscribe can't create socket.\n");
				return false;
			}
			bzero(&m_localAddr_, sizeof(m_localAddr_));
			m_localAddr_.sin_family = AF_INET;
			m_localAddr_.sin_port = htons(port);
			m_localAddr_.sin_addr.s_addr = INADDR_ANY;
			struct timeval timeout={1,0};//3s
			int ret = setsockopt(m_sock_,SOL_SOCKET,SO_RCVTIMEO,(const char*)&timeout,sizeof(timeout));
			if( ret != 0 )
			{
				printf("log subscribe can't set socket options.\n");
				return false;
			}

			int br = bind(m_sock_, (struct sockaddr *)&m_localAddr_, sizeof(m_localAddr_));
			if(br != 0)
			{
				printf("log subscribe can't bind port.\n");
				return false;
			}
			int r = pthread_create(&m_recv_t_, NULL, sub_log, this);
			if(r != 0)
			{
				printf("log subscribe create thread failed.\n");
				return false;
			}
			return true;
		}

		void udp_writter::stop()
		{
			m_run_ = false;
			if(m_recv_t_)
				pthread_join(m_recv_t_, 0);
			pthread_mutex_destroy(&locker);
		}

		bool udp_writter::write_to_sock(string log)
		{
			//发送日志到远程订阅的维护客户端
			pthread_mutex_lock(&locker);
			for(map<int, client>::iterator it = clients.begin(); it != clients.end(); it++)
			{
				if((get_time_now() - it->second.ac_time) > 60 * 1000)
				{
					clients.erase(it->first);
					continue;
				}
				socklen_t remoteAddrLength = sizeof(it->second.addr);
				/// 发送日志到订阅服务端，不检测是否发送成功
				sendto(m_sock_, log.c_str(), log.length(), 0, (struct sockaddr *)&(it->second.addr) ,remoteAddrLength);
			}
			pthread_mutex_unlock(&locker);
			return true;
		}

		int udp_writter::get_port()
		{
			return m_port_;
		}

		bool udp_writter::get_state()
		{
			return m_run_;
		}

		int udp_writter::get_sock()
		{
			return m_sock_;
		}
	}
}
