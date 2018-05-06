/**
 * @file redis_op.c
 * @brief  redis 操作基本接口和key的操作实现
 */

#include "redis_op.h"


/* -------------------------------------------*/
/**
 * @brief  选择redis一个数据库
 *
 * @param conn		已链接的数据库链接
 * @param db_no		redis数据库编号
 *
 * @returns   
 *			-1 失败
 *			0  成功
 */
/* -------------------------------------------*/
int rop_selectdatabase(redisContext *conn, unsigned int db_no)
{
	int retn = 0;
	redisReply *reply = NULL;

	/* 选择一个数据库 */
	reply = redisCommand(conn, "select %d", db_no);
	if (reply == NULL) {
		fprintf(stderr, "[-][GMS_REDIS]Select database %d error!\n", db_no);
		LOG(REDIS_LOG_MODULE, REDIS_LOG_PROC, "[-][GMS_REDIS]Select database %d error!%s\n", db_no, conn->errstr);
		retn = -1;
		goto END;
	}

	printf("[+][GMS_REDIS]Select database %d SUCCESS!\n", db_no);
	LOG(REDIS_LOG_MODULE, REDIS_LOG_PROC, "[+][GMS_REDIS]Select database %d SUCCESS!\n", db_no);

END:
	freeReplyObject(reply);
	return retn;
}


/* -------------------------------------------*/
/**
 * @brief			清空当前数据库所有信息(慎用)
 *
 * @param conn		已链接的数据库链接
 *
 * @returns   
 *			-1 失败
 *			0  成功
 */
/* -------------------------------------------*/
int rop_flush_database(redisContext *conn)
{
	int retn = 0;	
	redisReply *reply = NULL;

	reply = redisCommand(conn, "FLUSHDB");
	if (reply == NULL) {
		fprintf(stderr, "[-][GMS_REDIS]Clear all data error\n");
		LOG(REDIS_LOG_MODULE, REDIS_LOG_PROC, "[-][GMS_REDIS]Clear all data error\n");
		retn = -1;
		goto END;
	}

	printf("[+][GMS_REDIS]Clear all data!!\n");
	LOG(REDIS_LOG_MODULE, REDIS_LOG_PROC,"[+][GMS_REDIS]Clear all data!!\n");

END:
	freeReplyObject(reply);
	return retn;
}

/* -------------------------------------------*/
/**
 * @brief  判断key值是否存在
 *
 * @param conn		已经建立的链接
 * @param key		需要寻找的key值
 *
 * @returns   
 *				-1 失败
 *				1 存在
 *				0 不存在
 */
/* -------------------------------------------*/
int rop_is_key_exist(redisContext *conn, char* key)
{
	int retn = 0;	

	redisReply *reply = NULL;

	reply = redisCommand(conn, "EXISTS %s", key);
	//rop_test_reply_type(reply);
	if (reply->type != REDIS_REPLY_INTEGER) {
		fprintf(stderr, "[-][GMS_REDIS]is key exist get wrong type!\n");
		LOG(REDIS_LOG_MODULE, REDIS_LOG_PROC, "[-][GMS_REDIS]is key exist get wrong type! %s\n", conn->errstr);
		retn = -1;
		goto END;
	}

	if (reply->integer == 1) {
		retn = 1;	
	}
	else {
		retn = 0;
	}

END:
	freeReplyObject(reply);
	return retn;
}

/* -------------------------------------------*/
/**
 * @brief			删除一个key
 *
 * @param conn		已经建立的链接
 * @param key		
 *
 * @returns   
 *				-1 失败
 *				0 成功
 */
/* -------------------------------------------*/
int rop_del_key(redisContext *conn, char *key)
{
	int retn = 0;
	redisReply *reply = NULL;

	reply = redisCommand(conn, "DEL %s", key);
	if (reply->type != REDIS_REPLY_INTEGER) {
		fprintf(stderr, "[-][GMS_REDIS] DEL key %s ERROR\n", key);
		LOG(REDIS_LOG_MODULE, REDIS_LOG_PROC, "[-][GMS_REDIS] DEL key %s ERROR %s\n", key, conn->errstr);
		retn = -1;
		goto END;
	}

	if (reply->integer > 0) {
		retn = 0;	
	}
	else {
		retn = -1;
	}

END:
	freeReplyObject(reply);
	return retn;
}

