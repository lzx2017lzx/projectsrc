#ifndef TOOLS_H
#define TOOLS_H

#include <stdlib.h>
#include <sys/time.h>
#include <string>
#include "utilitys.h"
#include "global.h"
#include "consts.h"

using namespace std;
using namespace eims::global;

namespace eims
{
	namespace tool
	{
		/// //////////////////////////////////////////////////////////
		///
		///	工具类主要是提供给LUA使用的，由于LUA的某些功能限制，只有C＋＋才能
		///	实现的功能需要在这里实现，然后开放给LUA。追求性能的功能也可以在这
		///	里实现，然后开放给LUA
		///
		/// //////////////////////////////////////////////////////////
		class Tools
		{
			public:
				Tools();
				~Tools();

				///将密码进行MD5加密处理
				string handlePassword(string pwd);
				///获取当前时间戳
				string get_cur_time_stamp();
				///获取格林威治时间序列
				string get_data_seq();
				///获取指定位数的随机串
				string get_rand_num(int nlen);
				///生成des加密密钥
				string get_des_key();

				int GET_DATA_COUNT;
				int GET_USER_MSG;
				int GET_NOTIFY;
				int GET_APPLICATIONS_NOTIFY;
				int GET_ALL_SITES;
				int GET_ALL_SITES_USINT;
				int GET_APPLICATIONS;
				int GET_CONTROL_TYPES;
				int GET_NOTIFY_TYPES;
				int GET_CONTROLS;
				int GET_TRADE_TYPES;
				int GET_PROVINCES;
				int GET_CITYS;
				int GET_AREAS;
				int UPDATE_GET_USINGS;
	};
}
}
#endif // TOOLS_H
