// adddec.c: long addition of two equal-length decimal digit strings
#include <stdio.h>
#include <string.h>

int main(int argc, char *argv[]) {
    if (argc != 3) {
        fprintf(stderr, "usage: %s digits digits\n", argv[0]);
        return 1;
    }
    size_t n = strlen(argv[1]);
    if (n != strlen(argv[2]) || n == 0 || n > 50) {
        fprintf(stderr, "%s: the numbers must have the same length (1 to 50 digits)\n", argv[0]);
        return 1;
    }
    int z[50];
    int carry = 0;
    for (size_t k = n; k > 0; k--) {
        size_t i = k - 1;
        int s = (argv[1][i] - '0') + (argv[2][i] - '0') + carry;
        z[i] = s % 10;
        carry = s / 10;
    }
    if (carry != 0) {
        printf("%d", carry);
    }
    for (size_t i = 0; i < n; i++) {
        printf("%d", z[i]);
    }
    printf("\n");
    return 0;
}