/* -------------------------------------------*/
/**
 * @brief  设置一个key的删除时间 ，系统到达一定时间
 *			将会自动删除该KEY
 *
 * @param conn				已经建立好的链接
 * @param delete_time		到期事件 time_t 日历时间
 *
 * @returns   
 *		0	SUCC
 *		-1  FAIL
 */
/* -------------------------------------------*/
int rop_set_key_lifecycle(redisContext *conn, char *key, time_t delete_time)
{
	int retn = 0;
	redisReply *reply = NULL;		
	
	reply = redisCommand(conn, "EXPIREAT %s %d", key, delete_time);
	if (reply->type != REDIS_REPLY_INTEGER) {
		fprintf(stderr, "[-][GMS_REDIS]Set key:%s delete time ERROR!\n", key);
		LOG(REDIS_LOG_MODULE, REDIS_LOG_PROC, "[-][GMS_REDIS]Set key:%s delete time ERROR! %s\n", key, conn->errstr);
		retn = -1;
	}
	if (reply->integer == 1) {
		/* 成功 */
		retn = 0;
	}
	else {
		/* 错误 */
		retn = -1;
	}


	freeReplyObject(reply);	
	return retn;
}

/* -------------------------------------------*/
/**
 * @brief  打印库中所有匹配pattern的key
 *
 * @param conn		已建立好的链接
 * @param pattern	匹配模式，pattern支持glob-style的通配符格式，
 *					如 *表示任意一个或多个字符，
 *					   ?表示任意字符，
 *				    [abc]表示方括号中任意一个字母。
 */
/* -------------------------------------------*/
void rop_show_keys(redisContext *conn, char* pattern)
{
	int i = 0;
	redisReply *reply = NULL;

	reply = redisCommand(conn, "keys %s", pattern);
	if (reply->type != REDIS_REPLY_ARRAY) {
		fprintf(stderr, "[-][GMS_REDIS]show all keys and data wrong type!\n");
		LOG(REDIS_LOG_MODULE, REDIS_LOG_PROC, "[-][GMS_REDIS]show all keys and data wrong type! %s\n", conn->errstr);
		goto END;
	}

	for (i = 0; i < reply->elements; ++i) {
		printf("======[%s]======\n", reply->element[i]->str);
	}


END:
	freeReplyObject(reply);
}

/* -------------------------------------------*/
/**
 * @brief  批量执行已经封装好的redis 命令
 *
 * @param conn		已建立好的链接
 * @param cmds		封装好的命令数组
 * @param cmd_num	命令个数
 *
 * @returns   
 *			0		succ
 *			-1		FAIL
 */
/* -------------------------------------------*/
int rop_redis_append(redisContext *conn, RCOMMANDS cmds, int cmd_num)
{
	int retn = 0;
	int i = 0;
	redisReply *reply = NULL;


	/* 批量插入命令到缓冲命令管道 */
	for (i = 0; i < cmd_num; ++i) {
		retn = redisAppendCommand(conn, cmds[i]);
		if (retn != REDIS_OK) {
			fprintf(stderr, "[-][GMS_REDIS]Append Command: %s ERROR!\n", cmds[i]);
			LOG(REDIS_LOG_MODULE, REDIS_LOG_PROC, "[-][GMS_REDIS]Append Command: %s ERROR! %s\n", cmds[i], conn->errstr);
			retn = -1;
			goto END;
		}
		retn = 0;
	}

	/* 提交命令 */
	for (i = 0; i < cmd_num; ++i) {
		retn = redisGetReply(conn, (void**)&reply);
		if (retn != REDIS_OK) {
			retn = -1;
			fprintf(stderr, "[-][GMS_REDIS]Commit Command:%s ERROR!\n", cmds[i]);
			LOG(REDIS_LOG_MODULE, REDIS_LOG_PROC, "[-][GMS_REDIS]Commit Command:%s ERROR! %s\n", cmds[i], conn->errstr);
			freeReplyObject(reply);
			break;
		}
		freeReplyObject(reply);
		retn = 0;
	}
	
END:
	return retn;
}

/* -------------------------------------------*/
/**
 * @brief  执行单向命令 无返回值 命令自行输入
 *
 * @param conn		已建立的链接
 * @param cmd		封装好的命令
 *
 * @returns   
 *			0		succ
 *			-1		FAIL
 */
