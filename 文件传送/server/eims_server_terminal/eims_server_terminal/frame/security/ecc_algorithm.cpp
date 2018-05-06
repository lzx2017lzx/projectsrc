#include <stdio.h>
#include <malloc.h>
#include "ecc_nn.h"
#include "ecc_algorithm.h"

/**
	a=b+c mod P, P is the prime of ECC
	主要用于椭圆曲线加法和倍点运算中
*/
void NN_Add_ModP(NN_DIGIT *a,NN_DIGIT *b, NN_DIGIT *c,NN_DIGIT *P,unsigned int P_DIGITS)
{
    NN_DIGIT tem[MAX_P_DIGITS];
    memset(tem, 0x0, sizeof(tem));
    int cmp_flag,carry;
    carry=NN_Add(tem,b,c,P_DIGITS);
    cmp_flag=NN_Cmp(tem,P,P_DIGITS);
    if((cmp_flag>=0)||(carry==1))
        NN_Sub(a,tem,P,P_DIGITS);
    else
        NN_Assign(a,tem,P_DIGITS);
}

/**
	a=b-c mod P ,P is the prime of ECC
	主要用于椭圆曲线加法和倍点运算中
*/
void NN_Sub_ModP(NN_DIGIT *a,NN_DIGIT *b,NN_DIGIT *c,NN_DIGIT *P,unsigned int P_DIGITS)
{
    int cmp_flag;
    NN_DIGIT tem[MAX_P_DIGITS];
    memset(tem, 0x0, sizeof(tem));
    cmp_flag=NN_Cmp(b,c,P_DIGITS);
    if(cmp_flag==1)
        NN_Sub(a,b,c,P_DIGITS);
    else
    {
        NN_Add(tem,b,P,P_DIGITS);
        NN_Sub(a,tem,c,P_DIGITS);
    }
}

/**
	ECC point add alogrithm,the point representation is affine coordinate
	(x3,y3)=(x1,y1)+(x2+y2)，the length is MAX_NN_DIGITS
*/
void ECC_Add_Affine(NN_DIGIT *x3,NN_DIGIT *y3,NN_DIGIT *x1,NN_DIGIT *y1,
                    NN_DIGIT *x2,NN_DIGIT *y2,NN_DIGIT *P,unsigned int P_DIGITS)
{
    NN_DIGIT tem1[MAX_P_DIGITS],tem2[MAX_P_DIGITS],tem3[MAX_P_DIGITS];
    NN_DIGIT add_par[MAX_P_DIGITS];
    memset(tem1, 0x0, sizeof(tem1));
    memset(tem2, 0x0, sizeof(tem2));
    memset(tem3, 0x0, sizeof(tem3));
    memset(add_par, 0x0, sizeof(add_par));

    NN_Sub_ModP(tem1,x2,x1,P,P_DIGITS);
    NN_ModInv(tem3,tem1,P,P_DIGITS);   //tem3=1/(x2-x1);

    NN_Sub_ModP(tem1,y2,y1,P,P_DIGITS);  //tem1=y2-y1

    NN_ModMult(add_par,tem3,tem1,P,P_DIGITS);  //add_par=(y2-y1)/(x2-x1)

    NN_ModMult(tem1,add_par,add_par,P,P_DIGITS);
    NN_Sub_ModP(tem2,tem1,x1,P,P_DIGITS);
    NN_Sub_ModP(x3,tem2,x2,P,P_DIGITS);                    //x3

    NN_Sub_ModP(tem1,x1,x3,P,P_DIGITS);
    NN_ModMult(tem2,tem1,add_par,P,P_DIGITS);
    NN_Sub_ModP(y3,tem2,y1,P,P_DIGITS);                    //y3
}

