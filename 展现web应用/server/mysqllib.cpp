#include "mysqllib.h"

mysqllib * mysqllib::instance = new mysqllib;

mysqllib::mysqllib()
{
    mysql = mysql_init(NULL);
    mysql_real_connect(mysql, "127.0.0.1", "root", "123456", "webnet", 3306, NULL, 0);
    if (NULL == mysql)
    {
        cout << "connect error" << endl;
    }
    mysql_query(mysql, "set names utf8");
}

mysqllib::mysqllib(mysqllib&)
{
}

mysqllib::~mysqllib()
{
    mysql_close(mysql);
}

mysqllib * mysqllib::getInstance()
{
    return instance;
}

int mysqllib::insert(char *sql)
{
    return mysql_query(mysql, sql);
}

int mysqllib::select(char *sql)
{
    mysql_query(mysql, sql);
    MYSQL_RES *result = mysql_store_result(mysql);
    printf("result.\n");
    int rows =-1;
    rows=mysql_num_rows(result);
    return rows;
}

int mysqllib::select(char *sql, char *result_buf)
{
    if(mysql_query(mysql, sql))
    {
        return -1;
    }
    MYSQL_RES *result = mysql_store_result(mysql);
    MYSQL_ROW row;
    while (row = mysql_fetch_row(result))
    {
            sprintf(result_buf, "%s\n", row[0]);
    }
    return 0;
}

int mysqllib::selectgetfieldname(char *sql, char *result_buf)
{
    if(mysql_query(mysql, sql))
    {
        return -1;
    }
    MYSQL_RES *result = mysql_store_result(mysql);
    MYSQL_ROW row;
    unsigned int countFields;
    MYSQL_FIELD *fields;
    countFields=mysql_field_count(mysql);
    fields=mysql_fetch_fields(result);
    sprintf(result_buf,"%s","{");
    /*
        result_buf={"0":{"img":"","name":"","url":""},"1":{},"2":{}};
    */
    int count=0;
    
    while (row = mysql_fetch_row(result))
    {
        unsigned int i=0;
        sprintf(result_buf,"%s\"%d\":{",result_buf,count);
        for(i=0;i<countFields;i++)
        {
            sprintf(result_buf, "%s,\"%s\":\"%s\"", result_buf, fields[i].name,row[i]);
        }
        sprintf(result_buf,"%s}",result_buf);
        count++;
    }
    sprintf(result_buf,"%s}",result_buf);
    return mysql_num_rows(result);
}
int mysqllib::update(char*sql)
{
    return mysql_query(mysql, sql);
}

const char * mysqllib::mysqllib_error()
{
    return mysql_error(mysql); 
}
