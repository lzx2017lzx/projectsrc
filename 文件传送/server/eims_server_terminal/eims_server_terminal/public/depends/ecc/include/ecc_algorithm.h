#ifndef ECC_ALGORITHM_H_INCLUDED
#define ECC_ALGORITHM_H_INCLUDED

#include <string>
#include <stdio.h>
#include <string.h>
#include "ecc_des.h"
#include "ecc_global.h"

struct ECC_Para{
    NN_DIGIT P[MAX_P_DIGITS];
	NN_DIGIT EC_a[MAX_P_DIGITS];
	NN_DIGIT EC_b[MAX_P_DIGITS];
	NN_DIGIT Gx[MAX_P_DIGITS];
	NN_DIGIT Gy[MAX_P_DIGITS];
	NN_DIGIT N[MAX_NN_DIGITS];
	NN_DIGIT P_DIGITS;
	NN_DIGIT N_DIGITS;
	NN_DIGIT P_Bits;
	ECC_Para& operator=(const ECC_Para& e)
	{
		memcpy(P, e.P, sizeof(e.P));
		memcpy(EC_a, e.EC_a, sizeof(e.EC_a));
		memcpy(EC_b, e.EC_b, sizeof(e.EC_b));
		memcpy(Gx, e.Gx, sizeof(e.Gx));
		memcpy(Gy, e.Gy, sizeof(e.Gy));
		memcpy(N, e.N, sizeof(e.N));
		P_DIGITS = e.P_DIGITS;
		N_DIGITS = e.N_DIGITS;
		P_Bits = e.P_Bits;
		return *this;
	};
} ;
//ECC_Para;

/// ECC算法使用的函数
void NN_Add_ModP(NN_DIGIT *,NN_DIGIT *, NN_DIGIT *,NN_DIGIT *,unsigned int);

void NN_Sub_ModP(NN_DIGIT *,NN_DIGIT *,NN_DIGIT *,NN_DIGIT *,unsigned int);

void ECC_Add_Affine(NN_DIGIT *,NN_DIGIT *,NN_DIGIT *,NN_DIGIT *,NN_DIGIT *,NN_DIGIT *,NN_DIGIT *,unsigned int);

void ECC_Double_Affine(NN_DIGIT *,NN_DIGIT *,NN_DIGIT *,NN_DIGIT *,NN_DIGIT *,NN_DIGIT *,unsigned int);

void ECC_kP_Affine(NN_DIGIT *,NN_DIGIT *,NN_DIGIT *,unsigned int,NN_DIGIT *,NN_DIGIT *,
				   NN_DIGIT *,NN_DIGIT *,unsigned int);

void Key_gen(NN_DIGIT *,NN_DIGIT *,NN_DIGIT *,ECC_Para *);

void ECC_Double_Pro(NN_DIGIT *,NN_DIGIT *,NN_DIGIT *,NN_DIGIT *,NN_DIGIT *,NN_DIGIT *,
					NN_DIGIT *,NN_DIGIT *,unsigned int);

void ECC_Add_Pro(NN_DIGIT *,NN_DIGIT *,NN_DIGIT *,NN_DIGIT *,NN_DIGIT *,NN_DIGIT *,
					NN_DIGIT *,NN_DIGIT *,NN_DIGIT *,NN_DIGIT *,unsigned int);

void ECC_kP_Pro(NN_DIGIT *,NN_DIGIT *,NN_DIGIT *,unsigned int,NN_DIGIT *,NN_DIGIT *,
				NN_DIGIT *,NN_DIGIT *,unsigned int);

bool ECC_Decry(std::string& out_ming, const char *in_mi, unsigned int mi_len, NN_DIGIT *ttx,NN_DIGIT *tty,NN_DIGIT *key,ECC_Para *ECC_Para);

bool ECC_Encry(std::string& out_mi,NN_DIGIT *ttx,NN_DIGIT *tty, const char *in_ming, unsigned ming_len, NN_DIGIT *kk,NN_DIGIT *Qx,NN_DIGIT *Qy,ECC_Para *ECC_Para);

void RC4(unsigned char * key,unsigned int key_len,unsigned char *inout, unsigned int len);

///ecc init
void ECC_Init128(ECC_Para *ECC_Para1);
void ECC_Init224(ECC_Para *ECC_Para1);
void ECC_Init256(ECC_Para *ECC_Para1);


#endif // ECC_ALGORITHM_H_INCLUDED