/**
	ECC point double alogrithm,the point representation is affine coordinate
	(x2,y2)=(x1,y1)+(x1+y1),  the length is MAX_NN_DIGITS
*/
void ECC_Double_Affine(NN_DIGIT *x2,NN_DIGIT *y2,NN_DIGIT *x1,NN_DIGIT *y1,
                       NN_DIGIT *a,NN_DIGIT *P,unsigned int P_DIGITS)
{
    NN_DIGIT tem1[MAX_P_DIGITS],tem2[MAX_P_DIGITS],tem3[MAX_P_DIGITS],tem4[MAX_P_DIGITS];
    NN_DIGIT dou_par[MAX_P_DIGITS];
    memset(tem1, 0x0, sizeof(tem1));
    memset(tem2, 0x0, sizeof(tem2));
    memset(tem3, 0x0, sizeof(tem3));
    memset(tem4, 0x0, sizeof(tem4));
    memset(dou_par, 0x0, sizeof(dou_par));

    NN_Add_ModP(tem1,y1,y1,P,P_DIGITS);
    NN_ModInv(tem3,tem1,P,P_DIGITS);   //tem3=1/2*y1

    NN_ModMult(tem1,x1,x1,P,P_DIGITS);
    NN_Add_ModP(tem2,tem1,tem1,P,P_DIGITS);
    NN_Add_ModP(tem4,tem2,tem1,P,P_DIGITS);
    NN_Add_ModP(tem1,tem4,a,P,P_DIGITS);              //tem1=3*x1^2+a

    NN_ModMult(dou_par,tem3,tem1,P,P_DIGITS);  //dou_par=(3*x1^2+a)/2*y1

    NN_ModMult(tem1,dou_par,dou_par,P,P_DIGITS);
    NN_Sub_ModP(tem2,tem1,x1,P,P_DIGITS);
    NN_Sub_ModP(x2,tem2,x1,P,P_DIGITS);                    //x2

    NN_Sub_ModP(tem1,x1,x2,P,P_DIGITS);
    NN_ModMult(tem2,tem1,dou_par,P,P_DIGITS);
    NN_Sub_ModP(y2,tem2,y1,P,P_DIGITS);                    //y2
}

/**
	ECC point scalar multiplication alogrithm,the point representation is affine coordinate
	(x3,y3)=k(x1,y1),the length of k is k_digits<=<MAX_P_DIGITS+1
*/
void ECC_kP_Affine(NN_DIGIT *x,NN_DIGIT *y,NN_DIGIT *k,unsigned int k_digits,NN_DIGIT *x1,NN_DIGIT *y1,
                   NN_DIGIT *a,NN_DIGIT *P,unsigned int P_DIGITS)

{
    NN_DIGIT tem_x2[MAX_P_DIGITS],tem_y2[MAX_P_DIGITS],tem1[MAX_P_DIGITS];
    NN_DIGIT k1[MAX_P_DIGITS + 1],k3[MAX_P_DIGITS + 1];
    NN_DIGIT y1_inv[MAX_P_DIGITS];
    memset(tem_x2, 0x0, sizeof(tem_x2));
    memset(tem_y2, 0x0, sizeof(tem_y2));
    memset(k1, 0x0, sizeof(k1));
    memset(k3, 0x0, sizeof(k3));
    memset(y1_inv, 0x0, sizeof(y1_inv));
    memset(tem1, 0x0, sizeof(tem1));

    int carry = 0, bits_num;

    carry=NN_Add(tem1, k, k, P_DIGITS);
    k3[P_DIGITS] = carry;
    carry=NN_Add(k3, tem1, k, P_DIGITS);
    k3[P_DIGITS] += carry;                 //k3=3*k
    if(k_digits == P_DIGITS + 1)
        k3[P_DIGITS] += (k[P_DIGITS] * 3);

    NN_Assign(k1, k, P_DIGITS);
    if(k_digits == P_DIGITS+1)
        k1[P_DIGITS] = k[P_DIGITS];
    else
        k1[P_DIGITS] = 0;                  //k1=k

    NN_Sub(y1_inv, P, y1, P_DIGITS);        //y1_inv=P-y1

    bits_num = NN_Bits(k3, P_DIGITS + 1);

    NN_Assign(x,x1,P_DIGITS);
    NN_Assign(y,y1,P_DIGITS);

    for(int j = bits_num - 2; j > 0; j--)
    {
        ECC_Double_Affine(tem_x2, tem_y2, x, y, a, P, P_DIGITS);
        if(!((k1[j/32]>>(j%32))&0x00000001) & ((k3[j/32]>>(j%32))&0x00000001))
            ECC_Add_Affine(x, y, tem_x2, tem_y2, x1, y1, P, P_DIGITS);

        else if(((k1[j/32]>>(j%32))&0x00000001) & !((k3[j/32]>>(j%32))&0x00000001))
            ECC_Add_Affine(x, y, tem_x2, tem_y2, x1, y1_inv, P, P_DIGITS);
        else
        {
            NN_Assign(x, tem_x2, P_DIGITS);
            NN_Assign(y, tem_y2, P_DIGITS);
        }
    }
}

/***********************
Key Pair Genertion
************************/
void Key_gen(NN_DIGIT *kA,NN_DIGIT *kAx,NN_DIGIT *kAy,ECC_Para *ECC_Para)
{
    ECC_kP_Pro(kAx,kAy,kA,ECC_Para->P_DIGITS,ECC_Para->Gx,ECC_Para->Gy,
               ECC_Para->EC_a,ECC_Para->P,ECC_Para->P_DIGITS);
}



