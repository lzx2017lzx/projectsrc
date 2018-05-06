#ifndef SHOVE_SECURITY_SES_H
#define SHOVE_SECURITY_SES_H


#include <string.h>
#include <iostream>

using namespace std;


namespace shove
{
    namespace security
    {
        class ses
        {

        public:

            ses(void);
            ses(const char* key);
            ~ses(void);

            void set_key(const char* key);
            char* get_key(void);

            void Encrypt(char* input, int len, char* output);
            void Decrypt(char* input, char* output, int len, int* DecryptResultLength);

            int GetEncryptResultLength(char* input, int len);

        private:

            char* key;

            int ComplementInput(char* input, int len, char* output);
            void EncryptMatrixTransform(char* output, int len);
            void DecryptMatrixTransform(char* output, int len);
            int GetDecryptResultLength(char* output, int len);

            void Xor(char* output, int len);
        };
    }
}

#endif // SHOVE_SECURITY_SES_H
