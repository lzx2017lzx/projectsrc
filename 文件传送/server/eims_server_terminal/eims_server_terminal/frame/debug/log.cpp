#include "log.h"

namespace eims
{
namespace debug
{

map<unsigned long int, ShareList*> Logger::m_queues_;

Logger* Logger::m_self_ = NULL;
sem_t Logger::m_rwsem_;
pthread_mutex_t Logger::create_locker;
Logger::Logger()
{
    //ctor
    pthread_mutex_init(&create_locker, 0);
    m_log_sublevel = eLogLv.INFO;
    sem_init(&m_rwsem_, 0, 0);
}
Logger* Logger::get_singleton()
{
	if(m_self_ == NULL)
	{
		m_self_ = new Logger();
	}
	return m_self_;
}
Logger::~Logger()
{
	for(map<unsigned long int, ShareList*>::iterator it = m_queues_.begin(); it != m_queues_.end(); it++)
	{
		delete it->second;
	}
	m_queues_.clear();
    sem_destroy(&m_rwsem_);
    pthread_mutex_destroy(&create_locker);
}
ShareList::ShareList()
{
	header_ = NULL;
    curnode_ = NULL;
}
ShareList::~ShareList()
{
	if(header_ != curnode_)
	{
		if(header_ != NULL)
		{
			delete header_;
			header_ = NULL;
		}
		if(curnode_ != NULL)
		{
			delete curnode_;
			curnode_ = NULL;
		}
	}
	else
	{
		if(header_ != NULL)
			delete header_;
		header_ = NULL;
	}
}

void ShareList::put_back(string data, int lv)
{
    NODE* n = new NODE;
    if(!n) { return; }
    n->data = new char[data.size()];
    if(!n->data) { delete n; n = NULL; return; }
    memcpy(n->data, data.c_str(), data.size());
    n->len = data.size();
    n->i = 0;
    n->lev = lv;
    n->next_ = NULL;
    if(curnode_ != NULL)
    {
        curnode_->next_ = n;
        curnode_ = n;
    }
    else
        curnode_ = n;

    if(header_ == NULL)
        header_ = n;
}

void ShareList::get_front(string& content, int &lev, string& ptime)
{
	content.clear();
	ptime.clear();
    if(header_ == NULL)
        return ;
    if(header_->i == 0)
    {
        content.append(header_->data, header_->len);
        header_->i = 1;
        lev = header_->lev;
        ptime = header_->ptime;
    }
    if(header_->next_ != NULL)
    {
        NODE* t = header_->next_;
        delete header_;
        header_ = t;
    }
}

void Logger::write_log(string log, int lev = eLogLv.RUNTIME)
{
    unsigned long int pid = pthread_self();
	_get_queue(pid)->put_back(log, lev);
	sem_post(&m_rwsem_);
}

/// 获取各缓存中最前面的日志
void Logger::get_one_log_ex(vector<LogContent>& logs)
{
	sem_wait(&m_rwsem_);
	for(map<unsigned long int, ShareList*>::iterator it = m_queues_.begin(); it != m_queues_.end(); it++)
	{
		LogContent log;
		it->second->get_front(log.ctx, log.level, log.produce_time);
		if(log.ctx == "")
			continue;
		log.tid = it->first;
		logs.push_back(log);
	}
}

void* self_manager_func_ex(void* p)
{
	Logger* loger = (Logger*)p;
	string sw = "";
	string sk = "";
	ofstream ofile;
	ofile.open(loger->m_log_path_.c_str(), ofstream::app);
	if(ofile.fail())
	{
		cout<<"Warn: log file open failed .logger will not write to file"<<endl;
		//return NULL;
	}
	vector<LogContent> vlogs;
	while(loger->m_isrun_)
	{
		loger->get_one_log_ex(vlogs);
		if(vlogs.size() <= 0) continue;
		for(vector<LogContent>::iterator it = vlogs.begin(); it != vlogs.end(); it++)
		{
			string logctx = "";
			logctx = it->produce_time;
			logctx.append(" tid: ");
			logctx.append(longlong2str(it->tid));
			logctx.append(": [");
			logctx.append(longlong2str(it->level));
			logctx.append("]: ");
			logctx.append(it->ctx);
			logctx.append("\n");
			//logctx.append(it->produce_time).append().append(longlong2str(it->tid)).append().append().append().append(it->ctx).append("\n");
			if(it->level <= LOGWRITELEVEL)
			{
				sw += logctx;
			}
			if(it->level <= loger->m_log_sublevel)
			{
				sk += logctx;
			}
		}
		//write to file
		if(ofile.is_open() && sw != "")
		{
			ofile<<sw;
			ofile.flush();
		}
		if((LOGPRINT != 0) && (sw != ""))
		{
			//printf("%s\n", sw.c_str());
			printf("%s", sw.c_str());
		}
		//日志订阅开关打开，允许订阅服务终端的日志
		if(LOGSUBSCRIBE == 1)
		{
			loger->m_udp_wr_.write_to_sock(sk);
		}
		sw.clear();
		sk.clear();
		vlogs.clear();
	}
	ofile.close();
	return NULL;
}

bool Logger::initialize(string path)
{
	if(LOGSUBSCRIBE == 1)
	{
		if(!m_udp_wr_.initial(SUBSCRIBEPORT))
		{
			m_udp_wr_.stop();
			printf("log subscribe's socket initial failed!\n");
		}

	}
	m_log_path_ = path;
	m_isrun_ = true;
	int r = pthread_create(&m_sel_mgr_thread_, NULL, self_manager_func_ex, this);
	if(r)
	{
		printf("log thread create failed!\n");
		return false;
	}
	return true;
}
void Logger::quit()
{
	if(LOGSUBSCRIBE == 1)
		m_udp_wr_.stop();
	/// 退出标识
	m_isrun_ = false;
	/// 再发送一个信号，解除线程的等待状态
	sem_post(&m_rwsem_);
	sleep(1);
	pthread_join(m_sel_mgr_thread_, 0);
}

ShareList* Logger::_get_queue(unsigned long int id)
{

	if(m_queues_.find(id) == m_queues_.end())
	{
		pthread_mutex_lock(&create_locker);
		m_queues_[id] = new ShareList();
		pthread_mutex_unlock(&create_locker);
	}
	return m_queues_[id];
}
}
}
