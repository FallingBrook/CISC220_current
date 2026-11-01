#include <stdio.h>
#include <stdlib.h>

// returns 0 + 1 + ... + n
unsigned int sum_of(unsigned int n) {
    unsigned int sum = 0;   // local, so it starts at 0 on every call
    for (unsigned int i = 0; i <= n; i++) {
        sum += i;
    }
    return sum;
}

int main(int argc, char *argv[]) {
    if (argc < 2) {
        fprintf(stderr, "Usage: sums n ...\n");
        return 1;
    }
    for (int i = 1; i < argc; i++) {
        unsigned int n = atoi(argv[i]);
        printf("sum_of(%u) = %u\n", n, sum_of(n));
    }
    return 0;
}
