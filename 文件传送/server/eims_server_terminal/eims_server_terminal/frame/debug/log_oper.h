#ifndef LOG_OPER_H_INCLUDED
#define LOG_OPER_H_INCLUDED
#include "../common/common.h"

using namespace eims::common;
using namespace eims::debug;

namespace eims
{
	namespace debug
	{
		class log_oper
		{
			public:
				///构造
				log_oper();
				///析构
				~log_oper();
				///写日志。参数一为日志内容，参数二为日志等级
				void WriteLog(char* log, int level);
				///获取日志等级。参数为日志等级的字符串形式，如：ERROR,DEBUF,INFO..)
				int GetLevel(char* lev);
				///日志指针
				Logger* m_log;

		};
	}
}

#endif // LOG_OPER_H_INCLUDED