/**
	ECC point double alogrithm,the point representation is projective coordinate
	(x2,y2,z2)=(x1,y1,z1)+(x1,y1,z1)
*/
void ECC_Double_Pro(NN_DIGIT *x2,NN_DIGIT *y2,NN_DIGIT *z2,
                    NN_DIGIT *x1,NN_DIGIT *y1,NN_DIGIT *z1,NN_DIGIT *a,NN_DIGIT *P,unsigned int P_DIGITS)
{
    NN_DIGIT T1[MAX_P_DIGITS],T2[MAX_P_DIGITS],T3[MAX_P_DIGITS],
    T4[MAX_P_DIGITS],T5[MAX_P_DIGITS],T6[MAX_P_DIGITS];
    NN_DIGIT P_3[MAX_P_DIGITS],three[MAX_P_DIGITS];
    memset(T1, 0x0, sizeof(T1));
    memset(T2, 0x0, sizeof(T2));
    memset(T3, 0x0, sizeof(T3));
    memset(T4, 0x0, sizeof(T4));
    memset(T5, 0x0, sizeof(T5));
    memset(T6, 0x0, sizeof(T6));
    memset(P_3, 0x0, sizeof(P_3));
    memset(three, 0x0, sizeof(three));

    if(NN_Zero(y1,P_DIGITS)||NN_Zero(z1,P_DIGITS))  //return(1,1,0)
    {
        NN_ASSIGN_DIGIT(x2, 1, P_DIGITS);
        NN_ASSIGN_DIGIT(y2, 1, P_DIGITS);
        NN_AssignZero(z2,P_DIGITS);
        return;
    }

    NN_Assign(T1,x1,P_DIGITS);
    NN_Assign(T2,y1,P_DIGITS);
    NN_Assign(T3,z1,P_DIGITS);

    NN_ASSIGN_DIGIT(three, 3, P_DIGITS);
    NN_Sub(P_3,P,three,P_DIGITS);         //P_3=P-3

    if(NN_Cmp(a,P_3,P_DIGITS)==0)
    {
        NN_ModMult(T4,T3,T3,P,P_DIGITS);
        NN_Sub_ModP(T5,T1,T4,P,P_DIGITS);
        NN_Add_ModP(T4,T1,T4,P,P_DIGITS);
        NN_ModMult(T5,T4,T5,P,P_DIGITS);
        NN_Add_ModP(T4,T5,T5,P,P_DIGITS);
        NN_Add_ModP(T4,T4,T5,P,P_DIGITS);          //M
    }
    else
    {
        NN_Assign(T4,a,P_DIGITS);
        NN_ModMult(T5,T3,T3,P,P_DIGITS);
        NN_ModMult(T5,T5,T5,P,P_DIGITS);
        NN_ModMult(T5,T4,T5,P,P_DIGITS);
        NN_ModMult(T4,T1,T1,P,P_DIGITS);
        NN_Add_ModP(T6,T4,T4,P,P_DIGITS);
        NN_Add_ModP(T4,T4,T6,P,P_DIGITS);
        NN_Add_ModP(T4,T4,T5,P,P_DIGITS);             //M
    }

    NN_ModMult(T3,T3,T2,P,P_DIGITS);
    NN_Add_ModP(T3,T3,T3,P,P_DIGITS);                //Z2
    NN_ModMult(T2,T2,T2,P,P_DIGITS);
    NN_ModMult(T5,T1,T2,P,P_DIGITS);
    NN_Add_ModP(T5,T5,T5,P,P_DIGITS);
    NN_Add_ModP(T5,T5,T5,P,P_DIGITS);              //S

    NN_ModMult(T1,T4,T4,P,P_DIGITS);
    NN_Add_ModP(T6,T5,T5,P,P_DIGITS);
    NN_Sub_ModP(T1,T1,T6,P,P_DIGITS);                                  //X2

    NN_ModMult(T2,T2,T2,P,P_DIGITS);
    NN_Add_ModP(T2,T2,T2,P,P_DIGITS);
    NN_Add_ModP(T2,T2,T2,P,P_DIGITS);
    NN_Add_ModP(T2,T2,T2,P,P_DIGITS);         //T

    NN_Sub_ModP(T5,T5,T1,P,P_DIGITS);
    NN_ModMult(T5,T4,T5,P,P_DIGITS);
    NN_Sub_ModP(T2,T5,T2,P,P_DIGITS);         //Y2

    NN_Assign(x2,T1,P_DIGITS);
    NN_Assign(y2,T2,P_DIGITS);
    NN_Assign(z2,T3,P_DIGITS);

    return;
}

