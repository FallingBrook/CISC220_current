#include <stdio.h>
#include <stdlib.h>

int main(int argc, char *argv[]) {
    if (argc != 2) {
        fprintf(stderr, "usage: %s n   (n >= 0)\n", argv[0]);
        return 1;
    }
    int n = atoi(argv[1]);
    if (n < 0) {
        fprintf(stderr, "%s: n must not be negative\n", argv[0]);
        return 1;
    }
    unsigned int x = n;
    int count = 0;
    while (x != 0) {
        count = count + (x & 1u);
        x = x >> 1;
    }
    printf("%d\n", count);
    return 0;
}
