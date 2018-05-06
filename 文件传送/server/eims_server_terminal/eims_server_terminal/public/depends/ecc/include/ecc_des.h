#ifndef ECC_DES_H_INCLUDED
#define ECC_DES_H_INCLUDED

#include <string.h>

//enum Mode { ENCRYPT, DECRYPT };
#define ENCRYPT 0
#define DECRYPT 1

// Encrypt/decrypt the data in "data", according to the "key".
// Caller is responsible for confirming the buffer size of "data"
// points to is 8*"blocks" bytes.
// The data encrypted/decrypted is stored in data.
// The return code is 1:success, other:failed.
//int encrypt ( unsigned char key[8], unsigned char* data, int blocks = 1 );
//int decrypt ( unsigned char key[8], unsigned char* data, int blocks = 1 );
int encrypt ( unsigned char key[8], unsigned char* data, int blocks );
int decrypt ( unsigned char key[8], unsigned char* data, int blocks );
void SingleDesEncrypt(unsigned char *,unsigned char *,unsigned char *);
void SingleDesDecrypt(unsigned char *,unsigned char *,unsigned char *);
void TripleDesEncrypt(unsigned char *,unsigned char *,unsigned char *);
void TripleDesDecrypt(unsigned char *,unsigned char *,unsigned char *);

// Encrypt/decrypt any size data,according to a special method.
// Before calling yencrypt, copy data to a new buffer with size
// calculated by extend.
int yencrypt ( unsigned char key[8], unsigned char* data, int size );
//int ydecrypt ( unsigned char key[8], unsigned char* in, int blocks, int* size = 0 );
int ydecrypt ( unsigned char key[8], unsigned char* in, int blocks, int* size  );

int extend ( int size );

void des(unsigned char* in, unsigned char* out, int blocks);
void des_block(unsigned char* in, unsigned char* out);

void deskey(unsigned char key[8], int md);
void usekey(unsigned long *);
void cookey(unsigned long *);

void scrunch(unsigned char *, unsigned long *);
void unscrun(unsigned long *, unsigned char *);
void desfunc(unsigned long *, unsigned long *);


////////////////////
int Encrypt_ECB(unsigned char *text,int len,unsigned char *key,unsigned char *result);

int Decrypt_ECB(unsigned char *text,int len,unsigned char *key,unsigned char *result);

#endif // ECC_DES_H_INCLUDED
