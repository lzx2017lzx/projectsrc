#ifndef ECC_GLOBAL_H_INCLUDED
#define ECC_GLOBAL_H_INCLUDED

/* NN.H - header file for NN.C
*/
//#include "socket_server.h"
/* Copyright (C) RSA Laboratories, a division of RSA Data Security,
Inc., created 1991. All rights reserved.
*/

/* Type definitions.
*/
//typedef unsigned long int NN_DIGIT;
typedef unsigned int NN_DIGIT;
typedef unsigned short int NN_HALF_DIGIT;
typedef	unsigned char *POINTER;

/* Constants.

Note: MAX_NN_DIGITS is long enough to hold any RSA modulus, plus
one more digit as required by R_GeneratePEMKeys (for n and phiN,
whose lengths must be even). All natural numbers have at most
MAX_NN_DIGITS digits, except for double-length intermediate values
in NN_Mult (t), NN_ModMult (t), NN_ModInv (w), and NN_Div (c).
*/
/* Length of digit in bits */
#define NN_DIGIT_BITS 32
#define NN_HALF_DIGIT_BITS 16
/* Length of digit in bytes */
#define NN_DIGIT_LEN (NN_DIGIT_BITS / 8)
/* Maximum length in digits */
#define MAX_NN_DIGITS 8
#define MAX_P_DIGITS 8
/* Maximum digits */
#define MAX_NN_DIGIT 0xffffffff
#define MAX_NN_HALF_DIGIT 0xffff

#define HashBits  160
#define HashLen   HashBits/NN_DIGIT_BITS       //HASH结果的长度

#endif // ECC_GLOBAL_H_INCLUDED