/* -------------------------------------------*/
int rop_redis_command(redisContext *conn, char *cmd)
{
	int retn = 0;

	redisReply *reply = NULL;

	reply = redisCommand(conn, cmd);
	if (reply == NULL) {
		LOG(REDIS_LOG_MODULE, REDIS_LOG_PROC, "[-][GMS_REDIS]Command : %s ERROR!%s\n", cmd, conn->errstr);
		retn = -1;
	}

	freeReplyObject(reply);

	return retn;
}

/* -------------------------------------------*/
/**
 * @brief  测试一个reply的结果类型
 *			得到对应的类型用对应的方法获取数据
 *
 * @param reply		返回的命令结果
 */
/* -------------------------------------------*/
void rop_test_reply_type(redisReply *reply)
{
	switch (reply->type) {
		case REDIS_REPLY_STATUS:
			LOG(REDIS_LOG_MODULE, REDIS_LOG_PROC, "[+][GMS_REDIS]=REDIS_REPLY_STATUS=[string] use reply->str to get data, reply->len get data len\n");
			break;
		case REDIS_REPLY_ERROR:
			LOG(REDIS_LOG_MODULE, REDIS_LOG_PROC, "[+][GMS_REDIS]=REDIS_REPLY_ERROR=[string] use reply->str to get data, reply->len get date len\n");
			break;
		case REDIS_REPLY_INTEGER:
			LOG(REDIS_LOG_MODULE, REDIS_LOG_PROC, "[+][GMS_REDIS]=REDIS_REPLY_INTEGER=[long long] use reply->integer to get data\n");
			break;
		case REDIS_REPLY_NIL:
			LOG(REDIS_LOG_MODULE, REDIS_LOG_PROC, "[+][GMS_REDIS]=REDIS_REPLY_NIL=[] data not exist\n");
			break;
		case REDIS_REPLY_ARRAY:
			LOG(REDIS_LOG_MODULE, REDIS_LOG_PROC, "[+][GMS_REDIS]=REDIS_REPLY_ARRAY=[array] use reply->elements to get number of data, reply->element[index] to get (struct redisReply*) Object\n");
			break;
		case REDIS_REPLY_STRING:
			LOG(REDIS_LOG_MODULE, REDIS_LOG_PROC, "[+][GMS_REDIS]=REDIS_REPLY_string=[string] use reply->str to get data, reply->len get data len\n");
			break;
		default:
			LOG(REDIS_LOG_MODULE, REDIS_LOG_PROC, "[-][GMS_REDIS]Can't parse this type\n");
			break;
	}
}


/* -------------------------------------------*/
/**
 * @brief  redis tcp模式链接
 *
 * @param ip_str	redis服务器ip
 * @param port_str	redis服务器port
 *
 * @returns   
 *			成功返回链接句柄 
 *			失败返回NULL
 */
/* -------------------------------------------*/
redisContext* rop_connectdb_nopwd(char *ip_str, char* port_str)
{
	redisContext *conn = NULL;
	uint16_t port = atoi(port_str);

	conn = redisConnect(ip_str, port);

	if (conn  == NULL) {
		LOG(REDIS_LOG_MODULE, REDIS_LOG_PROC, "[-][GMS_REDIS]Connect %s:%d Error:Can't allocate redis context!\n", ip_str, port);		
		goto END;
	}

	if (conn->err) {
		LOG(REDIS_LOG_MODULE, REDIS_LOG_PROC, "[-][GMS_REDIS]Connect %s:%d Error:%s\n", ip_str, port, conn->errstr);	
		redisFree(conn);
		conn = NULL;
		goto END;
	}
	
	LOG(REDIS_LOG_MODULE, REDIS_LOG_PROC,"[+][GMS_REDIS]Connect %s:%d SUCCESS!\n", ip_str, port);

END:
	return conn;
}


/* -------------------------------------------*/
/**
 * @brief  redis tcp模式链接
 *
 * @param ip_str	redis服务器ip
 * @param port_str	redis服务器port
 *
 * @returns   
 *			成功返回链接句柄 
 *			失败返回NULL
 */
