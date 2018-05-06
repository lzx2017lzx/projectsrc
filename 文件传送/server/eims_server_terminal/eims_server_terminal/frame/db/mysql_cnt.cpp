#include "mysql_cnt.h"

namespace eims
{
namespace db
{
mysql_cnt::mysql_cnt(): m_transaction_open(false), m_res(NULL)
{
    //ctor
}

mysql_cnt::~mysql_cnt()
{
    //dtor
}
int mysql_cnt::init_(MYSQL* ml)
{
    if(mysql_init(ml) == NULL)
        return -1;
    return 0;
}
int mysql_cnt::connect(const char* host,
                       const char* user,
                       const char* pass,
                       const char* db,
                       const int port = 3306)
{
    if(init_(&m_mysql))
    {
        return -1;
    }
    for(vector<mysql_opt>::iterator it = m_opts.begin(); it != m_opts.end(); it++)
    {
        mysql_options(&m_mysql, it->opt_name, it->opt_value);
    }

    if((host == NULL) || (user == NULL) || (pass == NULL) || (db == NULL))
    {
        error_desc = "argument error";
        return -1;
    }

    if(!mysql_real_connect(&m_mysql, host, user, pass, db, port, NULL, 0))
    {
    	error_desc = mysql_error(&m_mysql);
    	return -1;
    }

    return 0;
}

void mysql_cnt::close()
{
	release_result();
    mysql_close(&m_mysql);
    //mysql_library_end();
}

void str_to_lwr(std::string& s)
{
	std::string::iterator it;
	for (it = s.begin(); it != s.end(); ++it) {
		*it = tolower(*it);
	}
}

unsigned long mysql_cnt::get_rows_count()
{
    if(!m_res)
        return 0;
    return mysql_num_rows(m_res);
}

unsigned long mysql_cnt::get_fields_count()
{
    if(!m_res)
        return 0;
    return mysql_num_fields(m_res);
}

int mysql_cnt::exe_sql(const char* sql)
{
    if(!sql)
    {
    	error_desc = "被执行的SQL语句为NULL";
    	return -1;
    }
	mysql_query(&m_mysql, "set names UTF8;");
    int qr = mysql_query(&m_mysql, sql);
    if(qr != 0)
    {
        // 确认连接是否正常，若不正常则重连
        qr = mysql_ping(&m_mysql);
        if(qr != 0)
        {
        	// 重连失败了
        	error_desc = mysql_error(&m_mysql);
        	return qr;
        }
        // 重新执行下SQL语句
        qr = mysql_query(&m_mysql, sql);
        if(qr != 0)
        {
        	error_desc = mysql_error(&m_mysql);
        	return qr;
        }
    }
    release_result();
    m_res = mysql_store_result(&m_mysql);
    if(m_res)
    {
    	// 记录下结果集中的列名
    	mysql_data_seek(m_res, 0);
		unsigned int rn = mysql_num_fields(m_res);
		for(unsigned int i = 0; i < rn; i++)
		{
			string temp(mysql_fetch_field(m_res)->name);
			str_to_lwr(temp);
			m_fields[temp] = i;
		}
    }
	return 0;
}

long long mysql_cnt::exe_sql_transaction(const char* sql, bool is_commit)
{
	//free_results();
    if(!m_transaction_open)
    {
        mysql_rollback(&m_mysql);
        int o = mysql_autocommit(&m_mysql, 0);
        if(o != 0)
        {
        	error_desc = mysql_error(&m_mysql);
        	return -1;
        }
        m_transaction_open = true;
    }
    if(!sql)
    {
    	error_desc = "被执行的SQL语句为NULL";
    	return -1;
    }
	mysql_query(&m_mysql, "set names UTF8;");
    int qr = mysql_query(&m_mysql, sql);
    if(qr != 0)
    {
    	// 确认连接是否正常，若不正常则重连
        qr = mysql_ping(&m_mysql);
        if(qr != 0)
        {
        	// 重连失败了
        	error_desc = mysql_error(&m_mysql);
			return -1;
        }
        // 重新执行SQL语句
        qr = mysql_query(&m_mysql, sql);
        if(qr != 0)
        {
        	// 执行失败了
        	mysql_rollback(&m_mysql);	// 回滚
        	mysql_autocommit(&m_mysql, 1);	// 恢复为自动提交
        	m_transaction_open = false;	// 关闭事务
        	error_desc = mysql_error(&m_mysql);
			return qr;
        }
    }
    if(is_commit)
    {
        int mc = mysql_commit(&m_mysql);
        if(mc)
        {
            mysql_rollback(&m_mysql);
            mc = mysql_autocommit(&m_mysql, 1);
            m_transaction_open = false;
            error_desc = mysql_error(&m_mysql);
            return -1;
        }
        mc = mysql_autocommit(&m_mysql, 1);
        m_transaction_open = false;
    }
    return mysql_insert_id(&m_mysql);
}

const char* mysql_cnt::get_query_result(int row_idx, const char* field_name)
{
	if((field_name == NULL) || (row_idx < 0))
	{
		error_desc = "要获取的行数小于0或者传入的列名为空！";
		return NULL;
	}
    if((get_rows_count() <= 0) || (get_fields_count() <= 0))
    {
    	error_desc = "当前结果集中没有数据！";
        return NULL;
    }
    if((unsigned)row_idx > (mysql_num_rows(m_res) - 1))
    {
    	error_desc = "要获取的行号大于结果集中拥有的最大行号！";
        return NULL;
    }

	string temp(field_name);
	str_to_lwr(temp);
	// 当无此列时会返回0，因此，对于0需要特殊判断
    unsigned int field_idx = 0;
    if(m_fields.find(temp) != m_fields.end())
    {
    	field_idx = m_fields[temp];
    }
	else
	{
		error_desc = "指定列不存在，列名：";
		error_desc.append(temp);
		return NULL;
	}

    mysql_data_seek(m_res, row_idx);
    MYSQL_ROW mr = mysql_fetch_row(m_res);
    mysql_data_seek(m_res, 0);
    return mr[field_idx] == NULL ? "NULL" : mr[field_idx];
}

const char* mysql_cnt::get_query_byte_result(int row_idx, const char* field_name)
{
	if((field_name == NULL) || (row_idx < 0))
	{
		error_desc = "要获取的行数小于0或者传入的列名为空！";
		return NULL;
	}
    if((get_rows_count() <= 0) || (get_fields_count() <= 0))
    {
    	error_desc = "当前结果集中没有数据！";
        return NULL;
    }
    if((unsigned)row_idx > (mysql_num_rows(m_res) - 1))
    {
    	error_desc = "要获取的行号大于结果集中拥有的最大行号！";
        return NULL;
    }

	string temp(field_name);
	str_to_lwr(temp);
    //当无此列时会返回0，因此，对于0需要特殊判断
    unsigned int field_idx = 0;
    if(m_fields.find(temp) != m_fields.end())
    {
    	field_idx = m_fields[temp];
    }
	else
	{
		error_desc = "指定列不存在，列名：";
		error_desc.append(temp);
		return NULL;
	}

    mysql_data_seek(m_res, row_idx);
    MYSQL_ROW mr = mysql_fetch_row(m_res);
    mysql_data_seek(m_res, 0);

    char c = mr[field_idx] == NULL ? -1 :mr[field_idx][0];
    if(c == 0)
        return "0";
    return "1";
}
int mysql_cnt::set_options(mysql_option opt, void* value)
{
	if(value == NULL)
	{
		error_desc = "传入的选项值是NULL";
		return -1;
	}
    mysql_opt o;
    o.opt_name = opt;
    o.opt_value = value;
    m_opts.push_back(o);
    return 0;
}
void mysql_cnt::release_result()
{
    if(m_res) mysql_free_result(m_res);
		m_res = NULL;
    m_fields.clear();
}

const char* mysql_cnt::get_error_reason()
{
	return error_desc.c_str();
    //return mysql_error(&m_mysql);
}

my_bool mysql_cnt::roll_back()
{
	my_bool r = mysql_rollback(&m_mysql);
	if(!r)
	{
		error_desc = mysql_error(&m_mysql);
		return false;
	}
	return true;
	//return mysql_rollback(&m_mysql);
}
my_bool mysql_cnt::commit()
{
	my_bool r = mysql_commit(&m_mysql);
	if(!r)
	{
		error_desc = mysql_error(&m_mysql);
		return false;
	}
	return true;
	//return mysql_commit(&m_mysql);
}
}
}
