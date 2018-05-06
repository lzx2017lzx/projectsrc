#include "message_handler.h"

namespace eims
{
	namespace protocols
	{
		///构造
		CHandleMessage::CHandleMessage()
		{
			m_lua_oper_ = NULL;
			//m_local_ses_ = new shove::security::ses();
		}

		///析构
		CHandleMessage::~CHandleMessage()
		{
			if(m_lua_oper_ != NULL)
				m_lua_oper_->clear();
		}

		///消息处理主循环
		char* CHandleMessage::handle_message(char* input, size_t len, size_t* result_len, string ip)
		{
			/////////////////////////////////////////////////////////////
			//	将消息解释，并调用LUA脚本来处理业务逻辑
			if(input == NULL)
			{
				Global::logger->write_log("input data is null", eLogLv.WARN);
				return NULL;
			}

			//请求对称密钥的命令
			if ((MessagePreFix[0] == input[0]) && (MessagePreFix[1] == input[1]) && (MessagePreFix[2] == input[2]))
			{
				//input 在消息发送回客户端时 释放掉
				return general_client_info(input, len, result_len);
			}

			//客户端发来的消息必须有明文的客户端标识号
			//消息在此进行，解包，解密，获取XML数据
			//包的前部N(ClientIDLength)个字节表示客户端的标识
			//后面的全部字节均是消息体内容

			string cl_id(input, ClientIDLength);
			string key("");
			if(allisnum(cl_id))
			{
				key = get_user_des_key(cl_id);
			}
			else
			{
				//用户标识不是全数字，认为是非法访问。直接关闭客户端。
				Global::logger->write_log("a illegal access was dennied." + cl_id, eLogLv.INFO);
				return NULL;
			}
			if(!key.compare(""))
			{
				//找不到用户对应的解码密钥，认为是非法访问。直接关闭客户端。
				Global::logger->write_log("user's des key not found.", eLogLv.INFO);
				return NULL;
			}

			char * orig_data = input + ClientIDLength;
			unsigned long pid = pthread_self();
			m_local_ses_ = Common::ses_oper_grab(pid);

			//获得key后，解密消息
			m_local_ses_->set_key(key.c_str());
			//printf("key is %s\n", key.c_str());
			int decrypt_length = len - ClientIDLength;
			char * decrypt_result = new char[decrypt_length];
			CHECKPOINT(decrypt_result)
			try
			{
				m_local_ses_->Decrypt(orig_data, decrypt_result, len - ClientIDLength, &decrypt_length);
			}
			catch(const std::exception& e)
			{
				*result_len = 0;
				Global::logger->write_log("3des decrypt failed." + (string)e.what(), eLogLv.FATAL);
				return NULL;
			}
			if(decrypt_length < 0)
			{
				*result_len = 0;
				Global::logger->write_log("3des decrypt failed.", eLogLv.FATAL);
				return NULL;
			}

			string xml_result_data(decrypt_result, decrypt_length);
			delete[] decrypt_result;
			//获取到LUA虚拟机
			m_lua_oper_ = Common::lua_vm_grab(pid);
			CHECKPOINT(m_lua_oper_)

			//调用LUA脚本完成业务逻辑
			TArgPool args;
			args.AddArg(xml_result_data);
			args.AddArg(cl_id);
			args.AddArg(ip);
			string result("");
			Global::logger->write_log("logic lua start running.", eLogLv.DEBUG);
			if(m_lua_oper_->call_lua_func(SCRIPT_ENTRANCE_FUNC.c_str(), args) != CALL_OK)
			{
				Global::logger->write_log(m_lua_oper_->m_err_desc, eLogLv.FATAL);
				result = error_message;
			}
			else
			{
				//获取返回值
				m_lua_oper_->get_return_value(result);
				result = result.compare("") == 0 ? error_message : result;
				Global::logger->write_log("logic lua run finished.", eLogLv.DEBUG);
			}
			m_lua_oper_->clear();
			//Global::logger->write_log("return to client message1 is :", eLogLv.DEBUG);
			//Global::logger->write_log(result, eLogLv.DEBUG);
			char* r = format_return_message(result, result.length(), result_len);
			//string s(r, *result_len);
			//Global::logger->write_log("return to client message2 is :", eLogLv.DEBUG);
			//Global::logger->write_log(s, eLogLv.DEBUG);
			return r;
		}

		///将返回消息进行加密处理
		char* CHandleMessage::format_return_message(string& messagecontent, unsigned int contentlen, size_t* retlen)
		{
			if(!retlen)
				return NULL;
			//加密消息
			char* ctx = new char[contentlen];
			CHECKPOINT(ctx)
			memcpy(ctx, messagecontent.c_str(), contentlen);
			unsigned int final_len = 0;
			try
			{
				final_len = m_local_ses_->GetEncryptResultLength(ctx, contentlen);
			}
			catch(const std::exception& e)
			{
				*retlen = 0;
				Global::logger->write_log("3des getencrylength failed." + (string)e.what(), eLogLv.FATAL);
				if(ctx != NULL) delete[] ctx;
				return NULL;
			}
			//发送消息完成后删除该内存
			char* final_ret = new char[final_len];
			if(final_ret == NULL) { delete[] ctx; return NULL; }

			memset(final_ret, 0x0, final_len );
			try
			{
				m_local_ses_->Encrypt(ctx, contentlen, final_ret );
			}
			catch(const std::exception& e)
			{
				*retlen = 0;
				Global::logger->write_log("3des encrypt failed." + (string)e.what(), eLogLv.FATAL);
				if(final_ret != NULL) delete[] final_ret;
				if(ctx != NULL) delete[] ctx;
				return NULL;
			}

			*retlen = final_len ;
			delete[] ctx;
			//printf("encry result is :%s", final_ret);
			return final_ret;
		}

