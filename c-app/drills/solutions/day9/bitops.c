#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>

void printb(uint8_t x) {
    for (int i = 7; i >= 0; i--) {
        printf("%d", (x >> i) & 1);
    }
}

void show(const char label[], uint8_t v) {
    printf("%s = ", label);
    printb(v);
    printf(" = %d\n", v);
}

int main(int argc, char *argv[]) {
    if (argc != 3) {
        fprintf(stderr, "usage: %s a b   (each from 0 to 255)\n", argv[0]);
        return 1;
    }
    int a = atoi(argv[1]);
    int b = atoi(argv[2]);
    if (a < 0 || a > 255 || b < 0 || b > 255) {
        fprintf(stderr, "%s: a and b must be from 0 to 255\n", argv[0]);
        return 1;
    }
    uint8_t x = a;
    uint8_t y = b;
    show("a    ", x);
    show("b    ", y);
    show("a & b", x & y);
    show("a | b", x | y);
    show("a ^ b", x ^ y);
    show("~a   ", ~x);
    return 0;
}
