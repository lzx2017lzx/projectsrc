#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <sys/wait.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>


#include "make_log.h"
#include "util.h"

#include "upload_file.h"

#include "fcgi_stdio.h"
#include "fcgi_config.h"

#define FCGI        "fcgi"
#define FCGI_DATA   "data"


#define VALUE_LEN  128

void increase_pv(char *file_id)
{
    int ret = 0;
    redisContext *conn = NULL;

    conn = rop_connectdb_nopwd("127.0.0.1", "6379");
    if (conn == NULL) {
        LOG(FCGI, FCGI_DATA, "conn redis server error ");
        return ;
    }

    ret = rop_hincrement_one_field(conn, FILEID_PV_HASH, file_id, 1);
    if (ret == -1) {
        LOG(FCGI, FCGI_DATA, "add pv %s error ", file_id);
        return ;
    }

    rop_disconnect(conn);
}

int main ()
{
    int retn = 0;
    char *query_string = NULL;

    while (FCGI_Accept() >= 0) {
        char *json_str = NULL; 
        char cmd[VALUE_LEN] = {0};
        char fromId[VALUE_LEN] = {0};
        char count[VALUE_LEN] = {0};
        char file_id[VALUE_LEN] = {0};

        printf("Content-type: text/html\r\n"
                "\r\n");


        query_string = getenv("QUERY_STRING");

        LOG(FCGI, FCGI_DATA, "query_string = [%s]", query_string);

        query_parse_key_value(query_string, "cmd", cmd, NULL);

        if (strcmp(cmd, "newFile") == 0) {
            //主界面查询数据的业务
            query_parse_key_value(query_string, "fromId", fromId, NULL);
            query_parse_key_value(query_string, "count", count, NULL);
            LOG(FCGI, FCGI_DATA, "fromd = [%s], count = %s", fromId, count);

            //查询数据库 ---> json_str
            //测试先把写死json数据返回
#if 0
            char *json_str = malloc(4096);
            memset(json_str, 0, 4096);
            FILE *fp = fopen("json_test_data.json", "r");
            fread(json_str, 4096, 1, fp);
            fclose(fp);
#endif
            retn = select_files(atoi(fromId), atoi(count), &json_str);
            if (retn != 0) {
                LOG(FCGI, FCGI_DATA, "select files error");
                goto END;
            }

            LOG(FCGI, FCGI_DATA, "json_str =[\n%s\n]", json_str);
            //将数据打印给前端
            printf("%s", json_str);

        }
        else if (strcmp(cmd, "increase") == 0) {
            //增加点击量业务

            //得到fileid
            query_parse_key_value(query_string, "fileId", file_id, NULL);

            //fileid中的 %2F --> /
            str_replace(file_id, "%2F", "/");
            LOG(FCGI, FCGI_DATA, "increase: fileid=[%s]", file_id);

            //更改FILEID_PV_HASH ---> fileid 字段 + 1
            increase_pv(file_id);

        }



END:
        if (json_str != NULL) {
            free(json_str);
            json_str = NULL;
        }

    } /* while */

    return 0;
}