/* -------------------------------------------*/
redisContext* rop_connectdb(char *ip_str, char* port_str, char *pwd)
{
	redisContext *conn = NULL;
	uint16_t port = atoi(port_str);
    char auth_cmd[REDIS_COMMAND_SIZE];

	conn = redisConnect(ip_str, port);

	if (conn  == NULL) {
		LOG(REDIS_LOG_MODULE, REDIS_LOG_PROC, "[-][GMS_REDIS]Connect %s:%d Error:Can't allocate redis context!\n", ip_str, port);		
		goto END;
	}

	if (conn->err) {
		LOG(REDIS_LOG_MODULE, REDIS_LOG_PROC, "[-][GMS_REDIS]Connect %s:%d Error:%s\n", ip_str, port, conn->errstr);	
		redisFree(conn);
		conn = NULL;
		goto END;
	}

    redisReply *reply = NULL;
    sprintf(auth_cmd, "auth %s", pwd);

    reply = redisCommand(conn, auth_cmd);
	if (reply == NULL) {
		LOG(REDIS_LOG_MODULE, REDIS_LOG_PROC, "[-][GMS_REDIS]Command : auth %s ERROR!\n", pwd);
        conn = NULL;
        goto END;
	}
    freeReplyObject(reply);

	
	LOG(REDIS_LOG_MODULE, REDIS_LOG_PROC,"[+][GMS_REDIS]Connect %s:%d SUCCESS!\n", ip_str, port);

END:
	return conn;
}

/* -------------------------------------------*
**
 * @brief  redis unix域模式链接
 *
 * @param ip_str	unix域sock文件
 *
 * @returns   
 *			成功返回链接句柄 
 *			失败返回NULL
 */
/* -------------------------------------------*/
redisContext* rop_connectdb_unix(char *sock_path, char *pwd)
{
	redisContext *conn = NULL;
    char auth_cmd[REDIS_COMMAND_SIZE];

	conn = redisConnectUnix(sock_path);
	if (conn  == NULL) {
		LOG(REDIS_LOG_MODULE, REDIS_LOG_PROC, "[-][GMS_REDIS]Connect domain-unix:%s Error:Can't allocate redis context!\n", sock_path);		
		goto END;
	}

	if (conn->err) {
		LOG(REDIS_LOG_MODULE, REDIS_LOG_PROC, "[-][GMS_REDIS]Connect domain-unix:%s Error:%s\n", sock_path, conn->errstr);	
		redisFree(conn);
		conn = NULL;
		goto END;
	}

    redisReply *reply = NULL;
    sprintf(auth_cmd, "auth %s", pwd);
    reply = redisCommand(conn, auth_cmd);
	if (reply == NULL) {
		LOG(REDIS_LOG_MODULE, REDIS_LOG_PROC, "[-][GMS_REDIS]Command : auth %s ERROR!\n", pwd);
        conn = NULL;
        goto END;
	}
    freeReplyObject(reply);
	
	LOG(REDIS_LOG_MODULE, REDIS_LOG_PROC,"[+][GMS_REDIS]Connect domain-unix:%s SUCCESS!\n", sock_path);

END:
	return conn;
}

/* -------------------------------------------*/
/**
 * @brief  tcp 链接redis超时等待模式，timeval链接超时
 *			返回
 *
 * @param ip_str		redis 服务器ip
 * @param port_str		redis 服务器端口
 * @param timeval		最大超时等待时间
 *
 * @returns   
 *		成功返回链接句柄
 *		失败返回NULL
 */
/* -------------------------------------------*/
redisContext* rop_connectdb_timeout(char* ip_str, char *port_str, struct timeval *timeout)
{
	redisContext *conn = NULL;
	uint16_t port = atoi(port_str);


	conn = redisConnectWithTimeout(ip_str, port, *timeout);

	if (conn  == NULL) {
		LOG(REDIS_LOG_MODULE, REDIS_LOG_PROC, "[-][GMS_REDIS]Connect %s:%d Error:Can't allocate redis context!\n", ip_str, port);
		goto END;
	}

	if (conn->err) {
		LOG(REDIS_LOG_MODULE, REDIS_LOG_PROC, "[-][GMS_REDIS]Connect %s:%d Error:%s\n", ip_str, port, conn->errstr);	
		redisFree(conn);
		conn = NULL;
		goto END;
	}
	
	LOG(REDIS_LOG_MODULE, REDIS_LOG_PROC,"[+][GMS_REDIS]Connect %s:%d SUCCESS!\n", ip_str, port);

END:
	return conn;
}

/* -------------------------------------------*/
/**
 * @brief  关闭指定的链接句柄
 *
 * @param conn	已建立好的链接
 */
