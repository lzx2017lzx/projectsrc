#ifndef __UTIL_H__
#define __UTIL_H__

int get_file_suffix(const char *file_name, char *suffix);

char* memstr(char* full_data, int full_data_len, char* substr);

/**
 * @brief  解析url query 类似 abc=123&bbb=456 字符串
 *          传入一个key,得到相应的value
 * @returns   
 *          0 成功, -1 失败
 */
int query_parse_key_value(const char *query, const char *key, char *value, int *value_len_p);

void str_replace(char* strSrc, char* strFind, char* strReplace);

#endif
