#ifndef EIMS_MESSAGE_H
#define EIMS_MESSAGE_H

#include <iostream>
#include <fstream>

#include "../../frame/security/shove/utility.h"
#include "../../frame/common/utilitys.h"

using namespace shove;

namespace eims
{
	namespace protocols
	{
		///请求对话信息的前三个字节标记
		const char MessagePreFix[3] = { 0x01, 0x02, 0x03 };
		///客户端标识的长度
		const unsigned int ClientIDLength = 12;
		///错误消息
		static string error_message = "<msg><id>0</id><ver>0</ver><ic>0</ic><sn>0</sn><el>1</el><dt><ed>服务器响应请求失败</ed></dt></msg>";
		///接收的消息的最大长度
		static const size_t MessageMaxLength = 100000;

		///消息处理类
		class CMessage
		{
			public:
				virtual ~CMessage(){ };
			protected:
				///加密回复消息
				//virtual char* format_return_message(string& messagecontent, unsigned int contentlen, size_t* retlen) = 0;
		};
	}
}
#endif
