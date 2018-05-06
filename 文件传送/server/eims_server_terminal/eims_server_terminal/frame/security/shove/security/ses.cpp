#include "ses.h"

namespace shove
{
    namespace security
    {
        const unsigned char SES_IV[16] = { 0xe0, 0x20, 0x3a, 0x08, 0x49, 0x06, 0x24, 0x5c, 0xc2, 0x29, 0xac, 0x12, 0x91, 0x95, 0xe4, 0x79 };


        ses::ses(void)
        {
            this->key = NULL;
        }

        ses::ses(const char* key)
        {
            set_key(key);
        }

        ses::~ses(void)
        {
            if (this->key != NULL)  delete[] this->key;   this->key = NULL;
        }

        // 设置 key
        void ses::set_key(const char* key)
        {
            int len = strlen(key);

            if (len < 16)
            {
                throw "ses\'s key length must be greater than or equal to 16 characters.";
            }
			if (this->key != NULL)  delete[] this->key;   this->key = NULL;
            this->key = new char[17];
            memset(this->key, 0x0, 17);
            memcpy(this->key, key, 16);

            for (int i = 0; i < 16; i++)
            {
                this->key[i] ^= SES_IV[i];
            }
        }

        char* ses::get_key(void)
        {
            return this->key;
        }

        // input, output 均为已经申请好了内存的指针。output 的大小可以用 GetResultLength(input) 获得。
        void ses::Encrypt(const char* input, int len, char* output)
        {
            if (this->key == NULL)
            {
                throw "ses\'s key must be setting. usage: set_key(...).";
            }

            int complemented_len = ComplementInput(input, len, output);
            EncryptMatrixTransform(output, complemented_len);
            Xor(output, complemented_len);
        }

        // input, output 均为已经申请好了内存的指针。output 的大小先与 input 设置为相同，ResultLength 参数将返回实际的长度。
        void ses::Decrypt(const char* input, char* output, int len, int* DecryptResultLength)
        {
            if (this->key == NULL)
            {
                throw "ses\'s key must be setting. usage: set_key(...).";
            }

            memcpy(output, input, len);
            Xor(output, len);
            DecryptMatrixTransform(output, len);
            *DecryptResultLength = GetDecryptResultLength(output, len);
        }

        int ses::GetEncryptResultLength(const char* input, int len)  // 根据源串，获得加密结果的长度。
        {
            //int len = strlen(input);
            int complement_len = 8 - len % 8;

            if (complement_len == 1)
            {
                complement_len = 9;
            }

            return complement_len + len;
        }

        int ses::GetDecryptResultLength(char* output, int len)
        {
            int complement_len = 0;
            int i = len - 1;

            while (!output[i--])
            {
                complement_len++;
            }

            int num = output[i + 1];

            if ((complement_len > 0) && (num != complement_len))
            {
                //throw;// exception("Invalid ciphertext format.");
                //throw "Invalid ciphertext format.";
                return -1;
            }

            return (complement_len == 0) ? len : len - complement_len - 1;
        }

        int ses::ComplementInput(const char* input, int len, char* output)
        {
            //int len = strlen(input);
            int complement_len = GetEncryptResultLength(input, len) - len;

            memcpy(output, input, len);

            if (complement_len == 0)
            {
                return len;
            }

            memset(output + len, 0, complement_len);
            output[len] = complement_len - 1;

            return len + complement_len;
        }

        void ses::EncryptMatrixTransform(char* output, int len)
        {
            int row = len / 4;
            char* t = new char[row];

            for (int i = 0; i < row; i++)
            {
                t[i] = output[i * 4];
            }

            for (int i = 0; i < row; i++)
            {
                for (int j = 0; j < 3; j++)
                {
                    output[i * 4 + j] = output[i * 4 + j + 1];
                }

                output[i * 4 + 3] = t[i];
            }

            if (t != NULL)  delete[] t; t = NULL;

            t = new char[4];

            for (int i = 0; i < 4; i++)
            {
                t[i] = output[i];
            }

            for (int i = 0; i < row - 1; i++)
            {
                for (int j = 0; j < 4; j++)
                {
                    output[i * 4 + j] = output[(i + 1) * 4 + j];
                }
            }

            for (int i = 0; i < 4; i++)
            {
                output[(row - 1) * 4 + i] = t[i];
            }

            if (t != NULL)  delete[] t; t = NULL;
        }

        void ses::DecryptMatrixTransform(char* output, int len)
        {
            int row = len / 4;
            char* t = new char[4];

            for (int i = 0; i < 4; i++)
            {
                t[i] = output[(row - 1) * 4 + i];
            }

            for (int i = row - 1; i > 0; i--)
            {
                for (int j = 0; j < 4; j++)
                {
                    output[i * 4 + j] = output[(i - 1) * 4 + j];
                }
            }

            for (int i = 0; i < 4; i++)
            {
                output[i] = t[i];
            }

            if (t != NULL)  delete[] t; t = NULL;

            t = new char[row];

            for (int i = 0; i < row; i++)
            {
                t[i] = output[i * 4 + 3];
            }

            for (int i = 0; i < row; i++)
            {
                for (int j = 3; j > 0; j--)
                {
                    output[i * 4 + j] = output[i * 4 + j - 1];
                }

                output[i * 4] = t[i];
            }

            if (t != NULL)  delete[] t; t = NULL;
        }

        void ses::Xor(char* output, int len)
        {
            int key_position = 0;

            for (int i = 0; i < len; i++)
            {
                output[i] ^= this->key[key_position++];

                if (key_position >= 16)
                {
                    key_position = 0;
                }
            }
        }
    }
}
