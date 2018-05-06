#ifndef SHOVE_CONVERT_H
#define SHOVE_CONVERT_H


#include <string.h>
#include <stdlib.h>
#include <string>
#include <clocale>
#include <iostream>
#include <sstream>
#include <typeinfo>
#include <ctime>
#include <iconv.h>

using namespace std;

namespace shove
{
    class convert
    {

    public:

        static void _enBase64Help(unsigned char chasc[3], unsigned char chuue[4]);
        static void _deBase64Help(unsigned char chuue[4], unsigned char chasc[3]);
        static string enBase64(const char* inbuf, size_t inbufLen);
        static string enBase64(const string& inbuf);
        static int deBase64(string src, char* outbuf);
        static string deBase64(string src);

        static string ws2s(const wstring& ws);
        static wstring s2ws(const string& s);
        static wstring UTF2Uni(const char* src, wstring& t);
        static int Uni2UTF(const wstring& strRes, char* utf8, int nMaxSize);
        static string s2utfs(const string& strSrc);
        static string utfs2s(const string& strutf);

        static string convert_encoding(const string& input, char* from_encoding, char* to_encoding);

        static string TimeToString();
        static string TimeToString(const time_t& t);

        template <typename Type>
        static Type StringToNumber(const string& str)
        {
            string _str = str;

            if (_str.empty())
            {
                _str = "0";
            }

            try
            {
                istringstream iss(_str);
                Type number;

                iss >> number;

                return number;
            }
            catch(const std::exception& e)
            {
            }

            return 0;
        }

        template <typename Type>
        static string NumberToString(Type number)
        {
            try
            {
                ostringstream oss;
                oss << number;

                return oss.str();
            }
            catch(const std::exception& e)
            {
            }

            return "";
        }
    };
}

#endif // SHOVE_CONVERT_H
