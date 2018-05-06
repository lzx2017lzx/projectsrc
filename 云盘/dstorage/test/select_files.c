#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <pthread.h>

#include "redis_op.h"

#define FILE_USER_LIST "FILE_INFO_LIST"
#define FILEID_NAME_HASH "FILEID_NAME_HASH"
#define FILEID_TIME_HASH "FILEID_TIME_HASH"
#define FILEID_USER_HASH "FILEID_USER_HASH"
#define FILEID_PV_HASH "FILEID_PV_HASH"

#define TIME_STR_MAX (256)

int main(int argc, char *argv[])
{
    int ret = 0;
    redisContext *conn = NULL;
    RVALUES file_id_array = NULL; 
    int count = 8;
    int array_len = 0;
    int i = 0;

    char name[VALUES_ID_SIZE] = {0};
    char time[VALUES_ID_SIZE] = {0};
    char user[VALUES_ID_SIZE] = {0};
    char pv[VALUES_ID_SIZE] = {0};

    file_id_array = malloc(count * VALUES_ID_SIZE);
    memset(file_id_array, 0, count *VALUES_ID_SIZE);


    conn = rop_connectdb_nopwd("127.0.0.1", "6379");
    if (conn == NULL) {
        ret = -1;
        goto END;
    }

    //遍历FILE_INFO_LIST
    ret = rop_range_list(conn, FILE_USER_LIST, 0, count-1, file_id_array, &array_len);
    if (ret != 0) {
        printf("range list %s error\n", FILE_USER_LIST);
        goto END;
    }

    //for
    for (i = 0; i < array_len; i++) {
        //得到名字
        printf("--- file id = [%s]\n", file_id_array[i]);
        rop_hash_get(conn, FILEID_NAME_HASH, file_id_array[i], name);
        printf("name = %s\n", name);

        rop_hash_get(conn, FILEID_TIME_HASH, file_id_array[i], time);
        printf("time = %s\n", time);

        rop_hash_get(conn, FILEID_USER_HASH, file_id_array[i], user);
        printf("user = %s\n", user);

        rop_hash_get(conn, FILEID_PV_HASH, file_id_array[i], pv);
        printf("pv = %s\n", pv);
    }

    
    


END:
    if (file_id_array != NULL) {
        free(file_id_array);
    }
    if (conn != NULL) {
        rop_disconnect(conn);
    }
	return ret;
}