/**
	ECC point add alogrithm,the point representation is projective coordinate
	(x3,y3,z3)=(x1,y1,z1)+(x2+y2,z1)
*/
void ECC_Add_Pro(NN_DIGIT *x3,NN_DIGIT *y3,NN_DIGIT *z3,NN_DIGIT *x1,NN_DIGIT *y1,NN_DIGIT *z1,
                 NN_DIGIT *x2,NN_DIGIT *y2,NN_DIGIT *z2,NN_DIGIT *P,unsigned int P_DIGITS)
{
    NN_DIGIT T1[MAX_P_DIGITS],T2[MAX_P_DIGITS],T3[MAX_P_DIGITS],
    T4[MAX_P_DIGITS],T5[MAX_P_DIGITS],T6[MAX_P_DIGITS],
    T7[MAX_P_DIGITS],T8[MAX_P_DIGITS];
    memset(T1, 0x0, sizeof(T1));
    memset(T2, 0x0, sizeof(T2));
    memset(T3, 0x0, sizeof(T3));
    memset(T4, 0x0, sizeof(T4));
    memset(T5, 0x0, sizeof(T5));
    memset(T6, 0x0, sizeof(T6));
    memset(T7, 0x0, sizeof(T7));
    memset(T8, 0x0, sizeof(T8));
    int carry;
    NN_DIGIT one[MAX_P_DIGITS];
    memset(one, 0x0, sizeof(one));

    NN_ASSIGN_DIGIT(one, 1, P_DIGITS);

    NN_Assign(T1,x1,P_DIGITS);
    NN_Assign(T2,y1,P_DIGITS);
    NN_Assign(T3,z1,P_DIGITS);
    NN_Assign(T4,x2,P_DIGITS);
    NN_Assign(T5,y2,P_DIGITS);

    if(NN_Cmp(z2,one,P_DIGITS))
    {
        NN_Assign(T6,z2,P_DIGITS);
        NN_ModMult(T7,T6,T6,P,P_DIGITS);
        NN_ModMult(T1,T1,T7,P,P_DIGITS);     //U0
        NN_ModMult(T7,T6,T7,P,P_DIGITS);
        NN_ModMult(T2,T2,T7,P,P_DIGITS);     //S0
    }

    NN_ModMult(T7,T3,T3,P,P_DIGITS);
    NN_ModMult(T4,T4,T7,P,P_DIGITS);      //U0
    NN_ModMult(T7,T3,T7,P,P_DIGITS);
    NN_ModMult(T5,T5,T7,P,P_DIGITS);      //S1

    NN_Sub_ModP(T4,T1,T4,P,P_DIGITS);                    //W
    NN_Sub_ModP(T5,T2,T5,P,P_DIGITS);                    //R

    if(NN_Zero(T4,P_DIGITS))
    {
        if(NN_Zero(T5,P_DIGITS))   //return(0,0,0)
        {
            NN_AssignZero(x3,P_DIGITS);
            NN_AssignZero(y3,P_DIGITS);
            NN_AssignZero(z3,P_DIGITS);
            return;
        }
        else                       //return(1,1,0)
        {
            NN_ASSIGN_DIGIT(x3, 1, P_DIGITS);
            NN_ASSIGN_DIGIT(y3, 1, P_DIGITS);
            NN_AssignZero(z3,P_DIGITS);
            return;
        }
    }

    NN_Add_ModP(T8,T1,T1,P,P_DIGITS);
    NN_Sub_ModP(T1,T8,T4,P,P_DIGITS);              //T

    NN_Add_ModP(T8,T2,T2,P,P_DIGITS);
    NN_Sub_ModP(T2,T8,T5,P,P_DIGITS);              //M

    if(NN_Cmp(z2,one,P_DIGITS))
        NN_ModMult(T3,T3,T6,P,P_DIGITS);
    NN_ModMult(T3,T3,T4,P,P_DIGITS);   //Z2

    NN_ModMult(T7,T4,T4,P,P_DIGITS);
    NN_ModMult(T4,T4,T7,P,P_DIGITS);
    NN_ModMult(T7,T1,T7,P,P_DIGITS);
    NN_ModMult(T1,T5,T5,P,P_DIGITS);
    NN_Sub_ModP(T1,T1,T7,P,P_DIGITS);                 //X2

    NN_Add_ModP(T8,T1,T1,P,P_DIGITS);
    NN_Sub_ModP(T7,T7,T8,P,P_DIGITS);              //V

    NN_ModMult(T5,T5,T7,P,P_DIGITS);
    NN_ModMult(T4,T2,T4,P,P_DIGITS);

    NN_Sub_ModP(T2,T5,T4,P,P_DIGITS);      //2Y2

    if(T2[0]&0x1)               //为偶数时直接移位，奇数时加上P再移位
    {
        carry=NN_Add(T2,T2,P,P_DIGITS);
        NN_RShift(T2,T2,1,P_DIGITS);
        T2[P_DIGITS-1]=(carry<<31)^T2[P_DIGITS-1];
    }
    else
        NN_RShift(T2,T2,1,P_DIGITS);

    NN_Assign(x3,T1,P_DIGITS);
    NN_Assign(y3,T2,P_DIGITS);
    NN_Assign(z3,T3,P_DIGITS);

    return;
}


