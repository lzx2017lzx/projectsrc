#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <pthread.h>
#include <sys/wait.h>

#include "fdfs_api.h"
#include "make_log.h"

#define LOG_MOUDLE "api"
#define LOG_PROC   "fdfs"

#include "fdfs_client.h"

/* -------------------------------------------*/
/**
 * @brief  上传fastdfs接口
 *
 * @param filename in 文件路径
 * @param fileid out 得到的文件id 
 *
 * @returns  0 succ, -1 fail 
 */
/* -------------------------------------------*/
int fdfs_upload_by_filename1(char *filename, char *fileid)
{
	char *conf_filename;
	char *local_filename;
	char group_name[FDFS_GROUP_NAME_MAX_LEN + 1];
	ConnectionInfo *pTrackerServer;
	int result;
	int store_path_index;
	ConnectionInfo storageServer;
	

	//log_init();
	//g_log_context.log_level = LOG_ERR;
	ignore_signal_pipe();

	conf_filename = FDFS_CLIENT_CONF;
    //初始化配置文件
	if ((result=fdfs_client_init(conf_filename)) != 0)
	{
		return result;
	}

    //得到tracker的句柄
	pTrackerServer = tracker_get_connection();
	if (pTrackerServer == NULL)
	{
		fdfs_client_destroy();
		return errno != 0 ? errno : ECONNREFUSED;
	}

	local_filename = filename;
	*group_name = '\0';
    //通过tracker得到storage句柄
	if ((result=tracker_query_storage_store(pTrackerServer, \
	                &storageServer, group_name, &store_path_index)) != 0)
	{
		fdfs_client_destroy();
		fprintf(stderr, "tracker_query_storage fail, " \
			"error no: %d, error info: %s\n", \
			result, STRERROR(result));
		return result;
	}

    //上传文件到storage中
	result = storage_upload_by_filename1(pTrackerServer, \
			&storageServer, store_path_index, \
			local_filename, NULL, \
			NULL, 0, group_name, fileid);
	if (result == 0)
	{
		LOG(LOG_MOUDLE, LOG_PROC, "%s\n", fileid);
	}
	else
	{
		fprintf(stderr, "upload file fail, " \
			"error no: %d, error info: %s\n", \
			result, STRERROR(result));
	}

    //销毁资源
	tracker_disconnect_server_ex(pTrackerServer, true);
	fdfs_client_destroy();

	return result;
}

int fdfs_upload_by_filename(char *filename, char * fileid)
{
    int ret = 0;
    int pfd[2];
    pid_t pid;

    ret = pipe(pfd);
    if (ret != 0) {
        LOG(LOG_MOUDLE, LOG_PROC, "pipe error");
        return -1;
    }


    pid = fork();
    if (pid < 0) {
        LOG(LOG_MOUDLE, LOG_PROC, "fork error");
        return -1;
    }
    else if (pid == 0){
        //child

        //close pfd[0]
        close(pfd[0]);

        //dup2 stdout->pfd[1]
        dup2(pfd[1], STDOUT_FILENO);

        //exec 
        execlp("fdfs_upload_file", "fdfs_upload_file", "/etc/fdfs/client.conf", filename, NULL);
        LOG(LOG_MOUDLE, LOG_PROC, "exec fdfs_upload_file error\n");
        return -1;
    }
    else {
        //parent

        //close pfd[1]
        close(pfd[1]);

        //wait
        wait(NULL);

        //read pfd[0] --> fileid
        read(pfd[0], fileid, FILE_ID_LEN);

        int len = strlen(fileid);

        fileid[len-1] = '\0';

        close(pfd[0]);
    }
    

    return 0;
}
