#ifndef EIMS_UTILITYS_H
#define EIMS_UTILITYS_H

#include <string>
#include <time.h>
#include <iostream>
#include <stdlib.h>
#include <stdio.h>

#include <sys/time.h>

//#include <Utility.h>
#include "../../frame/security/shove/utility.h"
//#include <security/ses.h>
#include "../../frame/security/shove/security/ses.h"
#include "consts.h"

using namespace shove;

static const string SYSTEM_KEY = "qwertyu1qwertyu3qwertyu6";

class CUtilitys
{
	///日志锁
    static pthread_mutex_t log_lock;

public:

    CUtilitys();
    ~CUtilitys();

	///获取校验码
    static string get_verify_code(void);

    ///获取指定位数的随机安串
    static string get_random_string(int len);

    ///获取随机序列
    static string get_random_sequence(void);

    ///判断ID是否是靓号
    static bool is_beautiful(bigint eims_id);

    ///打印当前时间（调试用）
    static string print_cur_systemtime(string label, bool b_print);

	///以下四个方法均是生成MD值的不同方式
    static string MD5(string input);
    static string MD5(char* input);
    static string MD5(char* input, char* key);
    static string MD5(string input, string key);

	///获取格林威治时间戳
    static string get_time_stamp();
};

#endif