/**
	ECC point scalar multiplication alogrithm,the point representation is projective coordinate
	(x3,y3,z3)=k(x1,y1,z1)
*/
void ECC_kP_Pro(NN_DIGIT *x,NN_DIGIT *y,NN_DIGIT *k,unsigned int k_digits,
                NN_DIGIT *x1,NN_DIGIT *y1,NN_DIGIT *a,NN_DIGIT *P,unsigned int P_DIGITS)

{
    NN_DIGIT tem_x2[MAX_P_DIGITS],tem_y2[MAX_P_DIGITS],tem_z2[MAX_P_DIGITS],
    z[MAX_P_DIGITS],z1[MAX_P_DIGITS],tem1[MAX_P_DIGITS];
    NN_DIGIT k1[MAX_P_DIGITS+1],k3[MAX_P_DIGITS+1];
    NN_DIGIT y1_inv[MAX_P_DIGITS];
    memset(tem_x2, 0x0, sizeof(tem_x2));
    memset(tem_y2, 0x0, sizeof(tem_y2));
    memset(tem_z2, 0x0, sizeof(tem_z2));
    memset(z, 0x0, sizeof(z));
    memset(z1, 0x0, sizeof(z1));
    memset(tem1, 0x0, sizeof(tem1));
    memset(k1, 0x0, sizeof(k1));
    memset(k3, 0x0, sizeof(k3));
    memset(y1_inv, 0x0, sizeof(y1_inv));
    int j,carry=0,bits_num;

    carry=NN_Add(tem1,k,k,P_DIGITS);
    k3[P_DIGITS]=carry;
    carry=NN_Add(k3,tem1,k,P_DIGITS);
    k3[P_DIGITS]+=carry;                 //k3=3*k
    if(k_digits==P_DIGITS+1)
        k3[P_DIGITS]+=(k[P_DIGITS]*3);

    NN_Assign(k1,k,P_DIGITS);
    if(k_digits==P_DIGITS+1)
        k1[P_DIGITS]=k[P_DIGITS];
    else
        k1[P_DIGITS]=0;                  //k1={k,0}

    NN_Sub(y1_inv,P,y1,P_DIGITS);        //y1_inv=P-y1

    bits_num=NN_Bits(k3,P_DIGITS+1);

    NN_ASSIGN_DIGIT(z1,1, P_DIGITS);
    NN_Assign(x,x1,P_DIGITS);
    NN_Assign(y,y1,P_DIGITS);
    NN_Assign(z,z1,P_DIGITS);

    for(j=bits_num-2; j>0; j--)
    {
        ECC_Double_Pro(tem_x2,tem_y2,tem_z2,x,y,z,a,P,P_DIGITS);
        if(!((k1[j/32]>>(j%32))&0x00000001)&((k3[j/32]>>(j%32))&0x00000001))
            ECC_Add_Pro(x,y,z,tem_x2,tem_y2,tem_z2,x1,y1,z1,P,P_DIGITS);

        else if(((k1[j/32]>>(j%32))&0x00000001)&!((k3[j/32]>>(j%32))&0x00000001))
            ECC_Add_Pro(x,y,z,tem_x2,tem_y2,tem_z2,x1,y1_inv,z1,P,P_DIGITS);

        else
        {
            NN_Assign(x,tem_x2,P_DIGITS);
            NN_Assign(y,tem_y2,P_DIGITS);
            NN_Assign(z,tem_z2,P_DIGITS);
        }
    }

    NN_ModInv(tem1,z,P,P_DIGITS);
    NN_ModMult(z1,tem1,tem1,P,P_DIGITS);
    NN_ModMult(x,x,z1,P,P_DIGITS);

    NN_ModMult(z1,tem1,z1,P,P_DIGITS);
    NN_ModMult(y,y,z1,P,P_DIGITS);

    return;
}