/* -------------------------------------------*/
void rop_disconnect(redisContext* conn)
{
	if (conn == NULL) {
		return ;
	}
	redisFree(conn);
	
	LOG(REDIS_LOG_MODULE, REDIS_LOG_PROC,"[+][GMS_REDIS]Disconnect SUCCESS!\n");
}

/* 封装一个 hmset 命令 */
static char* make_hmset_command(char* key, unsigned int element_num, RFIELDS fields, RVALUES values)
{
	char *cmd = NULL;	
	unsigned int buf_size = 0;
	unsigned int use_size = 0;
	unsigned int i = 0;

	cmd = (char*)malloc(1024*1024);
	if (cmd == NULL) {
		goto END;
	}
	memset(cmd, 0, 1024*1024);
	buf_size += 1024*1024;

	strncat(cmd, "hmset", 6);
	use_size += 5;
	strncat(cmd, " ", 1);
	use_size += 1;

	strncat(cmd, key, 200);
	use_size += 200;

	for (i = 0; i < element_num; ++i) {

		strncat(cmd, " ", 1);
		use_size += 1;
		if (use_size >= buf_size) {
			cmd = realloc(cmd, use_size + 1024*1024);
			if (cmd == NULL) {
				goto END;
			}
			buf_size += 1024*1024;
		}

		strncat(cmd, fields[i], FIELD_ID_SIZE);
		use_size += strlen(fields[i]);
		if (use_size >= buf_size) {
			cmd = realloc(cmd, use_size + 1024*1024);
			if (cmd == NULL) {
				goto END;
			}
			buf_size += 1024*1024;
		}


		strncat(cmd, " ", 1);
		use_size += 1;
		if (use_size >= buf_size) {
			cmd = realloc(cmd, use_size + 1024*1024);
			if (cmd == NULL) {
				goto END;
			}
			buf_size += 1024*1024;
		}

		strncat(cmd, values[i], VALUES_ID_SIZE);
		use_size += strlen(values[i]);
		if (use_size >= buf_size) {
			cmd = realloc(cmd, use_size + 1024*1024);
			if (cmd == NULL) {
				goto END;
			}
			buf_size += 1024*1024;
		}

	}

END:
	return cmd;
}


/* -------------------------------------------*/
/**
 * @brief  批量执行链表插入命令 插入链表头部
 *
 * @param conn		已建立好的链接
 * @param key		链表名
 * @param values	封装好的值数组
 * @param val_num	值个数
 *
 * @returns   
 *			0		succ
 *			-1		FAIL
 */
/* -------------------------------------------*/
int rop_hash_set_append(redisContext *conn, char *key, RFIELDS fields, RVALUES values, int val_num)
{
    int retn = 0;
    int i = 0;
    redisReply *reply = NULL;

	/* 批量插入命令到缓冲命令管道 */
    for (i = 0; i < val_num; ++i) {
        retn = redisAppendCommand(conn, "hset %s %s %s", key, fields[i], values[i]);
        if (retn != REDIS_OK) {
            LOG(REDIS_LOG_MODULE, REDIS_LOG_PROC, "[-][GMS_REDIS]HSET %s %s %s ERROR![%s]\n", key, fields[i], values[i], conn->errstr);
            retn = -1;
            goto END;
        }
        retn = 0;
    }

	/* 提交命令 */
	for (i = 0; i < val_num; ++i) {
		retn = redisGetReply(conn, (void**)&reply);
		if (retn != REDIS_OK) {
			retn = -1;
			LOG(REDIS_LOG_MODULE, REDIS_LOG_PROC, "[-][GMS_REDIS]Commit HSET %s %s %s ERROR![%s]\n", key, fields[i], values[i], conn->errstr);
			freeReplyObject(reply);
			break;
		}
		freeReplyObject(reply);
		retn = 0;
	}
	
END:
	return retn;
}


/* -------------------------------------------*/
/**
 * @brief			创建或者覆盖一个HASH表
 *
 * @param conn				已建立好的链接
 * @param key				hash 表名
 * @param element_num		hash 表区域个数
 * @param fields			hash 表区域名称数组char(*)[FIELD_ID_SIZE]
 * @param values			hash 表区域值数组  char(*)[VALUES_ID_SIZE]
 *
 * @returns   
 *			0   成功	
 *			-1  失败
 */
