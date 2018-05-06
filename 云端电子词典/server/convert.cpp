#include "convert.h"
//#include "consts.h"

namespace lizongxin
{
    void convert::_enBase64Help(unsigned char chasc[3], unsigned char chuue[4])
    {
        int i, k = 2;
        unsigned char t = 0;

        for (i = 0; i < 3; i++)
        {
            *(chuue + i) = *(chasc + i) >> k;
            *(chuue + i) |= t;
            t = *(chasc + i) << (8 - k);
            t >>= 2;
            k += 2;
        }

        *(chuue + 3) = *(chasc + 2) & 63;

        for (i = 0; i < 4; i++)
        {
            if ((*(chuue + i) <= 128) && (*(chuue + i) <= 25))
            {
                *(chuue + i) += 65; // 'A'-'Z'
            }
            else if ((*(chuue + i) >= 26) && (*(chuue + i) <= 51))
            {
                *(chuue + i) += 71; // 'a'-'z'
            }
            else if ((*(chuue + i) >= 52) && (*(chuue + i) <= 61))
            {
                *(chuue + i) -= 4; // 0-9
            }
            else if (*(chuue + i) == 62)
            {
                *(chuue + i) = 43; // +
            }
            else if (*(chuue + i) == 63)
            {
                *(chuue + i) = 47; // /
            }
        }
    }

    void convert::_deBase64Help(unsigned char chuue[4], unsigned char chasc[3])
    {
        int i, k = 2;
        unsigned char t = 0;

        for (i = 0; i < 4; i++)
        {
            if ((*(chuue + i) >= 65) && (*(chuue + i) <= 90))
            {
                *(chuue+i) -= 65; // 'A'-'Z' -> 0-25
            }
            else if ((*(chuue + i) >= 97) && (*(chuue + i) <= 122))
            {
                *(chuue + i) -= 71; // 'a'-'z' -> 26-51
            }
            else if ((*(chuue + i) >= 48) && (*(chuue + i) <= 57))
            {
                *(chuue + i) += 4; // '0'-'9' -> 52-61
            }
            else if (*(chuue + i) == 43)
            {
                *(chuue + i) = 62; // + -> 62
            }
            else if (*(chuue + i) == 47)
            {
                *(chuue + i) = 63; // / -> 63
            }
            else if (*(chuue + i) == 61)
            {
                *(chuue + i) = 0;  // = -> 0  Note: 'A'和'='都对应了0
            }
        }

        for (i = 0; i < 3; i++ )
        {
            *(chasc + i) = *(chuue + i) << k;
            k += 2;
            t = *(chuue + i + 1) >> (8 - k);
            *(chasc + i) |= t;
        }
    }

    string convert::enBase64(const char* inbuf, size_t inbufLen)
    {
        string outStr;
        unsigned char in[8];
        unsigned char out[8];

        out[4] = 0;
        size_t blocks = inbufLen / 3;

        for (size_t i = 0; i < blocks; i++)
        {
            in[0] = inbuf[i * 3];
            in[1] = inbuf[i * 3 + 1];
            in[2] = inbuf[i * 3 + 2];

            _enBase64Help(in, out);

            outStr += out[0];
            outStr += out[1];
            outStr += out[2];
            outStr += out[3];
        }

        if (inbufLen % 3 == 1)
        {
            in[0] = inbuf[inbufLen - 1];
            in[1] = 0;
            in[2] = 0;

            _enBase64Help(in, out);

            outStr += out[0];
            outStr += out[1];
            outStr += '=';
            outStr += '=';
        }
        else if (inbufLen % 3 == 2)
        {
            in[0] = inbuf[inbufLen - 2];
            in[1] = inbuf[inbufLen - 1];
            in[2] = 0;

            _enBase64Help(in, out);

            outStr += out[0];
            outStr += out[1];
            outStr += out[2];
            outStr += '=';
        }

        return string(outStr);
    }

    string convert::enBase64(const string &inbuf)
    {
        return enBase64(inbuf.c_str(), inbuf.size());
    }

