// tobin8.c: 8-bit two's complement pattern of an integer from -128 to 127
#include <stdio.h>
#include <stdlib.h>

int main(int argc, char *argv[]) {
    if (argc != 2) {
        fprintf(stderr, "Usage: tobin8 n\n");
        return 1;
    }
    int n = atoi(argv[1]);
    if (n < -128 || n > 127) {
        fprintf(stderr, "tobin8: %d is not in -128..127\n", n);
        return 1;
    }
    unsigned char u = n;        // a negative n becomes n + 256
    char bits[9];
    for (int i = 7; i >= 0; i--) {
        bits[i] = '0' + u % 2;
        u = u / 2;
    }
    bits[8] = '\0';
    printf("%s\n", bits);
    return 0;
}
