// binvalue.c: the unsigned value of an 8-character binary string (most significant bit first)
#include <stdio.h>

int binvalue(const char str[static 8]) {
    int value = 0;
    for (int i = 0; i < 8; i++) {
        value = value * 2 + (str[i] - '0');
    }
    return value;
}

int main(int argc, char *argv[]) {
    if (argc != 2) {
        fprintf(stderr, "usage: %s bbbbbbbb\n", argv[0]);
        return 1;
    }
    printf("%d\n", binvalue(argv[1]));
    return 0;
}