    int convert::deBase64(string src, char* outbuf)
    {
        // Break when the incoming base64 coding is wrong
        if ((src.size() % 4 ) != 0)
        {
            return 0;
        }

        unsigned char in[4];
        unsigned char out[3];

        size_t blocks = src.size() / 4;

        for (size_t i = 0; i < blocks; i++)
        {
            in[0] = src[i * 4];
            in[1] = src[i * 4 + 1];
            in[2] = src[i * 4 + 2];
            in[3] = src[i * 4 + 3];

            _deBase64Help(in, out);

            outbuf[i * 3]   = out[0];
            outbuf[i * 3 + 1] = out[1];
            outbuf[i * 3 + 2] = out[2];
        }

        int length = src.size() / 4 * 3;

        if (src[src.size() - 1] == '=')
        {
            length--;

            if (src[src.size() - 2] == '=')
            {
                length--;
            }
        }

        return length;
    }

    string convert::deBase64(string src)
    {
        char * buf = new char[src.length() * 2];
        int len = deBase64(src, buf);
        buf[len] = '\0';

        string result = string(buf, len);

        if (buf != NULL)    delete[] buf;   buf = NULL;

        return result;
    }

    string convert::ws2s(const wstring& ws)
    {
        string curLocale = setlocale(LC_ALL, NULL); // curLocale = "C";
        #ifdef OS_WINDOWS
            setlocale(LC_ALL, "chs");
        #else
            setlocale(LC_ALL, "zh_CN.UTF-8");
        #endif

        const wchar_t* _Source = ws.c_str();
        size_t _Dsize = 2 * ws.size() + 1;
        char *_Dest = new char[_Dsize];
        memset(_Dest, 0 ,_Dsize);
        wcstombs(_Dest, _Source, _Dsize);
        string result = _Dest;
        if (_Dest != NULL)  delete[] _Dest; _Dest = NULL;

        //setlocale(LC_ALL, "C");
        setlocale(LC_ALL, curLocale.c_str());

        return result;
    }

    wstring convert::s2ws(const string& s)
    {
        string curLocale = setlocale(LC_ALL, NULL); // curLocale = "C";
        #ifdef OS_WINDOWS
            setlocale(LC_ALL, "chs");
        #else
            setlocale(LC_ALL, "zh_CN.UTF-8");
        #endif

        const char* _Source = s.c_str();
        size_t _Dsize = s.size() + 1;
        wchar_t *_Dest = new wchar_t[_Dsize];
        wmemset(_Dest, 0, _Dsize);
        mbstowcs(_Dest, _Source, _Dsize);
        wstring result = _Dest;
        if (_Dest != NULL)  delete[] _Dest; _Dest = NULL;

        //setlocale(LC_ALL, "C");
        setlocale(LC_ALL, curLocale.c_str());

        return result;
    }

    wstring convert::UTF2Uni(const char* src, wstring& t)
    {
        if (src == NULL)
        {
            return L"";
        }

        int size_s = strlen(src);
        int size_d = size_s + 10;          //?

        wchar_t *des = new wchar_t[size_d];
        memset(des, 0, size_d * sizeof(wchar_t));

        int s = 0, d = 0;
        //bool toomuchbyte = true; //set true to skip error prefix.

        while (s  < size_s && d  < size_d)
        {
            unsigned char c = src[s];

            if ((c & 0x80) == 0)
            {
                des[d++] += src[s++];
            }
            else if((c & 0xE0) == 0xC0)  /// < 110x-xxxx 10xx-xxxx
            {
                wchar_t& wideChar = des[d++];
                wideChar  = (src[s + 0] & 0x3F) << 6;
                wideChar |= (src[s + 1] & 0x3F);

                s += 2;
            }
            else if((c & 0xF0) == 0xE0)  /// < 1110-xxxx 10xx-xxxx 10xx-xxxx
            {
                wchar_t& wideChar = des[d++];

                wideChar  = (src[s + 0] & 0x1F) << 12;
                wideChar |= (src[s + 1] & 0x3F) << 6;
                wideChar |= (src[s + 2] & 0x3F);

                s += 3;
            }
            else if((c & 0xF8) == 0xF0)  /// < 1111-0xxx 10xx-xxxx 10xx-xxxx 10xx-xxxx
            {
                wchar_t& wideChar = des[d++];

                wideChar  = (src[s + 0] & 0x0F) << 18;
                wideChar  = (src[s + 1] & 0x3F) << 12;
                wideChar |= (src[s + 2] & 0x3F) << 6;
                wideChar |= (src[s + 3] & 0x3F);

                s += 4;
            }
            else
            {
                wchar_t& wideChar = des[d++]; /// < 1111-10xx 10xx-xxxx 10xx-xxxx 10xx-xxxx 10xx-xxxx

                wideChar  = (src[s + 0] & 0x07) << 24;
                wideChar  = (src[s + 1] & 0x3F) << 18;
                wideChar  = (src[s + 2] & 0x3F) << 12;
                wideChar |= (src[s + 3] & 0x3F) << 6;
                wideChar |= (src[s + 4] & 0x3F);

                s += 5;
            }
        }

        t = des;
        if (des != NULL)    delete[] des;   des = NULL;

        return t;
    }