/*******************
 ECC解密运算函数
***********************/
bool ECC_Decry(std::string& out_ming, const char *in_mi, unsigned int mi_len, NN_DIGIT *ttx,NN_DIGIT *tty,NN_DIGIT *key,ECC_Para *ECC_Para)
{
    unsigned int deal_count = 0;
    NN_DIGIT temx[MAX_P_DIGITS],temy[MAX_P_DIGITS];
    memset(temx, 0x0, sizeof(temx));
    memset(temy, 0x0, sizeof(temy));
    unsigned char des_key[8];
    unsigned char buffer[16],buffer_out[16];

    ECC_kP_Pro(temx,temy,key,MAX_P_DIGITS,ttx,tty,ECC_Para->EC_a,ECC_Para->P,ECC_Para->P_DIGITS);
    memcpy(des_key,temx,8);   //des密钥

    while(deal_count < mi_len)
    {
        if(mi_len - deal_count > 8)
        {
            memcpy(buffer, in_mi + deal_count, 8);
        }
        else
        {
            int left_len = mi_len - deal_count;
            memcpy(buffer, in_mi + deal_count, left_len);
            memset(buffer + left_len, 0x0, 8 - left_len);
        }

        if(Decrypt_ECB(buffer,8,des_key,buffer_out) < 0) return false;

        if(mi_len - deal_count > 8)
        {
            out_ming.append((char*)buffer_out, 8);
            deal_count += 8;
        }
        else
        {
            out_ming.append((char*)buffer_out, mi_len - deal_count);
            deal_count = mi_len;
        }
    }
    return true;
}

/*******************
 ECC加密运算函数
***********************/
bool ECC_Encry(std::string& out_mi,NN_DIGIT *ttx,NN_DIGIT *tty,
               const char *in_ming, unsigned ming_len, NN_DIGIT *kk,NN_DIGIT *Qx,NN_DIGIT *Qy,ECC_Para *ECC_Para)
{
    unsigned int deal_count = 0;
    NN_DIGIT temx[MAX_P_DIGITS],temy[MAX_P_DIGITS];
    memset(temx, 0x0, sizeof(temx));
    memset(temy, 0x0, sizeof(temy));
    unsigned char des_key[8], buffer[8], buffer_out[8];

    ECC_kP_Pro(ttx, tty,kk,MAX_P_DIGITS,ECC_Para->Gx,ECC_Para->Gy,
               ECC_Para->EC_a,ECC_Para->P,ECC_Para->P_DIGITS);

    ECC_kP_Pro(temx, temy, kk, MAX_P_DIGITS, Qx, Qy,
               ECC_Para->EC_a, ECC_Para->P, ECC_Para->P_DIGITS);

    memcpy(des_key, temx, 8);   //des密钥

    while(deal_count < ming_len)
    {
        if(ming_len - deal_count > 8)
        {
            memcpy(buffer, in_ming + deal_count, 8);
        }
        else
        {
            int left_len = ming_len - deal_count;
            memcpy(buffer, in_ming + deal_count, left_len);
            memset(buffer + left_len, 0x0, 8 - left_len);
        }

        if(Encrypt_ECB(buffer, 8, des_key, buffer_out) < 0) return false;

        if(ming_len - deal_count > 8)
        {
            out_mi.append((char*)buffer_out, 8);
            deal_count += 8;
        }
        else
        {
            out_mi.append((char*)buffer_out, ming_len - deal_count);
            deal_count = ming_len;

        }
    }
    return true;
}

/****************
说明：该工程中的函数可以实现ECC的密钥对的生成，签名和验证操作，
ECC参数可以更换，只需修改ECC_Para结构中的数据

在nn_global.h中的MAX_P_DIGITS定义了该工程支持的最大的ECC长度，例如设为8，则
可支持长度小于256的所有ECC操作，MAX_NN_DIGITS比MAX_P_DIGITS大1；

ECC_Para结构中，
P[MAX_P_DIGITS]为素数，
EC_a[MAX_P_DIGITS]为曲线参数a，
EC_b[MAX_P_DIGITS]为曲线参数b，
Gx[MAX_P_DIGITS]为基本点坐标，
Gy[MAX_P_DIGITS]为基本点坐标，
N[MAX_NN_DIGITS]为基本点的阶，
P_DIGITS为素数长度，
N_DIGITS为阶长度，有可能比P_DIGITS大1，
P_Bits为素数的比特数;

在进行密钥生成和签名操作时，需要首先对随机数生成函数进行初始化，
drbg_init(&rdbg_info)
drbg_instant(&rdbg_info,entropy_in)；


****************/

