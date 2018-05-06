#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <pthread.h>
#include <time.h>

#include "fdfs_api.h"
#include "redis_op.h"


#define FILE_USER_LIST "FILE_INFO_LIST"
#define FILEID_NAME_HASH "FILEID_NAME_HASH"
#define FILEID_TIME_HASH "FILEID_TIME_HASH"
#define FILEID_USER_HASH "FILEID_USER_HASH"
#define FILEID_PV_HASH "FILEID_PV_HASH"

#define TIME_STR_MAX (256)

int main(int argc, char *argv[])
{
    char file_id[FILE_ID_LEN] = {0};
    redisContext *conn = NULL;
    time_t now;
    char time_str[TIME_STR_MAX] = {0};
    int ret = 0;
    if (argc < 2) {
        printf("usage:./save_one_file [filename]\n");
        exit(1);
    }


    //1将文件存入fastdfs中 --->fileid
    ret = fdfs_upload_by_filename1(argv[1], file_id);
    if (ret == -1) {
        printf("fdfs upload %s error\n", argv[1]);
        goto END;
    }
    

    //2 将fileid --> FILE_INFO_LIST中 
    conn = rop_connectdb_nopwd("127.0.0.1", "6379");
    if (conn == NULL) {
        ret = -1;
        goto END;
    }

    ret = rop_list_push(conn, FILE_USER_LIST, file_id);
    if (ret != 0) {
        printf("push %s to %s error\n", file_id, FILE_USER_LIST);
        goto END;
    }

    //3 存入文件属性hash中
    ret = rop_hash_set(conn, FILEID_NAME_HASH, file_id, argv[1]);
    if (ret != 0) {
        printf("hset %s to %s error\n", file_id, FILEID_NAME_HASH);
        goto END;
    }

    //得到当前时间 
    now = time(NULL);//获得当前系统时间
    strftime(time_str, TIME_STR_MAX, "%Y-%m-%d %H:%M:%S", localtime(&now));
    
    ret = rop_hash_set(conn, FILEID_TIME_HASH, file_id, time_str);
    if (ret != 0) {
        printf("hset %s to %s error\n", file_id, FILEID_TIME_HASH);
        goto END;
    }

    ret = rop_hash_set(conn, FILEID_USER_HASH, file_id, "itcast");
    if (ret != 0) {
        printf("hset %s to %s error\n", file_id, FILEID_USER_HASH);
        goto END;
    }

    ret = rop_hash_set(conn, FILEID_PV_HASH, file_id, "1");
    if (ret != 0) {
        printf("hset %s to %s error\n", file_id, FILEID_PV_HASH);
        goto END;
    }



    rop_disconnect(conn);
END:
	return ret;
}
