#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <pthread.h>

#include <hiredis.h>

int main(int argc, char *argv[])
{
    redisContext *c;
    redisReply *reply;

    c = redisConnect("127.0.0.1", 6379);
    if (c == NULL || c->err) {
        if (c) {
            printf("Connection error: %s\n", c->errstr);
            redisFree(c);
        } else {
            printf("Connection error: can't allocate redis context\n");
        }
        exit(1);
    }


    /* Set a key */
    reply = redisCommand(c,"SET %s %s", "foo", "hello world");

    if (reply == NULL) {
        printf("set error\n");
    }
    printf("SET: %s\n", reply->str);
    freeReplyObject(reply);

    reply = redisCommand(c, "Get %s", "foo");
    if (reply == NULL) {
        printf("set error\n");
    }
    //reply->type -->应该是一个字符串类型
    printf("value = %s, len = %lu\n", reply->str, reply->len);
    freeReplyObject(reply);



    /* Disconnects and frees the context */
    redisFree(c);

    return 0;

	return 0;
}
