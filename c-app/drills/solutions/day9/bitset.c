#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>

void printb(uint8_t x) {
    for (int i = 7; i >= 0; i--) {
        printf("%d", (x >> i) & 1);
    }
}

int main(int argc, char *argv[]) {
    if (argc != 4) {
        fprintf(stderr, "usage: %s t|s|c|f k x\n", argv[0]);
        return 1;
    }
    int k = atoi(argv[2]);
    int n = atoi(argv[3]);
    if (k < 0 || k > 7 || n < 0 || n > 255) {
        fprintf(stderr, "%s: k must be 0 to 7 and x must be 0 to 255\n", argv[0]);
        return 1;
    }
    char op = argv[1][0];
    if (op == '\0' || argv[1][1] != '\0') {
        op = '?';                       // more than one character: not a valid operation
    }
    uint8_t x = n;
    uint8_t mask = 1u << k;
    if (op == 't') {
        printf("%d\n", (x & mask) != 0);
        return 0;
    }
    if (op == 's') {
        x = x | mask;
    }
    else if (op == 'c') {
        x = x & ~mask;
    }
    else if (op == 'f') {
        x = x ^ mask;
    }
    else {
        fprintf(stderr, "%s: unknown operation %s\n", argv[0], argv[1]);
        return 1;
    }
    printb(x);
    printf(" %d\n", x);
    return 0;
}
