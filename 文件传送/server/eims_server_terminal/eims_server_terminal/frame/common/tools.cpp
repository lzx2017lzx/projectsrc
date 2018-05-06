 #include "tools.h"

namespace eims
{
namespace tool
{
Tools::Tools()
{
	//ctor
//	GET_DATA_COUNT = INTERVAL_GET_DATA_COUNT;
//	GET_USER_MSG = INTERVAL_GET_USER_MSG;
//	GET_NOTIFY = INTERVAL_GET_NOTIFY;
//	GET_APPLICATIONS_NOTIFY = INTERVAL_GET_APPLICATIONS_NOTIFY;
//	GET_ALL_SITES = INTERVAL_GET_ALL_SITES;
//	GET_ALL_SITES_USINT = INTERVAL_GET_ALL_SITES_USINT;
//	GET_APPLICATIONS = INTERVAL_GET_APPLICATIONS;
//	GET_CONTROL_TYPES = INTERVAL_GET_CONTROL_TYPES;
//	GET_NOTIFY_TYPES = INTERVAL_GET_NOTIFY_TYPES;
//	GET_CONTROLS = INTERVAL_GET_CONTROLS;
//	GET_TRADE_TYPES = INTERVAL_GET_TRADE_TYPES;
//	GET_PROVINCES = INTERVAL_GET_PROVINCES;
//	GET_CITYS = INTERVAL_GET_CITYS;
//	GET_AREAS = INTERVAL_GET_AREAS;
//	UPDATE_GET_USINGS = INTERVAL_UPDATE_GET_USINGS;
}

Tools::~Tools()
{
	//dtor
}

string Tools::handlePassword(string pwd)
{
	return utility::MD5(pwd, SYSTEM_KEY);
}

string Tools::get_cur_time_stamp()
{
	return CUtilitys::get_time_stamp();
}

string Tools::get_data_seq()
{
	long long i = get_data_sequence();
	stringstream ss;
	ss<<i;
	string s = "";
	ss>>s;
	return s;
}

string Tools::get_rand_num(int nlen)
{
	return eims::meta::get_rand_num(nlen);
}

string Tools::get_des_key()
{
	return gen_des_key();
}
}
}