/* -------------------------------------------*/
int rop_create_or_replace_hash_table(redisContext* conn,
									 char* key, 
									 unsigned int element_num, 
									 RFIELDS fields, 
									 RVALUES values)
{
	int retn = 0;
	redisReply *reply = NULL;			

	char *cmd = make_hmset_command(key, element_num, fields, values);		
	if (cmd == NULL) {
		LOG(REDIS_LOG_MODULE, REDIS_LOG_PROC, "[-][GMS_REDIS]create hash table %s error\n", key);
		retn = -1;
		goto END_WITHOUT_FREE;
	}

	reply = redisCommand(conn, cmd);
//	rop_test_reply_type(reply);
	if (strcmp(reply->str, "OK") != 0) {
		LOG(REDIS_LOG_MODULE, REDIS_LOG_PROC, "[-][GMS_REDIS]Create hash table %s Error:%s,%s\n", key, reply->str, conn->errstr);
		
		retn = -1;
		goto END;
	}


END:
	free(cmd);
	freeReplyObject(reply);

END_WITHOUT_FREE:

	return retn;
}

/* -------------------------------------------*/
/**
 * @brief  给指定的hash表 指定的field对应的value自增num
 *
 * @param conn			已建立好的链接
 * @param key			hash表名
 * @param field			hash表下的区域名	
 *
 * @returns   
 *			0		succ
 *			-1		fail
 */
/* -------------------------------------------*/
int rop_hincrement_one_field(redisContext *conn, char *key, char *field, unsigned int num)
{
	int retn = 0;

	redisReply *reply = NULL;

	reply = redisCommand(conn, "HINCRBY %s %s %d", key, field, num);
	if (reply == NULL) {
		LOG(REDIS_LOG_MODULE, REDIS_LOG_PROC, "[-][GMS_REDIS]increment %s %s error %s\n", key, field, conn->errstr);	
		retn =  -1;
		goto END;
	}

END:
	freeReplyObject(reply);

	return retn;
}


/* -------------------------------------------*/
/**
 * @brief  批量执行链表插入命令 插入链表头部
 *
 * @param conn		已建立好的链接
 * @param key		链表名
 * @param values	封装好的值数组
 * @param val_num	值个数
 *
 * @returns   
 *			0		succ
 *			-1		FAIL
 */
/* -------------------------------------------*/
int rop_list_push_append(redisContext *conn, char *key, RVALUES values, int val_num)
{
	int retn = 0;
	int i = 0;
	redisReply *reply = NULL;


	/* 批量插入命令到缓冲命令管道 */
	for (i = 0; i < val_num; ++i) {
		retn = redisAppendCommand(conn, "lpush %s %s", key, values[i]);
		if (retn != REDIS_OK) {
			LOG(REDIS_LOG_MODULE, REDIS_LOG_PROC, "[-][GMS_REDIS]PLUSH %s %s ERROR! %s\n", key, values[i], conn->errstr);
			retn = -1;
			goto END;
		}
		retn = 0;
	}

	/* 提交命令 */
	for (i = 0; i < val_num; ++i) {
		retn = redisGetReply(conn, (void**)&reply);
		if (retn != REDIS_OK) {
			retn = -1;
			LOG(REDIS_LOG_MODULE, REDIS_LOG_PROC, "[-][GMS_REDIS]Commit LPUSH %s %s ERROR! %s\n", key, values[i], conn->errstr);
			freeReplyObject(reply);
			break;
		}
		freeReplyObject(reply);
		retn = 0;
	}
	
END:
	return retn;
}

/* -------------------------------------------*/
/**
 * @brief  单条数据插入链表
 *
 * @param conn		已建立好的链接
 * @param key		链表名
 * @param value		数据
 *
 * @returns   
 */
/* -------------------------------------------*/
int rop_list_push(redisContext *conn, char *key, char *value)
{
	int retn = 0;
	redisReply *reply = NULL;

	reply = redisCommand(conn, "LPUSH %s %s", key, value);
	//rop_test_reply_type(reply);	
	if (reply->type != REDIS_REPLY_INTEGER) {
		LOG(REDIS_LOG_MODULE, REDIS_LOG_PROC, "[-][GMS_REDIS]LPUSH %s %s error!%s\n", key, value, conn->errstr);
		retn = -1;
	}

	freeReplyObject(reply);
	return retn;
}

/* -------------------------------------------*/
/**
 * @brief  得到链表中元素的个数
 *
 * @param conn	链接句柄
 * @param key	链表名
 *
 * @returns   
 *			>=0 个数
 *			-1 fail
 */
