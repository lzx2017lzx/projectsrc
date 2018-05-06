#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <pthread.h>

#include "fdfs_api.h"
#include "make_log.h"


#define LOG_MODULE "dstorage"
#define LOG_PROC    "main"


int main(int argc, char *argv[])
{
    int ret = 0;
    char * filename = "/home/itcast/aa.cpp";
    char fileid[FILE_ID_LEN] = {0};

    ret = fdfs_upload_by_filename1(filename, fileid);
    if (ret != 0) {
        printf("upload %s error \n", filename);
        LOG(LOG_MODULE, LOG_PROC, "upload %s error \n", filename);
        exit(1);
    }

    printf("fileid = [%s]\n", fileid);
    LOG(LOG_MODULE, LOG_PROC, "fileid=[%s]", fileid);

	return 0;
}
