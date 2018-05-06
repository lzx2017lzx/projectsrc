#include<stdio.h>
#define abc(a,b,c) a ## b ## c
typedef int int23;

int main(int argc, char *argv[])
{

    abc(int,2,3) a;
    a=20;
    return 0;
}

