#ifndef __UPLOAD_FILE_H__
#define __UPLOAD_FILE_H__

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
#define FILEID_TYPE_HASH "FILEID_TYPE_HASH"
#define FILEID_URL_HASH "FILEID_URL_HASH"
#define FILEID_SHARED_STATUS_HASH "FILEID_SHARED_STATUS_HASH"

#define TIME_STR_MAX (256)
#define FILE_URL_LEN (256)
#define STORAGE_IP "192.168.19.27"

int save_one_file(char *filename);

/* -------------------------------------------*/
/**
 * @brief  select_files 
 *
 * @param fromId IN 查询文件的起始下标
 * @param count IN 文件个数
 * @param out OUT 得到返回前端的json字符串
 *
 * @returns   
 *   0 succ, -1 fail
 */
/* -------------------------------------------*/
int select_files(int fromId, int count, char **out);

#endif
