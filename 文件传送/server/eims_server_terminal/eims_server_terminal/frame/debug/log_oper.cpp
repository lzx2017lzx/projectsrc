#include "log_oper.h"


log_oper::log_oper()
{
	m_log = Logger::get_singleton();
}
log_oper::~log_oper()
{
	;
}
void log_oper::WriteLog(char* log, int level)
{
	string strLog(log);
	m_log->write_log(strLog, level);
}
int log_oper::GetLevel(char* lev)
{
	//FATAL/ERROR/WARN/DEBUG/INFO/RUNTIME
	string l(lev);
	if(l == "FATAL")
		return eLogLv.FATAL;
	else if(l == "ERROR")
		return eLogLv.ERROR;
	else if(l == "WARN")
		return eLogLv.WARN;
	else if(l == "DEBUG")
		return eLogLv.DEBUG;
	else if(l == "INFO")
		return eLogLv.INFO;
	else
		return eLogLv.RUNTIME;
}