/* -------------------------------------------*/
int rop_get_list_cnt(redisContext *conn, char *key)
{
	int cnt = 0;

	redisReply *reply = NULL;

	reply = redisCommand(conn, "LLEN %s", key);
	if (reply->type != REDIS_REPLY_INTEGER) {
		LOG(REDIS_LOG_MODULE, REDIS_LOG_PROC, "[-][GMS_REDIS]LLEN %s error %s\n", key, conn->errstr);
		cnt = -1;
		goto END;
	}

	cnt = reply->integer;

END:
	freeReplyObject(reply);
	return cnt;
}


/* -------------------------------------------*/
/**
 * @brief  按照一定范围截断链表中的数据
 *
 * @param conn		已经建立的链接
 * @param key		链表名
 * @param begin		阶段启示位置 从 0 开始
 * @param end		阶段结束位置 从 -1 开始
 *
 *					这里的范围定义举例 
 *					如果得到全部范围(0, -1)
 *					除了最后一个元素范围(0, -2)
 *					前20各数据范围(0, 19)
 *
 * @returns   
 *			0  SUCC
 *			-1 FAIL
 */
/* -------------------------------------------*/
int rop_trim_list(redisContext *conn, char *key, int begin, int end)
{
	int retn = 0;
	redisReply *reply = NULL;

	reply = redisCommand(conn, "LTRIM %s %d %d", key, begin, end);
	if (reply->type != REDIS_REPLY_STATUS) {
		LOG(REDIS_LOG_MODULE, REDIS_LOG_PROC, "[-][GMS_REDIS]LTRIM %s %d %d error!%s\n", key, begin, end, conn->errstr);
		retn = -1;
	}

	freeReplyObject(reply);
	return retn;
}


/* -------------------------------------------*/
/**
 * @brief  rop_range_list 得到链表中的数据
 *
 *          返回数据为 区间为
 *              [from_pos, end_pos)
 *
 * @param conn
 * @param key       表名
 * @param from_pos  查找表的起始数据下标
 * @param end_pos   查找表的结尾数据下标
 * @param values    得到表中的value数据
 * @param get_num   得到结果value的个数
 *
 * @returns   
 *      0 succ, -1 fail
 */
/* -------------------------------------------*/
int rop_range_list(redisContext *conn, char *key, int from_pos, int end_pos, RVALUES values, int *get_num)
{
    int retn = 0;
    int i = 0;
    redisReply *reply = NULL;
    int max_count = 0;

    int count = end_pos - from_pos + 1;

    reply = redisCommand(conn, "LRANGE %s %d %d", key, from_pos, end_pos);
//    rop_test_reply_type(reply);
	if (reply->type != REDIS_REPLY_ARRAY) {
		LOG(REDIS_LOG_MODULE, REDIS_LOG_PROC, "[-][GMS_REDIS]LRANGE %s  error!%s\n", key, conn->errstr);
		retn = -1;
	}


    max_count = (reply->elements > count) ? count: reply->elements;
    *get_num = max_count;


    for (i = 0; i < max_count; ++i) {
        strncpy(values[i], reply->element[i]->str, VALUES_ID_SIZE-1);
    }

	freeReplyObject(reply);
	return retn;
}

/* -------------------------------------------*/
/**
 * @brief		将指定的zset表，对应的成员，值自增1
 *				（key 或 成员不存在 则创建）
 *
 * @param conn		已建立的链接
 * @param key		zset表名
 * @param member	zset成员名
 *
 * @returns   
 *			0			succ
 *			-1			fail
 */
/* -------------------------------------------*/
int rop_zset_increment(redisContext *conn, char* key, char* member)
{
	int retn = 0;	

	redisReply *reply = NULL;

	reply = redisCommand(conn, "ZINCRBY %s 1 %s", key, member);
	//rop_test_reply_type(reply);
	if (strcmp(reply->str, "OK") != 0) {
		LOG(REDIS_LOG_MODULE, REDIS_LOG_PROC, "[-][GMS_REDIS]Add or increment table: %s,member: %s Error:%s,%s\n", key, member,reply->str, conn->errstr);
		
		retn = -1;
		goto END;
	}

END:
	freeReplyObject(reply);
	return retn;
}

/* -------------------------------------------*/
/**
 * @brief	 批量将指定的zset表，对应的成员，值自增1
 *				（key 或 成员不存在 则创建）
 *
 * @param conn		已建立好的链接
 * @param key		有序集合名称
 * @param values	封装好的成员数组
 * @param val_num	数据个数
 *
 * @returns   
 *			0		succ
 *			-1		FAIL
 */
