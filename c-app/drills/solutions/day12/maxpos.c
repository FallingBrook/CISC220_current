#include <stdio.h>
#include <stdlib.h>

// Returns the maximum value in a; stores its index in *index.
int max(int a[], size_t count, size_t *index) {
    int hi = a[0];
    size_t i_hi = 0;
    for (size_t i = 1; i < count; i++) {
        if (a[i] > hi) {
            hi = a[i];
            i_hi = i;
        }
    }
    *index = i_hi;
    return hi;
}

int main(int argc, char *argv[]) {
    if (argc < 2 || argc > 101) {
        fprintf(stderr, "usage: %s n1 [n2 ...] (at most 100 integers)\n", argv[0]);
        return 1;
    }
    int a[100];
    size_t n = argc - 1;
    for (size_t i = 0; i < n; i++) {
        a[i] = atoi(argv[i + 1]);
    }
    size_t idx;
    int big = max(a, n, &idx);
    printf("max = %d, index = %zu\n", big, idx);
    return 0;
}
