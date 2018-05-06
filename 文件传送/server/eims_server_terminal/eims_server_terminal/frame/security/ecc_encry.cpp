#include "ecc_encry.h"
ecc_encry::ecc_encry()
{
    //ctor
    memset(m_qx_, 0x0, sizeof(m_qx_));
    memset(m_qy_, 0x0, sizeof(m_qy_));
    memset(m_ttx_, 0x0, sizeof(m_ttx_));
    memset(m_tty_, 0x0, sizeof(m_tty_));
    memset(&m_ecc_para1_, 0x0, sizeof(m_ecc_para1_));
    m_key_[0] = 0x11111111;
    m_key_[1] = 0xf3b9cac2;
    m_key_[2] = 0xa7179e84;
    m_key_[3] = 0xbce6faad;
    m_key_[4] = 0xffffffff;
    m_key_[5] = 0xffffffff;
    m_key_[6] = 0x00000000;
    m_key_[7] = 0x55555555;
}

ecc_encry::~ecc_encry()
{
    //dtor
}

bool ecc_encry::initial(unsigned short encry_size)
{
    for(int i = 0; i < MAX_P_DIGITS; i++)
    {
        m_key_[i] = ((double)rand() / RAND_MAX) * 0xffffffff;
    }
    switch(encry_size)
    {
    case 256:
        ECC_Init256(&m_ecc_para1_);	//选取ECC基本参数
        break;
    case 224:
        ECC_Init224(&m_ecc_para1_);
        break;
    case 128:
        ECC_Init128(&m_ecc_para1_);
        break;
    default:
        return false;
    }
	return generate_key();
}

/// 生成加密用的椭圆曲线及公钥
bool ecc_encry::generate_key()
{
    //密钥对的生成，key为私钥，Qx,Qy为公钥
    Key_gen(m_key_,m_qx_,m_qy_,&m_ecc_para1_);
    return true;
}

/// 获取公钥
char* ecc_encry::get_pub_key(unsigned short& pk_len)
{
    ecc_pub_key pk;
    memcpy(pk.qx, m_qx_, sizeof(m_qx_));
    memcpy(pk.qy, m_qy_, sizeof(m_qy_));
    memcpy(pk.ttx, m_ttx_, sizeof(m_ttx_));
    memcpy(pk.tty, m_tty_, sizeof(m_tty_));
    pk.ecc_para = m_ecc_para1_;
    //char c_pk[sizeof(pk)];
    char* c_pk = new char[sizeof(pk)];
    memset(c_pk, 0x0, sizeof(pk));
    memcpy(c_pk, &pk, sizeof(pk));
    pk_len = sizeof(pk);
    return c_pk;
}



/// 加密
bool ecc_encry::ecc_encrypt(string src, string& res, char* pub_key, unsigned pk_len)
{
	if(pub_key == NULL)	return false;
    ecc_pub_key *pk = (ecc_pub_key*)pub_key;
    //memcpy(&pk, pub_key, pk_len);
    //长度不满足8的整数时，补上X
    unsigned int model = src.length() % 8;
    if(model != 0)
    {
        src.append(std::string( 8 - model , 'x'));
    }
    ////kk需要随机生成
    ////随机数
    NN_DIGIT kk[MAX_P_DIGITS]= { 0x11111111, 0xf3b9cac2, 0xa7179e84, 0xbce6faad,
							     0xffffffff, 0xffffffff, 0x00000000, 0x55555555 };
    for(int i = 0; i < MAX_P_DIGITS; i++)
    {
        kk[i] = ((double)rand() / RAND_MAX) * 0xffffffff;
    }
    ECC_Encry(res, pk->ttx, pk->tty, src.c_str(), src.length(), kk, pk->qx, pk->qy, &pk->ecc_para);

    return true;
}

/// 解密
bool ecc_encry::ecc_decrypt(string src, string& res, char* dec_para, unsigned int src_len)
{
	if(dec_para == NULL) return false;
    ecc_pub_key *dk = (ecc_pub_key*)dec_para;
    ECC_Decry(res, src.c_str(), src.length(), dk->ttx, dk->tty, m_key_, &dk->ecc_para);
    return true;
}
