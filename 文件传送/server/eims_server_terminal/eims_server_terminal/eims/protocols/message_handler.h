#ifndef EIMS_HANDLEMESSAGE_H
#define EIMS_HANDLEMESSAGE_H

#include <iostream>
#include <fstream>

#include "message.h"
#include "../../frame/security/ecc_encry.h"
#include "../../frame/common/common.h"
#include "../../frame/db/db_oper.h"

#define CHECKPOINT(p) if(p == NULL){ return NULL;}

using namespace eims::lua;
using namespace eims::common;
using namespace eims::tool;

namespace eims
{
	namespace protocols
	{
		///消息处理入口类
		class CHandleMessage : public CMessage
		{
		public:
			///构造
			CHandleMessage();
			///析构
			~CHandleMessage();
			///消息处理主循环
			char* handle_message(char* input, size_t len, size_t* result_len, string ip);

		private:

			///错误原因
			string m_err_reson;
			///LUA虚拟机
			lua_oper *m_lua_oper_;
			///ses加密对象
			shove::security::ses* m_local_ses_;
			/// ECC加密对象
			ecc_encry m_ecc_;


		private:

			///生成与客户端的对话信息
			char* general_client_info(char* msg, size_t len, size_t* outlen);
			///将返回消息加密
			char* format_return_message(string& messagecontent, unsigned int contentlen, size_t* retlen);
			///存储客户端ID及加密密钥到DB
			bool cache_user_info(string cid, string key);
			///获取DB中客户端ses加密密钥
			string get_user_des_key(string cid);
		};
	}
}
#endif
