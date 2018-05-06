#include "meta.h"

namespace eims{
namespace meta{
string get_rand_num(int nlen)
{
	char* code = new char[nlen + 1];
	if(code == NULL)
	{
		return "";
	}
	code[nlen] = '\0';
    char character[11] = "0123456789";

    for (int i = 0; i < nlen; i++)
    {
        code[i] = character[rand() % 10];
    }

    string Result = "";
    Result.append(code);
	delete []code;
    return Result;
}
string get_data_version()
{
	return "";
}

// 获取最新版本流水号(用时间刻度代替的序列)
long long get_data_sequence()
{
	timeval tv;
	gettimeofday(&tv, NULL);

	long long result = (long long)(tv.tv_sec - 1261440000) * (long long)1000000 + tv.tv_usec;

	return result;
}

string get_md5(string src)
{
	return CUtilitys::MD5(src);
}

string gen_des_key()
{
    string randn = get_rand_num(10);
    string firstmd5 = get_md5(randn);
    string first12chars = firstmd5.substr(0, 12);
    string secondmd5 = get_md5(first12chars);
    string second12chars = secondmd5.substr(0, 12);
    string ret = first12chars + second12chars;
    return ret;
}
stringstream meta_ss;
string longlong2str(long long src)
{
	meta_ss.clear();
	meta_ss<<src;
	string temp("");
	meta_ss>>temp;
	return temp;
}
long long str2longlong(string src)
{
	meta_ss.clear();
	meta_ss<<src;
	long long sr = 0;
	meta_ss>>sr;
	return sr;
}
bool allisnum(string s)
{
	for(unsigned int i = 0; i < s.length(); i++)
	{
		if ((s.at(i) > '9') || (s.at(i) < '0'))
			return false;
	}
	return true;
}

void resize(char* src, size_t new_size)
{
	if(!src) delete[] src; src = NULL;
	src = new char[new_size];
	memset(src, 0x0, new_size);
	return ;
}
}
}
