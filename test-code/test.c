#include <stdio.h>

int functionC() {
    int a = 0xbeef;
    return a;
    //printf("functionC called...");
}

int functionC2int(int p1, int p2) {
    int c;
    c =  p1 * 2;
    return c;
}

int functionC2long(long int p1, long int p2) {
    long int c;
    c =  p1 * 2;
    return c;
}