void ECC_Init224(ECC_Para *ECC_Para1)
{
    ECC_Para1->P[0]=0xffffe56d;
    ECC_Para1->P[1]=0xfffffffe;
    ECC_Para1->P[2]=0xffffffff;
    ECC_Para1->P[3]=0xffffffff;
    ECC_Para1->P[4]=0xffffffff;
    ECC_Para1->P[5]=0xffffffff;
    ECC_Para1->P[6]=0xffffffff;
    ECC_Para1->P[7]=0x0;

    ECC_Para1->EC_a[0]=0x0;
    ECC_Para1->EC_a[1]=0x0;
    ECC_Para1->EC_a[2]=0x0;
    ECC_Para1->EC_a[3]=0x0;
    ECC_Para1->EC_a[4]=0x0;
    ECC_Para1->EC_a[5]=0x0;
    ECC_Para1->EC_a[6]=0x0;
    ECC_Para1->EC_a[7]=0x0;

    ECC_Para1->EC_b[0]=0x5;
    ECC_Para1->EC_b[1]=0x0;
    ECC_Para1->EC_b[2]=0x0;
    ECC_Para1->EC_b[3]=0x0;
    ECC_Para1->EC_b[4]=0x0;
    ECC_Para1->EC_b[5]=0x0;
    ECC_Para1->EC_b[6]=0x0;
    ECC_Para1->EC_b[7]=0x0;

    ECC_Para1->Gx[0]=0xb6b7a45c;
    ECC_Para1->Gx[1]=0x0f7e650e;
    ECC_Para1->Gx[2]=0xe47075a9;
    ECC_Para1->Gx[3]=0x69a467e9;
    ECC_Para1->Gx[4]=0x30fc28a1;
    ECC_Para1->Gx[5]=0x4df099df;
    ECC_Para1->Gx[6]=0xa1455b33;
    ECC_Para1->Gx[7]=0x0;

    ECC_Para1->Gy[0]=0x556d61a5;
    ECC_Para1->Gy[1]=0xe2ca4bdb;
    ECC_Para1->Gy[2]=0xc0b0bd59;
    ECC_Para1->Gy[3]=0xf7e319f7;
    ECC_Para1->Gy[4]=0x82cafbd6;
    ECC_Para1->Gy[5]=0x7fba3442;
    ECC_Para1->Gy[6]=0x7e089fed;
    ECC_Para1->Gy[7]=0x0;

    ECC_Para1->N[0]=0x769fb1f7;
    ECC_Para1->N[1]=0xcaf0a971;
    ECC_Para1->N[2]=0xd2ec6184;
    ECC_Para1->N[3]=0x0001dce8;
    ECC_Para1->N[4]=0x0;
    ECC_Para1->N[5]=0x0;
    ECC_Para1->N[6]=0x0;
    ECC_Para1->N[7]=0x01;

    ECC_Para1->P_DIGITS=7;
    ECC_Para1->N_DIGITS=8;
    ECC_Para1->P_Bits=224;
}

void ECC_Init128(ECC_Para *ECC_Para1)
{
    ECC_Para1->P[0]=0xFFFFFFFF;
    ECC_Para1->P[1]=0xFFFFFFFF;
    ECC_Para1->P[2]=0xFFFFFFFF;
    ECC_Para1->P[3]=0xFFFFFFFD;
    ECC_Para1->P[4]=0x0;
    ECC_Para1->P[5]=0x0;
    ECC_Para1->P[6]=0x0;
    ECC_Para1->P[7]=0x0;

    ECC_Para1->EC_a[0]=0xFFFFFFFC;
    ECC_Para1->EC_a[1]=0xFFFFFFFF;
    ECC_Para1->EC_a[2]=0xFFFFFFFF;
    ECC_Para1->EC_a[3]=0xFFFFFFFD;
    ECC_Para1->EC_a[4]=0x0;
    ECC_Para1->EC_a[5]=0x0;
    ECC_Para1->EC_a[6]=0x0;
    ECC_Para1->EC_a[7]=0x0;

    ECC_Para1->EC_b[0]=0x2CEE5ED3;
    ECC_Para1->EC_b[1]=0xD824993C;
    ECC_Para1->EC_b[2]=0x1079F43D;
    ECC_Para1->EC_b[3]=0xE87579C1;
    ECC_Para1->EC_b[4]=0x0;
    ECC_Para1->EC_b[5]=0x0;
    ECC_Para1->EC_b[6]=0x0;
    ECC_Para1->EC_b[7]=0x0;

    ECC_Para1->Gx[0]=0xA52C5B86;
    ECC_Para1->Gx[1]=0x0C28607C;
    ECC_Para1->Gx[2]=0x8B899B2D;
    ECC_Para1->Gx[3]=0x161FF752;
    ECC_Para1->Gx[4]=0x0;
    ECC_Para1->Gx[5]=0x0;
    ECC_Para1->Gx[6]=0x0;
    ECC_Para1->Gx[7]=0x0;

    ECC_Para1->Gy[0]=0xDDED7A83;
    ECC_Para1->Gy[1]=0xC02DA292;
    ECC_Para1->Gy[2]=0x5BAFEB13;
    ECC_Para1->Gy[3]=0xCF5AC839;
    ECC_Para1->Gy[4]=0x0;
    ECC_Para1->Gy[5]=0x0;
    ECC_Para1->Gy[6]=0x0;
    ECC_Para1->Gy[7]=0x0;

    ECC_Para1->N[0]=0x9038A115;
    ECC_Para1->N[1]=0x75A30D1B;
    ECC_Para1->N[2]=0x00000000;
    ECC_Para1->N[3]=0xFFFFFFFE;
    ECC_Para1->N[4]=0x0;
    ECC_Para1->N[5]=0x0;
    ECC_Para1->N[6]=0x0;
    ECC_Para1->N[7]=0x0;

    ECC_Para1->P_DIGITS=4;
    ECC_Para1->N_DIGITS=4;
    ECC_Para1->P_Bits=128;
}

