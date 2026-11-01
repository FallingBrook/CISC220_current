// twos.c: value of an 8-bit two's complement binary string
#include <stdio.h>
#include <string.h>

int main(int argc, char *argv[]) {
    if (argc != 2 || strlen(argv[1]) != 8) {
        fprintf(stderr, "Usage: twos bbbbbbbb (8 bits)\n");
        return 1;
    }
    const char *bits = argv[1];
    // the leftmost bit is worth -128, the others 64, 32, ..., 1
    int value = -128 * (bits[0] - '0');
    int place = 64;
    for (int i = 1; i < 8; i++) {
        value = value + place * (bits[i] - '0');
        place = place / 2;
    }
    printf("%d\n", value);
    return 0;
}
