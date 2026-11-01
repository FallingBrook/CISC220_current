// fits.c: which integer types can hold a value?
#include <limits.h>
#include <stdio.h>
#include <stdlib.h>

void report(const char name[], int ok) {
    if (ok) {
        printf("%s: yes\n", name);
    } else {
        printf("%s: no\n", name);
    }
}

int main(int argc, char *argv[]) {
    if (argc != 2) {
        fprintf(stderr, "Usage: fits n\n");
        return 1;
    }
    long long n = atoll(argv[1]);
    report("signed char", n >= SCHAR_MIN && n <= SCHAR_MAX);
    report("unsigned char", n >= 0 && n <= UCHAR_MAX);
    report("short", n >= SHRT_MIN && n <= SHRT_MAX);
    report("int", n >= INT_MIN && n <= INT_MAX);
    report("unsigned int", n >= 0 && n <= UINT_MAX);
    return 0;
}
