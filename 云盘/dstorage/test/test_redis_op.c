#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <pthread.h>

#include "redis_op.h"
#include "make_log.h"

#define LOG_MODULE "test"
#define LOG_PROC "redis_op"

int main(int argc, char *argv[])
{
    redisContext *conn = NULL; //redis连接句柄
    int ret = 0;
    char value[VALUES_ID_SIZE] = {0};
    int i = 0;

    RVALUES value_array = NULL;

    conn = rop_connectdb_nopwd("127.0.0.1", "6379") ;
    
    if (conn == NULL) {
        LOG(LOG_MODULE, LOG_PROC, "conntect error");
        return 1;
    }

    ret = rop_set_string(conn, "FOO", "nihaoshijie");
    if (ret != 0) {
        LOG(LOG_MODULE, LOG_PROC, "set error");
        return 1;
    }

    ret = rop_get_string(conn, "FOO", value);
    if (ret != 0) {
        LOG(LOG_MODULE, LOG_PROC, "get error");
        return 1;
    }

    printf("value = %s\n", value);

    //创建一个链表 添加元素
    ret = rop_list_push(conn, "my_list_key", "zhang3");
    if (ret != 0) {
        LOG(LOG_MODULE, LOG_PROC, "list push error");
        return 1;
    }

    ret = rop_list_push(conn, "my_list_key", "li4");
    if (ret != 0) {
        LOG(LOG_MODULE, LOG_PROC, "list push error");
        return 1;
    }

    ret = rop_list_push(conn, "my_list_key", "zhang5");
    if (ret != 0) {
        LOG(LOG_MODULE, LOG_PROC, "list push error");
        return 1;
    }

    int count = 8;
    int array_len = 0;
    value_array = malloc(count *VALUES_ID_SIZE);
    memset(value_array, 0, count*VALUES_ID_SIZE);


    ret = rop_range_list(conn, "my_list_key", 0, count-1, value_array, &array_len);
    if (ret != 0) {
        LOG(LOG_MODULE, LOG_PROC, "range error");
        return 1;
    }

    for (i = 0 ; i < array_len; i++) {
        printf("value_array[%d] = %s\n", i, value_array[i]);
    }

    free(value_array);


    printf("------------------------\n");

    ret = rop_hash_set(conn, "my_hash_key", "name", "zhang3");
    if (ret != 0) {
        LOG(LOG_MODULE, LOG_PROC, "hset error");
        return 1;
    }

    ret = rop_hash_set(conn, "my_hash_key", "age", "18");
    if (ret != 0) {
        LOG(LOG_MODULE, LOG_PROC, "hset error");
        return 1;
    }

    memset(value, 0, VALUES_ID_SIZE);
    ret = rop_hash_get(conn, "my_hash_key", "name", value);
    if (ret != 0) {
        LOG(LOG_MODULE, LOG_PROC, "hget error");
        return 1;
    }






    //断开连接
    rop_disconnect(conn);



	return 0;
}
