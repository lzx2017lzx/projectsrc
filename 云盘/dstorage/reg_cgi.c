#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <sys/time.h>
#include <time.h>

#include "cJSON.h"
#include "dao_mysql.h"
#include "util.h"
#include "make_log.h"

#include "fcgi_stdio.h"
#include "fcgi_config.h"

#define REG_LOG_MODULE       "cgi"
#define REG_LOG_PROC          "reg"

//extern char g_host_name[HOST_NAME_LEN];

int process_result_get_uid(MYSQL *conn, MYSQL_RES *res_set, char *u_id)
{
    MYSQL_ROW row;
    uint i;
    ulong line = 0;


    if (mysql_errno(conn) != 0) {
        LOG(REG_LOG_MODULE, REG_LOG_PROC, "mysql_fetch_row() failed");
        return -1;
    }

    line = mysql_num_rows(res_set);
    LOG(REG_LOG_MODULE, REG_LOG_PROC, "%lu rows returned \n", line);
    if (line == 0) {
        return -1;
    }
    

    while ((row = mysql_fetch_row(res_set)) != NULL) {
        for (i = 0; i<mysql_num_fields(res_set); i++)  {
            if (row[i] != NULL) {
                LOG(REG_LOG_MODULE, REG_LOG_PROC, "%d row is %s", i, row[i]);
                strcpy(u_id, row[i]);
                return 0;
            }
        }
    }

    

    return -1;
}

void deal_reg_query(void)
{
    char *query_string = getenv("QUERY_STRING");
    char user[128];
    char flower_name[128];
    char pwd[128];
    char tel[128];
    char email[128];
    char *out;
    char buffer[SQL_MAX_LEN] = {0};


    //当前时间戳
    struct timeval tv;
    struct tm* ptm;
    char time_str[128];

    gettimeofday(&tv, NULL);
    ptm = localtime(&tv.tv_sec);
    strftime(time_str, sizeof(time_str), "%Y-%m-%d %H:%M:%S", ptm);

    query_parse_key_value(query_string, "user", user, NULL);
    query_parse_key_value(query_string, "flower_name", flower_name, NULL);
    query_parse_key_value(query_string, "pwd", pwd, NULL);
    query_parse_key_value(query_string, "tel", tel, NULL);
    query_parse_key_value(query_string, "email", email, NULL);

    //入mysql库 
    MYSQL *mysql_conn = msql_conn(MYSQL_USER, MYSQL_PWD, MYSQL_DATABASE);
    if (mysql_conn == NULL) {
        return;
    }

    sprintf(buffer, "insert into %s (u_name, nicheng, password, phone, createtime, email) values ('%s', '%s', '%s', '%s', '%s', '%s')",
            "user", user, flower_name, pwd, tel, time_str ,email);

    if (mysql_query(mysql_conn, buffer))  {
        print_error(mysql_conn, "插入失败");
    }


    if (mysql_conn != NULL) {
        mysql_close(mysql_conn);
    }

    /*
       {
        "code":"000"
       } 

       {
        "code":"001"
       }

     
     */
    cJSON *root = cJSON_CreateObject(); 
    cJSON_AddStringToObject(root, "code", "000");
    out = cJSON_Print(root);

    printf(out);
    free(out);
}

int main (void)
{

    while (FCGI_Accept() >= 0) {


        printf("Content-type: text/html\r\n");
        printf("\r\n");

        deal_reg_query();

    }
    return 0;
}
