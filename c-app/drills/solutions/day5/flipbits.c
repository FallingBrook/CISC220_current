// flipbits.c: print the ones' complement negation (every bit flipped) of an 8-character binary string
#include <stdio.h>

void flip(const char in[static 8], char out[static 9]) {
    for (int i = 0; i < 8; i++) {
        if (in[i] == '0') {
            out[i] = '1';
        } else {
            out[i] = '0';
        }
    }
    out[8] = '\0';
}

int main(int argc, char *argv[]) {
    if (argc != 2) {
        fprintf(stderr, "usage: %s bbbbbbbb\n", argv[0]);
        return 1;
    }
    char out[9];
    flip(argv[1], out);
    printf("%s\n", out);
    return 0;
}
