#include <stdio.h>
#include <stdlib.h>

// returns the len bits of x that start at bit pos (bit 0 is the rightmost)
unsigned int getfield(unsigned int x, unsigned int pos, unsigned int len) {
    unsigned int mask = (1u << len) - 1;
    return (x >> pos) & mask;
}

int main(int argc, char *argv[]) {
    if (argc != 4) {
        fprintf(stderr, "Usage: field x pos len\n");
        return 1;
    }
    unsigned int x = (unsigned int) atoi(argv[1]);
    int pos = atoi(argv[2]);
    int len = atoi(argv[3]);
    if (pos < 0 || len < 1 || pos + len > 31) {
        fprintf(stderr, "field: need pos >= 0, len >= 1 and pos + len <= 31\n");
        return 1;
    }
    printf("%u\n", getfield(x, (unsigned int) pos, (unsigned int) len));
    return 0;
}