    int convert::Uni2UTF(const wstring& strRes, char* utf8, int nMaxSize)
    {
        if (utf8 == NULL)
        {
            return -1;
        }

        int len = 0;
        int size_d = nMaxSize;


        for (wstring::const_iterator it = strRes.begin(); it != strRes.end(); ++it)
        {
            wchar_t wchar = *it;

            if (wchar < 0x80)
            {
                //
                //length = 1;
                utf8[len++] = (char)wchar;
            }
            else if (wchar < 0x800)
            {
                //length = 2;

                if (len + 1 >= size_d)
                {
                    return -1;
                }

                utf8[len++] = 0xc0 | (wchar >> 6);
                utf8[len++] = 0x80 | (wchar & 0x3f);
            }
            else if (wchar < 0x10000)
            {
                //length = 3;
                if (len + 2 >= size_d)
                {
                    return -1;
                }

                utf8[len++] = 0xe0 | (wchar >> 12);
                utf8[len++] = 0x80 | ((wchar >> 6) & 0x3f);
                utf8[len++] = 0x80 | (wchar & 0x3f);
            }
            else if (wchar < 0x200000)
            {
                //length = 4;
                if (len + 3 >= size_d)
                {
                    return -1;
                }

                utf8[len++] = 0xf0 | ((int)wchar >> 18);
                utf8[len++] = 0x80 | ((wchar >> 12) & 0x3f);
                utf8[len++] = 0x80 | ((wchar >> 6) & 0x3f);
                utf8[len++] = 0x80 | (wchar & 0x3f);
            }
        }

        return len;
    }

    string convert::s2utfs(const string& strSrc)
    {
        string strRes;
        wstring wstrUni = s2ws(strSrc);

        char* chUTF8 = new char[wstrUni.length() * 3];
        memset(chUTF8,0x00, wstrUni.length() * 3);
        Uni2UTF(wstrUni, chUTF8, wstrUni.length() * 3);
        strRes = chUTF8;
        if (chUTF8 != NULL) delete[] chUTF8;    chUTF8 = NULL;

        return strRes;
    }

    string convert::utfs2s(const string& strutf)
    {
        wstring wStrTmp;
        UTF2Uni(strutf.c_str(), wStrTmp);
        return ws2s(wStrTmp);
    }

    string convert::convert_encoding(const string& input, char* from_encoding, char* to_encoding)
    {
        size_t in_len = input.length();
        size_t out_len = in_len * 4;
        iconv_t cd = iconv_open(to_encoding, from_encoding);
        char* outbuf = (char*)malloc(out_len);
        bzero(outbuf, out_len);

        char* in = (char*)input.c_str();
        char* out = outbuf;

        iconv(cd, &in, (size_t*)&in_len, &out, &out_len);

        out_len = strlen(outbuf);
        string result(outbuf);
        free(outbuf);

        iconv_close(cd);

        return result;
    }

    string convert::TimeToString()
    {
        time_t t;
        time(&t);

        return TimeToString(t);
    }

    string convert::TimeToString(const time_t& t)
    {
        char s[20];
        strftime(s, sizeof(s), "%Y%m%d%H%M%S", localtime(&t));
        string result(s);

        return result;
    }
}
