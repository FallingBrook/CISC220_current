#include <stdio.h>
#include <stdlib.h>

int main(int argc, char *argv[]) {
    if (argc != 2) {
        fprintf(stderr, "Usage: bits n   (0 <= n <= 255)\n");
        return 1;
    }
    int n = atoi(argv[1]);
    if (n < 0 || n > 255) {
        fprintf(stderr, "bits: %s is not between 0 and 255\n", argv[1]);
        return 1;
    }
    unsigned int x = (unsigned int) n;
    int ones = 0;
    for (int i = 7; i >= 0; i--) {
        unsigned int bit = (x >> i) & 1u;
        printf("%u", bit);
        ones += bit;
    }
    printf(" %d\n", ones);
    return 0;
}
