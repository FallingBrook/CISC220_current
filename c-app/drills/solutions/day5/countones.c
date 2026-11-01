// countones.c: count the 1 bits in an 8-character binary string
#include <stdio.h>

int countones(const char str[static 8]) {
    int count = 0;
    for (int i = 0; i < 8; i++) {
        if (str[i] == '1') {
            count++;
        }
    }
    return count;
}

int main(int argc, char *argv[]) {
    if (argc != 2) {
        fprintf(stderr, "usage: %s bbbbbbbb\n", argv[0]);
        return 1;
    }
    printf("%d\n", countones(argv[1]));
    return 0;
}
