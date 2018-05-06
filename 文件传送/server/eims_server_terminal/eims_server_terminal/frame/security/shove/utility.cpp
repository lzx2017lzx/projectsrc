#include "utility.h"

namespace shove
{
char* utility::str_trim(char* pStr)
{
    char* pStart = pStr;
    char* pEnd = pStart + strlen(pStart) - 1;

    while(isspace(*pStart)) pStart++;
    while(isspace(*pEnd))   pEnd--;

    *(pEnd + 1) = '\0';

    return pStart;
}

char* utility::str_trim_quote(char* pStr)
{
    char* pStart = pStr;
    char* pEnd = pStart + strlen(pStart) - 1;

    if (*pStart == '"') pStart++;
    if (*pEnd == '"')   pEnd--;

    *(pEnd + 1) = '\0';

    return pStart;
}


string utility::string_ltrim(string Source)
{
    string str = Source;

    return str.erase(0, str.find_first_not_of(" "));
}

string utility::string_rtrim(string Source)
{
    string str = Source;

    return str.erase(str.find_last_not_of(" ") + 1);
}

string utility::string_trim(string Source)
{
    return string_ltrim(string_rtrim(Source));
}


string utility::MD5(string input)
{
    unsigned char* p = (unsigned char*)input.c_str();

    return MD5((char*)p);
}

string utility::MD5(char* input)
{
    return _md5.GenerateMD5((unsigned char*)input, strlen(input));
}

string utility::MD5(char* input, char* key)
{
    string _input(input);
    string _key(key);

    return MD5(_input, _key);
}

string utility::MD5(string input, string key)
{
    string _input = input + key;

    return _md5.GenerateMD5((unsigned char*)_input.c_str(), _input.length());
}


string utility::SES_Encrypt(string input, string key)
{
    _ses.set_key(key.c_str());

    int len = _ses.GetEncryptResultLength((char*)input.c_str(), input.length());
    char* output = new char[len];

    _ses.Encrypt((char*)input.c_str(), input.length(), output);

    return convert::enBase64((const char*)output, len);
}

string utility::SES_Decrypt(string input, string key)
{
    _ses.set_key(key.c_str());

    string _input = convert::deBase64(input);
    int len = _input.length();

    char* output = new char[len];
    int output_len;

    _ses.Decrypt(_input.c_str(), output, len, &output_len);

    char* _output = new char[output_len + 1];
    memcpy(_output, output, output_len);
    _output[output_len] = '\0';

    string result(_output);
    delete[] _output;
    delete[] output;

    return result;
}


unsigned char* utility::compress_string(unsigned char* input, unsigned long input_len, unsigned long* output_len)
{
    *output_len = compressBound(input_len);
    unsigned char* output = new unsigned char[*output_len];

    if (compress(output, output_len, input, input_len) != Z_OK)
    {
        *output_len = -1;
    }

    return output;
}

unsigned char* utility::uncompress_string(unsigned char* input, unsigned long input_len, unsigned long* output_len)
{
    if (input_len <= 0)
    {
        *output_len = -1;

        return NULL;
    }

    *output_len = input_len * 100;
    unsigned char* output = new unsigned char[*output_len];
    int result = uncompress(output, output_len, input, input_len);

    if (result == Z_DATA_ERROR)
    {
        *output_len = 0;

        return output;
    }

    if (result == Z_BUF_ERROR)
    {
        *output_len = input_len * 1000;
        if (output != NULL) delete[] output;
        output = NULL;
        output = new unsigned char[*output_len];

        result = uncompress(output, output_len, input, input_len);
    }

    if (result != Z_OK)
    {
        *output_len = -2;
    }

    return output;
}


void utility::WriteLog(string filename, string log)
{
    ofstream ofs(filename.c_str(), ios::app);
    ofs << convert::TimeToString() << "\t" << log << endl;
    ofs.close();
}
void utility::PrintSystemInfo()
{
	//using namespace std;
//    struct sysinfo s_info;
//    int error;
//
//    error = sysinfo(&s_info);
//    printf("\n\ncode error=%d\n",error);
//    printf("Uptime = %ds\nLoad: 1 min%d / 5 min %d / 15 min %d\n"
//           "RAM: total %d / free %d /shared%d\n"
//           "Memory in buffers = %d\nSwap:total%d/free%d\n"
//           "Number of processes = %d\n",
//           s_info.uptime, s_info.loads[0],
//           s_info.loads[1], s_info.loads[2],
//           s_info.totalram, s_info.freeram,
//           s_info.totalswap, s_info.freeswap,
//           s_info.procs );
//    return ;
}
}
