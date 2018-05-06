#ifndef DB_OPER_H
#define DB_OPER_H

//#include "sql_connect.h"
#include "mysql_cnt.h"
#include "../common/common.h"

using namespace eims::common;

namespace eims
{
	namespace db
	{
		///数据库二次封装类
		class db_oper
		{
			public:
				db_oper();
				~db_oper();

				///执行SQL select/delete/update/insert
				int oper_db(const char* sqlStr);

				///参数化，防止被注入攻击
				//int oper_db(const char* sqlStr, int pCount, ...);
				///获取记录行数
				int get_row_count();
				///获取指定行和列名的值
				const char* get_query_result(int row,const char* itemStr);
				///获取指定行和列的二进制数据
				const char* get_query_byte_result(int row,const char* itemStr);
				///以事务形式执行SQL
				int  oper_db_trans_exc_v2(const char* sqlStr,bool as_end = false);
				///释放记录集
				void release_res();
				///提交事务
				bool commit();
				///回滚
				bool rollback();
				///获取错误原因
				string get_error_reason();
				///获取错误描述，同get_error_reason。这两个函数用在不同的地方。
				const char* get_error_desc();

				bool m_isopen;

			private:
				///连接指针
				mysql_cnt* m_cnt_;
				//SqlConnect* m_cnt_;
		};
	}
}
#endif
