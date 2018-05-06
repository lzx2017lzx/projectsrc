#ifndef MYSQL_CONNECT_H
#define MYSQL_CONNECT_H
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <vector>
#include <string>
#include <map>
#include <mysql.h>

using namespace std;
namespace eims
{
namespace db
{

struct mysql_opt
{
    mysql_option opt_name;
    void* opt_value;
};

class mysql_cnt
{
public:
    mysql_cnt();
    virtual ~mysql_cnt();
    int connect(const char* host,
                const char* user,
                const char* pass,
                const char* db,
                const int port);
    void close();

    unsigned long get_rows_count();
    unsigned long get_fields_count();

    int exe_sql(const char* sql);
    long long exe_sql_transaction(const char* sql, bool is_commit);
    const char* get_query_result(int row_idx, const char* field_name);
    const char* get_query_byte_result(int row_idx, const char* field_name);

    int set_options(mysql_option opt, void* value);

    my_bool roll_back();
    my_bool commit();

    void release_result();
    const char* get_error_reason();
protected:
    int init_(MYSQL* ml);
    void free_results();
private:
    vector<mysql_opt> m_opts;
    MYSQL m_mysql;
    bool m_transaction_open;
    MYSQL_RES* m_res;
	map<string, unsigned int> m_fields;
    string error_desc;

};
}
}
#endif // MYSQL_CONNECT_H