		///生成客户端必需的信息
		char* CHandleMessage::general_client_info(char* msg, size_t len, size_t* outlen)
		{
			if((msg == NULL) || (outlen == NULL))
			{
				Global::logger->write_log("GeneralClientInfo input argument's len is null.", eLogLv.WARN);
				*outlen = 0;
				return NULL;
			}
			if(len < 335)
			{
				Global::logger->write_log("GeneralClientInfo input len is not right.", eLogLv.WARN);
				*outlen = 0;
				return NULL;
			}
			//生成对称密钥 24位
			string des_key = gen_des_key();
			//生成用户标识 12位
			string c_id = get_rand_num(ClientIDLength);
			//构建用户信息结构体 记录用户信息
			if(!c_id.compare(""))
			{
				Global::logger->write_log("user client id can't create.", eLogLv.FATAL);
				*outlen = 0;
				return NULL;
			}
			if(!cache_user_info(c_id, des_key))
			{
				m_err_reson = "cache user login info failed ";
				Global::logger->write_log(m_err_reson, eLogLv.FATAL);
				*outlen = 0;
				return NULL;
			}
			//获取客户端公钥
			unsigned int key_encry_out_len = 24;
			//加密
			//string des_key_out = "";
			string key_encry_out = "";
			try
			{
				m_ecc_.ecc_encrypt(des_key, key_encry_out, msg + 3, len -3);
				//Global::_rsa.Encrypt(msg + 5, encry_len, msg + 5 + encry_len, pub_len, &key_encry_out, &key_encry_out_len, des_key.c_str(), des_key.length());
			}
			catch(const std::exception& e)
			{
				key_encry_out = "";
				Global::logger->write_log("rsa encrypt failed, " + (string)e.what(), eLogLv.FATAL);
			}
			if(key_encry_out == "")
			{
				Global::logger->write_log("rsa encrypt failed", eLogLv.FATAL);
				*outlen = 0;
				return NULL;
			}
			unsigned int clen = c_id.length();

			//发送回给客户端时释放
			int r_len = clen + key_encry_out_len + (len - 3);
			char* ret_msg = new char[r_len];
			if(ret_msg == NULL)	{ *outlen = 0; return NULL; }
			//客户端标识
			memcpy(ret_msg , c_id.c_str(), clen);
			//ret_msg[clen ] = '|';
			//对称密钥
			memcpy(ret_msg + clen , key_encry_out.c_str(), key_encry_out_len );
			memcpy(ret_msg + clen + key_encry_out_len, msg + 3, len -3);
			//去除字符串的结尾符
			*outlen = clen + key_encry_out_len + len - 3;
			//delete[] key_encry_out;
			return ret_msg;
		}

		///用户登陆信息记录到数据库
		bool CHandleMessage::cache_user_info(string cid, string key)
		{
			string sql = "insert into t_users_online(user_id, unique_id, des_key, oper_time) values(0,";
			sql = sql.append(cid).append(",'").append(key).append("',").append("UNIX_TIMESTAMP(now())").append(")");
			db_oper* pdb = new db_oper;
			if(pdb == NULL) return false;
			if(!pdb->m_isopen)
			{
				Global::logger->write_log("database cann't open.", eLogLv.FATAL);
				return false;
			}
			//printf("a\n");
			int ins = pdb->oper_db(sql.c_str());
			if(ins == 0)
			{
				//printf("6\n");
				delete pdb;
				return true;
			}
			else
			{
				string log("cache user's talk information failed. reason: ");
				Global::logger->write_log(log.append(pdb->get_error_reason()), eLogLv.FATAL);
				//printf("3\n");
				delete pdb;
				return false;
			}
		}

		///获取用户的对称密钥
		string CHandleMessage::get_user_des_key(string c_id)
		{
			string sql = "select des_key from t_users_online where unique_id = ";
			sql.append(c_id);
			db_oper* pdb = new db_oper;
			if(pdb == NULL)
			{
				Global::logger->write_log("get db connect failed.", eLogLv.FATAL);
				return "";
			}
			int ins = pdb->oper_db(sql.c_str());
			if(ins != 0)
			{
				Global::logger->write_log(pdb->get_error_reason(), eLogLv.FATAL);
				pdb->release_res();
				delete pdb;
				return "";
			}
			int row_count = pdb->get_row_count();
			if(row_count <= 0)
			{
				pdb->release_res();
				delete pdb;
				Global::logger->write_log("user's des key not found.", eLogLv.WARN);
				return "";
			}
			string r = pdb->get_query_result(0, "des_key");
			pdb->release_res();
			delete pdb;
			return r;
		}
	}
}
