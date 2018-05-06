#ifndef __FDFS_API_H__
#define __FDFS_API_H__

#define FILE_ID_LEN  128

#define FDFS_CLIENT_CONF "./conf/client.conf"

int fdfs_upload_by_filename(char *filename, char * fileid);
int fdfs_upload_by_filename1(char *filename, char * fileid);
#endif
