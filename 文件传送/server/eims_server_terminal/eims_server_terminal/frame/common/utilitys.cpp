#include "utilitys.h"

pthread_mutex_t CUtilitys::log_lock;

CUtilitys::CUtilitys()
{
    ;
}
CUtilitys::~CUtilitys()
{
    ;
}

string CUtilitys::get_verify_code(void)
{
    char code[7] = "      ";
    char character[11] = "0123456789";

    // srand((unsigned int)time(NULL));
    // main.cpp 中已经初始化随机种子

    for (int i = 0; i < 6; i++)
    {
        code[i] = character[rand() % 10];
    }

    string Result;
    Result = code;

    return Result;
}

string CUtilitys::get_random_string(int len)
{
	char code[len];
    char character[11] = "0123456789";

    // srand((unsigned int)time(NULL));
    // main.cpp 中已经初始化随机种子

    for (int i = 0; i < len; i++)
    {
        code[i] = character[rand() % 10];
    }

    string Result;
    Result = code;

    return Result;
}

string CUtilitys::get_random_sequence(void)
{
    // main.cpp 中已经初始化随机种子

    int num = rand()%9999;

    struct tm *p;
    time_t second;
    time(&second);

    p = localtime(&second);
    char buf[20] = {0};
    sprintf(buf, "%d%02d%02d%02d%02d%02d%04d", 1900+p->tm_year, 1+p->tm_mon, p->tm_mday,
            p->tm_hour, p->tm_min, p->tm_sec, num);

    string str;
    int i = 0;

    while(buf[i])
    {
        str += buf[i++];
    }

    return utility::MD5(str, SYSTEM_KEY);
}

/*
*   @data 2013-04-20
*   @description 注册EIMS ID 是否靓号
*/
bool CUtilitys::is_beautiful(bigint eims_id)
{
    short n1 = (eims_id / 10000);
    short n2 = (eims_id / 1000) % 10;
    short n3 = (eims_id / 100) % 10;
    short n4 = (eims_id / 10) % 10;
    short n5 = eims_id % 10;
    // 顺号 >= 4
    if((n1+1) == n2 &&
            (n1+2) == n3 &&
            (n1+3) == n4)
    {
        return true;
    }
    if((n2+1) == n3 &&
            (n2+2) == n4 &&
            (n2+3) == n5)
    {
        return true;
    }
    // 叠号 >= 3
    if(n1 == n2 &&
            n1 == n3)
    {
        return true;
    }
    if(n2 == n3 &&
            n2 == n4)
    {
        return true;
    }
    if(n3 == n4 &&
            n4 == n5)
    {
        return true;
    }
    // 双叠
    if(n1 == n2 &&
            n4 == n5)
    {
        return true;
    }
    if(n2 == n3 &&
            n4 == n5)
    {
        return true;
    }
    return false;
}
string CUtilitys::print_cur_systemtime(string label, bool b_print)
{
    struct timeval tv;
    gettimeofday(&tv,NULL);
    printf("%s", label.c_str());
    printf(" :%ld\n",tv.tv_sec * 1000 + tv.tv_usec / 1000);
    return "";
}

string CUtilitys::MD5(string input)
{
	return utility::MD5(input);
}
string CUtilitys::MD5(char* input)
{
	return utility::MD5(input);
}
string CUtilitys::MD5(char* input, char* key)
{
	return utility::MD5(input, key);
}
string CUtilitys::MD5(string input, string key)
{
	return utility::MD5(input, key);
}

string CUtilitys::get_time_stamp()
{
	struct timeval tv;
	gettimeofday(&tv,NULL);
	unsigned long int t_now = tv.tv_sec * 1000 + tv.tv_usec / 1000;
	stringstream ss;
	ss<<t_now;
	string ret = "";
	ss>>ret;
	return ret;
}

