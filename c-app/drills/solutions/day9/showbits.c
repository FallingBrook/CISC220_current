#include <stdio.h>
#include <stdlib.h>

int main(int argc, char *argv[]) {
    if (argc != 2) {
        fprintf(stderr, "usage: %s n   (n from 0 to 255)\n", argv[0]);
        return 1;
    }
    int n = atoi(argv[1]);
    if (n < 0 || n > 255) {
        fprintf(stderr, "%s: n must be from 0 to 255\n", argv[0]);
        return 1;
    }
    unsigned int x = n;
    printf("%u 0x%02X ", x, x);
    for (int i = 7; i >= 0; i--) {
        printf("%u", (x >> i) & 1u);
    }
    printf("\n");
    return 0;
}
