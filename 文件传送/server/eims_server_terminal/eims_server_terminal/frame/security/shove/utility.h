#ifndef SHOVE_UTILITY_H
#define SHOVE_UTILITY_H

#include <stdio.h>
#include <string>
#include <time.h>
#include <zlib.h>
#include <iostream>
#include <fstream>

#include "security/md5.h"
#include "security/ses.h"
#include "convert.h"
#include <linux/unistd.h>     /* 包含调用 _syscallX 宏等相关信息*/
#include <linux/kernel.h>     /* 包含sysinfo结构体信息*/

using namespace shove::security;


namespace shove
{
    static md5 _md5;
    static ses _ses;
	//_syscall1(int, sysinfo, struct sysinfo*, info);
    class utility
    {

    public:

        static char* str_trim(char* pStr);
        static char* str_trim_quote(char* pStr);

        static string string_ltrim(string Source);
        static string string_rtrim(string Source);
        static string string_trim(string Source);

        static string MD5(string input);
        static string MD5(char* input);
        static string MD5(char* input, char* key);
        static string MD5(string input, string key);

        static string SES_Encrypt(string input, string key);
        static string SES_Decrypt(string input, string key);

        static unsigned char* compress_string(unsigned char* input, unsigned long input_len, unsigned long* output_len);
        static unsigned char* uncompress_string(unsigned char* input, unsigned long input_len, unsigned long* output_len);

        static void WriteLog(string filename, string log);

        static void PrintSystemInfo();
    };
}

#endif // SHOVE_UTILITY_H
