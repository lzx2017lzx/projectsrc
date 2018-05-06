#ifndef GLOBAL_H_INCLUDED
#define GLOBAL_H_INCLUDED
#include <boost/unordered_map.hpp>
//#include <security/ses.h>
//#include "../security/rsa_encry.h"
#include "../debug/log.h"

#include "meta.h"

using namespace boost;
using namespace eims::meta;
using namespace eims::debug;
namespace eims
{
namespace global
{
	class Global
	{
		public:
			~Global();
			///RSA加密的对象
			//static RSA_Encry _rsa;
			///DES加密的对象
			//static shove::security::ses _ses;
			///日志
			static Logger* logger;
	};
}
}

#endif // GLOBAL_H_INCLUDED
