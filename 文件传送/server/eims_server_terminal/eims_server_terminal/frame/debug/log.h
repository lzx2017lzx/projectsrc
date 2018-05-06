#ifndef LOG_H
#define LOG_H

#include <map>
#include <vector>
#include <string>
#include <stdio.h>
#include <pthread.h>
#include <string.h>
#include <semaphore.h>
#include <sstream>
#include <fstream>
//#include <convert.h>
#include "../../frame/security/shove/convert.h"
#include "../io/udp/net_udp_writer.h"
#include "../common/consts.h"
#include "../common/meta.h"

using namespace std;
using namespace shove;
using namespace eims::network;
using namespace eims::meta;

namespace eims
{
	namespace debug
	{
		///日志等级枚举
		extern struct STULOGLEVEL
		{
			enum LOGLEVEL { FATAL = 1, ERROR, WARN, INFO, DEBUG, RUNTIME};
		} eLogLv;

		///数据缓存链表（单向链表）的节点
		struct NODE
		{
			///数据是否已经被取走的标识
			int i;
			///节点数据内容的长度
			int len;
			///节点（日志）的等级
			int lev;
			///节点的数据内容
			char* data;
			///日志产生的时间
			string ptime;
			///下一个节点
			NODE* next_;
			///构造
			NODE()
			{
				lev = 6; data = NULL; next_ = NULL; ptime = convert::TimeToString();
			};
			///构造
			~NODE()
			{
				if(data != NULL) delete[] data; data = NULL;
			};
		};

		///数据缓存链表
		class ShareList
		{
			///链表头
			NODE* header_;
			///链表尾
			NODE* curnode_;
		public:
			ShareList();
			~ShareList();
			///向链表中添加节点，只需要传入日志的内容及等级即可，方法会生成节点，并添加到链表中
			void put_back(string data, int lv);
			///获取链表头上的节点的内容，并删除头节点
			void get_front(string& content, int &lev, string& ptime);
		};

		///日志内容
		struct LogContent
		{
			///日志内容
			string ctx;
			///日志等级
			int level;
			///生成日志的线程ID
			long long tid;
			/// 日志产生的时间
			string produce_time;
		};

		///日志类
		class Logger
		{
			Logger();

			///互斥锁
			static pthread_mutex_t create_locker;

			///各线程的日志队列
			static map<unsigned long int, ShareList*> m_queues_;
			///信号量
			static sem_t m_rwsem_;
			///日志管理线程
			pthread_t m_sel_mgr_thread_;
			///日志的单例指针
			static Logger* m_self_;

			///获取线程对应的日志队列
			ShareList* _get_queue(unsigned long int id);

		public:
			~Logger();
			///初始化。参数为日志路径
			bool initialize(string path);
			///写日志。参数分别为日志内容，日志等级
			void write_log(string log, int lev);
			///向缓存队列中获取日志
			void get_one_log_ex(vector<LogContent>& logs);
			///关闭日志
			void quit();
			///创建日志类的单例
			static Logger* get_singleton();

			///日志运行标志
			bool m_isrun_;
			///日志路径
			string m_log_path_;
			///UDP订阅的IO对象
			udp_writter m_udp_wr_;
			///日志订阅等级
			int m_log_sublevel;

		};
	}
}

#endif // LOG_H
