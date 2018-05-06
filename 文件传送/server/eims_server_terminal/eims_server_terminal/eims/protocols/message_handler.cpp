#include "message_handler.h"

namespace eims
{
	namespace protocols
	{
		///����
		CHandleMessage::CHandleMessage()
		{
			m_lua_oper_ = NULL;
			//m_local_ses_ = new shove::security::ses();
		}

		///����
		CHandleMessage::~CHandleMessage()
		{
			if(m_lua_oper_ != NULL)
				m_lua_oper_->clear();
		}

		///��Ϣ������ѭ��
		char* CHandleMessage::handle_message(char* input, size_t len, size_t* result_len, string ip)
		{
			/////////////////////////////////////////////////////////////
			//	����Ϣ���ͣ�������LUA�ű�������ҵ���߼�
			if(input == NULL)
			{
				Global::logger->write_log("input data is null", eLogLv.WARN);
				return NULL;
			}

			//����Գ���Կ������
			if ((MessagePreFix[0] == input[0]) && (MessagePreFix[1] == input[1]) && (MessagePreFix[2] == input[2]))
			{
				//input ����Ϣ���ͻؿͻ���ʱ �ͷŵ�
				return general_client_info(input, len, result_len);
			}

			//�ͻ��˷�������Ϣ���������ĵĿͻ��˱�ʶ��
			//��Ϣ�ڴ˽��У���������ܣ���ȡXML����
			//����ǰ��N(ClientIDLength)���ֽڱ�ʾ�ͻ��˵ı�ʶ
			//�����ȫ���ֽھ�����Ϣ������

			string cl_id(input, ClientIDLength);
			string key("");
			if(allisnum(cl_id))
			{
				key = get_user_des_key(cl_id);
			}
			else
			{
				//�û���ʶ����ȫ���֣���Ϊ�ǷǷ����ʡ�ֱ�ӹرտͻ��ˡ�
				Global::logger->write_log("a illegal access was dennied." + cl_id, eLogLv.INFO);
				return NULL;
			}
			if(!key.compare(""))
			{
				//�Ҳ����û���Ӧ�Ľ�����Կ����Ϊ�ǷǷ����ʡ�ֱ�ӹرտͻ��ˡ�
				Global::logger->write_log("user's des key not found.", eLogLv.INFO);
				return NULL;
			}

			char * orig_data = input + ClientIDLength;
			unsigned long pid = pthread_self();
			m_local_ses_ = Common::ses_oper_grab(pid);

			//���key�󣬽�����Ϣ
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
			//��ȡ��LUA�����
			m_lua_oper_ = Common::lua_vm_grab(pid);
			CHECKPOINT(m_lua_oper_)

			//����LUA�ű����ҵ���߼�
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
				//��ȡ����ֵ
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

		///��������Ϣ���м��ܴ���
		char* CHandleMessage::format_return_message(string& messagecontent, unsigned int contentlen, size_t* retlen)
		{
			if(!retlen)
				return NULL;
			//������Ϣ
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
			//������Ϣ��ɺ�ɾ�����ڴ�
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

		///���ɿͻ��˱������Ϣ
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
			//���ɶԳ���Կ 24λ
			string des_key = gen_des_key();
			//�����û���ʶ 12λ
			string c_id = get_rand_num(ClientIDLength);
			//�����û���Ϣ�ṹ�� ��¼�û���Ϣ
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
			//��ȡ�ͻ��˹�Կ
			unsigned int key_encry_out_len = 24;
			//����
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

			//���ͻظ��ͻ���ʱ�ͷ�
			int r_len = clen + key_encry_out_len + (len - 3);
			char* ret_msg = new char[r_len];
			if(ret_msg == NULL)	{ *outlen = 0; return NULL; }
			//�ͻ��˱�ʶ
			memcpy(ret_msg , c_id.c_str(), clen);
			//ret_msg[clen ] = '|';
			//�Գ���Կ
			memcpy(ret_msg + clen , key_encry_out.c_str(), key_encry_out_len );
			memcpy(ret_msg + clen + key_encry_out_len, msg + 3, len -3);
			//ȥ���ַ����Ľ�β��
			*outlen = clen + key_encry_out_len + len - 3;
			//delete[] key_encry_out;
			return ret_msg;
		}

		///�û���½��Ϣ��¼�����ݿ�
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

		///��ȡ�û��ĶԳ���Կ
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