/* -------------------------------------------*/
int rop_zset_increment_append(redisContext *conn, char *key, RVALUES values, int val_num)
{
	int retn = 0;
	int i = 0;
	redisReply *reply = NULL;

	/* 批量命令到缓冲管道 */
	for (i = 0; i < val_num; ++i) {
		retn = redisAppendCommand(conn, "ZINCRBY %s 1 %s", key, values[i]);
		if (retn != REDIS_OK) {
			LOG(REDIS_LOG_MODULE, REDIS_LOG_PROC, "[-][GMS_REDIS]ZINCRBY %s 1 %s ERROR! %s\n", key, values[i], conn->errstr);
			retn = -1;
			goto END;
		}
		retn = 0;
	}

	/* 提交命令 */
	for (i = 0; i < val_num; ++i) {
		retn = redisGetReply(conn, (void**)&reply);
		if (retn != REDIS_OK) {
			retn = -1;
			LOG(REDIS_LOG_MODULE, REDIS_LOG_PROC, "[-][GMS_REDIS]Commit ZINCRBY %s 1 %s ERROR!%s\n", key, values[i], conn->errstr);
			freeReplyObject(reply);
			break;
		}
		freeReplyObject(reply);
		retn = 0;
	}

END: 
	return retn;
}

int rop_zset_get_score(redisContext *conn, char *key, char *member)
{
	int score = 0;

	redisReply *reply = NULL;

	reply = redisCommand(conn, "ZSCORE %s %s", key, member);
    rop_test_reply_type(reply);
    
	if (reply->type != REDIS_REPLY_STRING) {
		LOG(REDIS_LOG_MODULE, REDIS_LOG_PROC, "[-][GMS_REDIS]ZSCORE %s %s error %s\n", key, member,conn->errstr);
        score = -1;
		goto END;
	}

    score = atoi(reply->str);


END:
	freeReplyObject(reply);

	return score;
}

int rop_hash_set(redisContext* conn, const char *key, const char *field, const char *value)
{
	int retn = 0;	

	redisReply *reply = NULL;

	reply = redisCommand(conn, "HSET %s %s %s", key, field, value);
	if (reply == NULL) {
		LOG(REDIS_LOG_MODULE, REDIS_LOG_PROC, "[-][GMS_REDIS]hset error : key: %s, field:%s, value:%s, Error:%s\n", key, field, value, conn->errstr);
		retn = -1;
		goto END;
	}

END:
	freeReplyObject(reply);
	return retn;
}

int rop_hash_get(redisContext *conn, const char *key, const char *field, char *value)
{
	int retn = 0;	

	redisReply *reply = NULL;

	reply = redisCommand(conn, "HGET %s %s", key, field);
	if (reply == NULL) {
		LOG(REDIS_LOG_MODULE, REDIS_LOG_PROC, "[-][GMS_REDIS]hget error : key: %s, field:%s Error:%s\n", key, field,conn->errstr);
		retn = -1;
		goto END;
	}

    strncpy(value, reply->str, VALUES_ID_SIZE);

END:
	freeReplyObject(reply);
	return retn;
}

int rop_get_string(redisContext *conn, const char* key, char *value)
{
	int retn = 0;	

	redisReply *reply = NULL;

	reply = redisCommand(conn, "GET %s", key);
	if (reply == NULL) {
		LOG(REDIS_LOG_MODULE, REDIS_LOG_PROC, "[-][GMS_REDIS]get string : key: %s Error:%s\n", key, conn->errstr);
		retn = -1;
		goto END;
	}

    strncpy(value, reply->str, VALUES_ID_SIZE);

END:
	freeReplyObject(reply);
	return retn;
}

int rop_set_string(redisContext*conn, const char *key, const char *value)
{
	int retn = 0;	

	redisReply *reply = NULL;

	reply = redisCommand(conn, "SET %s %s", key, value);
	if (reply == NULL) {
		LOG(REDIS_LOG_MODULE, REDIS_LOG_PROC, "[-][GMS_REDIS]set string : %s,key: %s Error:%s,%s\n", key, value,reply->str, conn->errstr);
		retn = -1;
		goto END;
	}


END:
	freeReplyObject(reply);
	return retn;
}
