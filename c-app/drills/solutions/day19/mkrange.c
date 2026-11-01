#include <stdio.h>
#include <stdlib.h>

// Allocates exactly enough ints for lo, lo + step, ... (values <= hi), stores the
// array's address in *out and returns how many values there are. If step <= 0 or
// lo > hi (or malloc fails), sets *out to NULL and returns 0.
size_t make_range(int lo, int hi, int step, int **out) {
    *out = NULL;
    if (step <= 0 || lo > hi) {
        return 0;
    }
    size_t n = (size_t) ((hi - lo) / step) + 1;
    int *a = malloc(n * sizeof(int));
    if (!a) {
        return 0;
    }
    for (size_t i = 0; i < n; i++) {
        a[i] = lo + (int) i * step;
    }
    *out = a;
    return n;
}

int main(int argc, char *argv[]) {
    if (argc != 4) {
        fprintf(stderr, "usage: %s lo hi step\n", argv[0]);
        return 1;
    }
    int *r;
    size_t n = make_range(atoi(argv[1]), atoi(argv[2]), atoi(argv[3]), &r);
    if (n == 0) {
        printf("empty\n");
        return 0;
    }
    for (size_t i = 0; i < n; i++) {
        if (i > 0) {
            printf(" ");
        }
        printf("%d", r[i]);
    }
    printf("\nn = %zu\n", n);
    free(r);
    return 0;
}
