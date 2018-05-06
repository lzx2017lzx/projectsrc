 #ifndef ECC_ENCRY_H
#define ECC_ENCRY_H
#include <stdlib.h>
#include <string>
#include "ecc_global.h"
#include "ecc_algorithm.h"

using namespace std;

// 公钥是多种信息组成的，这里为了方便，使用结构体
// 在传送过程中，可将此结构体转换成字符串
class ecc_pub_key
{
public:
	NN_DIGIT ttx[MAX_P_DIGITS], tty[MAX_P_DIGITS], qx[MAX_P_DIGITS], qy[MAX_P_DIGITS];
	ECC_Para ecc_para;
	ecc_pub_key()
	{
		memset(ttx, 0x0, sizeof(ttx));
		memset(tty, 0x0, sizeof(tty));
		memset(qx, 0x0, sizeof(qx));
		memset(qy, 0x0, sizeof(qy));
		memset(&ecc_para, 0x0, sizeof(ecc_para));
	}
	ecc_pub_key& operator=(const ecc_pub_key& e)
	{
		memcpy(ttx, e.ttx, sizeof(e.ttx));
		memcpy(tty, e.tty, sizeof(e.tty));
		memcpy(qx, e.qx, sizeof(e.qx));
		memcpy(qy, e.qy, sizeof(e.qy));
		ecc_para = e.ecc_para;
		return *this;
	}
};

class ecc_encry
{
	public:
		ecc_encry();
		~ecc_encry();
		/// 初始化,加密的长度可选的有三种(128,224,256)
		bool initial(unsigned short encry_size);

		/// 获取公钥
		char* get_pub_key(unsigned short& pk_len);
		/// 加密
		bool ecc_encrypt(string src, string& res, char* pub_key, unsigned pk_len);
		/// 解密
		bool ecc_decrypt(string src, string& res, char* dec_para, unsigned int src_len);

	private:
		/// 生成加密用的椭圆曲线及公钥
		bool generate_key();

		char* m_pri_key_;
		char* m_pub_key_;

		NN_DIGIT m_key_[MAX_P_DIGITS];
		//公钥
		NN_DIGIT m_qx_[MAX_P_DIGITS], m_qy_[MAX_P_DIGITS];
		//协商公钥
		NN_DIGIT m_ttx_[MAX_P_DIGITS], m_tty_[MAX_P_DIGITS];
		//ECC曲线参数
		ECC_Para m_ecc_para1_;  //ECC基本参数
};

#endif // ECC_ENCRY_H