void ECC_Init256(ECC_Para *ECC_Para1)
{
    ECC_Para1->P[0]=0xffffffff;
    ECC_Para1->P[1]=0xffffffff;
    ECC_Para1->P[2]=0xffffffff;
    ECC_Para1->P[3]=0x00000000;
    ECC_Para1->P[4]=0x00000000;
    ECC_Para1->P[5]=0x00000000;
    ECC_Para1->P[6]=0x00000001;
    ECC_Para1->P[7]=0xffffffff;

    ECC_Para1->EC_a[0]=0xfffffffc;
    ECC_Para1->EC_a[1]=0xffffffff;
    ECC_Para1->EC_a[2]=0xffffffff;
    ECC_Para1->EC_a[3]=0x00000000;
    ECC_Para1->EC_a[4]=0x00000000;
    ECC_Para1->EC_a[5]=0x00000000;
    ECC_Para1->EC_a[6]=0x00000001;
    ECC_Para1->EC_a[7]=0xffffffff;

    ECC_Para1->EC_b[0]=0x27d2604b;
    ECC_Para1->EC_b[1]=0x3bce3c3e;
    ECC_Para1->EC_b[2]=0xcc53b0f6;
    ECC_Para1->EC_b[3]=0x651d06b0;
    ECC_Para1->EC_b[4]=0x769886bc;
    ECC_Para1->EC_b[5]=0xb3ebbd55;
    ECC_Para1->EC_b[6]=0xaa3a93e7;
    ECC_Para1->EC_b[7]=0x5ac635d8;


    ECC_Para1->Gx[0]=0xd898c296;
    ECC_Para1->Gx[1]=0xf4a13945;
    ECC_Para1->Gx[2]=0x2deb33a0;
    ECC_Para1->Gx[3]=0x77037d81;
    ECC_Para1->Gx[4]=0x63a440f2;
    ECC_Para1->Gx[5]=0xf8bce6e5;
    ECC_Para1->Gx[6]=0xe12c4247;
    ECC_Para1->Gx[7]=0x6b17d1f2;

    ECC_Para1->Gy[0]=0x37bf51f5;
    ECC_Para1->Gy[1]=0xcbb64068;
    ECC_Para1->Gy[2]=0x6b315ece;
    ECC_Para1->Gy[3]=0x2bce3357;
    ECC_Para1->Gy[4]=0x7c0f9e16;
    ECC_Para1->Gy[5]=0x8ee7eb4a;
    ECC_Para1->Gy[6]=0xfe1a7f9b;
    ECC_Para1->Gy[7]=0x4fe342e2;

    ECC_Para1->N[0]=0xfc632551;
    ECC_Para1->N[1]=0xf3b9cac2;
    ECC_Para1->N[2]=0xa7179e84;
    ECC_Para1->N[3]=0xbce6faad;
    ECC_Para1->N[4]=0xffffffff;
    ECC_Para1->N[5]=0xffffffff;
    ECC_Para1->N[6]=0x00000000;
    ECC_Para1->N[7]=0xffffffff;

    ECC_Para1->P_DIGITS=8;
    ECC_Para1->N_DIGITS=8;
    ECC_Para1->P_Bits=256;
}
