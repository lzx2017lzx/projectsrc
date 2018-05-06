#ifndef ECC_NN_H_INCLUDED
#define ECC_NN_H_INCLUDED
/* NN.H - header file for NN.C
 */
//#include "socket_server.h"
/* Copyright (C) RSA Laboratories, a division of RSA Data Security,
     Inc., created 1991. All rights reserved.
 */

#include <string.h>
#include "ecc_global.h"
/* Macros.
 */
#ifndef _Nn_

#define LOW_HALF(x) ((x) & MAX_NN_HALF_DIGIT)
#define HIGH_HALF(x) (((x) >> NN_HALF_DIGIT_BITS) & MAX_NN_HALF_DIGIT)
#define TO_HIGH_HALF(x) (((NN_DIGIT)(x)) << NN_HALF_DIGIT_BITS)
#define DIGIT_MSB(x) (unsigned int)(((x) >> (NN_DIGIT_BITS - 1)) & 1)
#define DIGIT_2MSB(x) (unsigned int)(((x) >> (NN_DIGIT_BITS - 2)) & 3)

/* CONVERSIONS
   NN_Decode (a, digits, b, len)   Decodes character string b into a.
   NN_Encode (a, len, b, digits)   Encodes a into character string b.

   ASSIGNMENTS
   NN_Assign (a, b, digits)        Assigns a = b.
   NN_ASSIGN_DIGIT (a, b, digits)  Assigns a = b, where b is a digit.
   NN_AssignZero (a, b, digits)    Assigns a = 0.
   NN_Assign2Exp (a, b, digits)    Assigns a = 2^b.

   ARITHMETIC OPERATIONS
   NN_Add (a, b, c, digits)        Computes a = b + c.
   NN_Sub (a, b, c, digits)        Computes a = b - c.
   NN_Mult (a, b, c, digits)       Computes a = b * c.
   NN_LShift (a, b, c, digits)     Computes a = b * 2^c.
   NN_RShift (a, b, c, digits)     Computes a = b / 2^c.
   NN_Div (a, b, c, cDigits, d, dDigits)  Computes a = c div d and b = c mod d.

   NUMBER THEORY
   NN_Mod (a, b, bDigits, c, cDigits)  Computes a = b mod c.
   NN_ModMult (a, b, c, d, digits) Computes a = b * c mod d.
   NN_ModExp (a, b, c, cDigits, d, dDigits)  Computes a = b^c mod d.
   NN_ModInv (a, b, c, digits)     Computes a = 1/b mod c.
   NN_Gcd (a, b, c, digits)        Computes a = gcd (b, c).

   OTHER OPERATIONS
   NN_EVEN (a, digits)             Returns 1 iff a is even.
   NN_Cmp (a, b, digits)           Returns sign of a - b.
   NN_EQUAL (a, digits)            Returns 1 iff a = b.
   NN_Zero (a, digits)             Returns 1 iff a = 0.
   NN_Digits (a, digits)           Returns significant length of a in digits.
   NN_Bits (a, digits)             Returns significant length of a in bits.
 */
/*
在下面的函数中，注意对运算数长度有要求的函数，尤其是下面几个，防止出错
1、void NN_Assign2Exp(NN_DIGIT *, unsigned int, unsigned int);
2、void NN_Mult(NN_DIGIT *, NN_DIGIT *, NN_DIGIT *, unsigned int);
3、void NN_Div(NN_DIGIT *, NN_DIGIT *, NN_DIGIT *, unsigned int, NN_DIGIT *, unsigned int);
4、void NN_ModInv(NN_DIGIT *, NN_DIGIT *, NN_DIGIT *, unsigned int);
*/

void NN_Decode(NN_DIGIT *, unsigned int, unsigned char *, unsigned int);
void NN_Encode(unsigned char *, unsigned int, NN_DIGIT *, unsigned int);

void NN_Assign(NN_DIGIT *, NN_DIGIT *, unsigned int);
void NN_AssignZero(NN_DIGIT *, unsigned int);
void NN_Assign2Exp(NN_DIGIT *, unsigned int, unsigned int);

NN_DIGIT NN_Add(NN_DIGIT *, NN_DIGIT *, NN_DIGIT *, unsigned int);
NN_DIGIT NN_Sub(NN_DIGIT *, NN_DIGIT *, NN_DIGIT *, unsigned int);
void NN_Mult(NN_DIGIT *, NN_DIGIT *, NN_DIGIT *, unsigned int);
void NN_Div(NN_DIGIT *, NN_DIGIT *, NN_DIGIT *, unsigned int, NN_DIGIT *, unsigned int);
NN_DIGIT NN_LShift(NN_DIGIT *, NN_DIGIT *, unsigned int, unsigned int);
NN_DIGIT NN_RShift(NN_DIGIT *, NN_DIGIT *, unsigned int, unsigned int);

void NN_Mod(NN_DIGIT *, NN_DIGIT *, unsigned int, NN_DIGIT *, unsigned int);
void NN_ModMult(NN_DIGIT *, NN_DIGIT *, NN_DIGIT *, NN_DIGIT *, unsigned int);
void NN_ModExp(NN_DIGIT *, NN_DIGIT *, NN_DIGIT *, unsigned int, NN_DIGIT *, unsigned int);
void NN_ModInv(NN_DIGIT *, NN_DIGIT *, NN_DIGIT *, unsigned int);
void NN_Gcd(NN_DIGIT *, NN_DIGIT *, NN_DIGIT *, unsigned int);

int NN_Cmp(NN_DIGIT *, NN_DIGIT *, unsigned int);
int NN_Zero(NN_DIGIT *, unsigned int);
unsigned int NN_Bits(NN_DIGIT *, unsigned int);
unsigned int NN_Digits(NN_DIGIT *, unsigned int);

NN_DIGIT NN_AddDigitMult(NN_DIGIT *, NN_DIGIT *, NN_DIGIT, NN_DIGIT *, unsigned int);
NN_DIGIT NN_SubDigitMult(NN_DIGIT *, NN_DIGIT *, NN_DIGIT, NN_DIGIT *, unsigned int);

void NN_DigitMult (NN_DIGIT a[2],NN_DIGIT b,NN_DIGIT c);
void NN_DigitDiv (NN_DIGIT *a,NN_DIGIT b[2],NN_DIGIT c);


#define NN_ASSIGN_DIGIT(a, b, digits) {NN_AssignZero (a, digits); a[0] = b;}
#define NN_EQUAL(a, b, digits) (! NN_Cmp (a, b, digits))
#define NN_EVEN(a, digits) (((digits) == 0) || ! (a[0] & 1))
#endif

#endif // ECC_NN_H_INCLUDED
