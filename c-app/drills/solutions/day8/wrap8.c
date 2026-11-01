// wrap8.c: unsigned char arithmetic wraps around modulo 256
#include <stdio.h>
#include <stdlib.h>

int main(int argc, char *argv[]) {
    if (argc != 3) {
        fprintf(stderr, "Usage: wrap8 a b\n");
        return 1;
    }
    int ia = atoi(argv[1]);
    int ib = atoi(argv[2]);
    if (ia < 0 || ia > 255 || ib < 0 || ib > 255) {
        fprintf(stderr, "wrap8: a and b must be 0..255\n");
        return 1;
    }
    unsigned char a = ia;
    unsigned char b = ib;
    unsigned char sum = a + b;
    unsigned char diff = a - b;
    unsigned char prod = a * b;
    printf("%d %d %d\n", sum, diff, prod);
    return 0;
}
