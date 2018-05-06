#ifndef META_H_INCLUDED
#define META_H_INCLUDED
#include <sstream>
#include "utilitys.h"

using namespace std;
namespace eims
{
	namespace meta
	{
		///在线用户所需要的信息
		struct onlineuser
		{
			///用户ID
			string userid;
			///加密密钥
			string secretKey;
			///平台
			int platform;
			///状态
			int state;
			///最近活跃时间
			struct timeval last_active_time;
		};

		///获取指定位数的随机码
		extern string get_rand_num(int nlen);

		///获取版本号（已作废）
		extern string get_data_version();

		///获取指定串的MD5值
		extern string get_md5(string src);

		///获取格林威制时间序列
		extern long long get_data_sequence();

		///生成DES加密的24位密钥
		extern string gen_des_key();

		///long long 转换成string
		extern string longlong2str(long long src);

		///string 转换成long long
		extern long long str2longlong(string src);

		///判断字符串是否全是数字组成
		extern bool allisnum(string s);

		///重新设置字符串长度
		extern void resize(char* src, size_t new_size);
	}
}

#endif // META_H_INCLUDED
