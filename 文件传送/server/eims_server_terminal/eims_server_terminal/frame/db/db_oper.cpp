#include "db_oper.h"

namespace eims
{
namespace db
{

db_oper::db_oper()
{
	m_isopen = false;
	unsigned long int pid = pthread_self();
    m_cnt_ = Common::sql_oper_grab(pid);
    if(m_cnt_ != NULL) m_isopen = true;
}

db_oper::~db_oper()
{
	m_cnt_ = NULL;
}

//get row count
int db_oper::get_row_count()
{
	if(!m_isopen)
	{
		Global::logger->write_log("db connectiion is not open.", eLogLv.ERROR);
		return -1;
	}
    //return m_cnt_->Get_Row_Count();
    return m_cnt_->get_rows_count();
}

//get query result
const char* db_oper::get_query_result(int row,const char* itemStr)
{
	if(!m_isopen)
	{
		Global::logger->write_log("db connectiion is not open.", eLogLv.ERROR);
		return "";
	}
	//return m_cnt_->Get_Query_Result(row, itemStr);
	const char* temp = m_cnt_->get_query_result(row, itemStr);
	if(!temp)
	{
		Global::logger->write_log("get a null. field is " + (string)itemStr + "." + m_cnt_->get_error_reason(), eLogLv.ERROR);
		return "";
	}
	return m_cnt_->get_query_result(row, itemStr);
}

const char* db_oper::get_query_byte_result(int row,const char* itemStr)
{
	if(!m_isopen)
	{
		Global::logger->write_log("db connectiion is not open.", eLogLv.ERROR);
		return "";
	}
	//return m_cnt_->Get_Query_Byte_Result(row, itemStr);
	const char* temp = m_cnt_->get_query_result(row, itemStr);
	if(!temp)
	{
		Global::logger->write_log("get a null. field is " + (string)itemStr + "." + m_cnt_->get_error_reason(), eLogLv.ERROR);
		return "";
	}
	return m_cnt_->get_query_byte_result(row, itemStr);
}

//oper db :select
int  db_oper::oper_db(const char* sqlStr)
{
	if(!m_isopen)
	{
		Global::logger->write_log("db connectiion is not open.", eLogLv.ERROR);
		return -1;
	}
	//printf("0\n");
	//return m_cnt_->ExeSql(sqlStr);
	if(m_cnt_ == NULL)
	{
		//printf("4\n");
		Global::logger->write_log("connection was lost. being a null.", eLogLv.ERROR);
		//printf("5\n");
		return -1;
	}
	//printf("1\n");
	int ret = m_cnt_->exe_sql(sqlStr);
	//printf("2\n");
	return ret;
}

///参数化，防止被注入攻击
//int  db_oper::oper_db(const char* sqlStr, int pCount, ...)
//{
//	//return m_cnt_->ExeSql(sqlStr, pCount, ...);
//	return 0;
//}

int db_oper::oper_db_trans_exc_v2(const char* sqlStr,bool as_end)
{
	if(!m_isopen)
	{
		Global::logger->write_log("db connectiion is not open.", eLogLv.ERROR);
		return -1;
	}
	//return m_cnt_->ExeSQL_Trans_EX(sqlStr, as_end);
	long long ret = m_cnt_->exe_sql_transaction(sqlStr, as_end);
	return ret;
}

void db_oper::release_res()
{
	if(!m_isopen)
	{
		Global::logger->write_log("db connectiion is not open.", eLogLv.ERROR);
		return ;
	}
	m_cnt_->release_result();
	return;
}

bool db_oper::commit()
{
	if(!m_isopen)
	{
		Global::logger->write_log("db connectiion is not open.", eLogLv.ERROR);
		return false;
	}
	//return m_cnt_->Commit();
	return m_cnt_->commit();
}

bool db_oper::rollback()
{
	if(!m_isopen)
	{
		Global::logger->write_log("db connectiion is not open.", eLogLv.ERROR);
		return false;
	}
	//return m_cnt_->RollBack();
	return m_cnt_->roll_back();
}

string db_oper::get_error_reason()
{
	if(!m_isopen)
	{
		Global::logger->write_log("db connectiion is not open.", eLogLv.ERROR);
		return "";
	}
	//return m_cnt_->Get_error_reason();
	return m_cnt_->get_error_reason();
}
const char* db_oper::get_error_desc()
{
	if(!m_isopen)
	{
		Global::logger->write_log("db connectiion is not open.", eLogLv.ERROR);
		return "";
	}
	//return m_cnt_->Get_error_reason().c_str();
	return m_cnt_->get_error_reason();
}

}
}
