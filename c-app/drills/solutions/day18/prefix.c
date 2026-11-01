#include <stdio.h>
#include <stdlib.h>

// Returns a new array p of n doubles where p[i] is the average of a[0] ... a[i].
// The caller must free it. Returns NULL if out of memory.
double *prefix_avg(int a[], size_t n) {
    double *p = malloc(n * sizeof(double));
    if (!p) {
        return NULL;
    }
    long sum = 0;
    for (size_t i = 0; i < n; i++) {
        sum += a[i];
        p[i] = (double) sum / (i + 1);
    }
    return p;
}

int main(int argc, char *argv[]) {
    if (argc < 2) {
        fprintf(stderr, "usage: %s int...\n", argv[0]);
        return 1;
    }
    size_t n = argc - 1;
    int *a = malloc(n * sizeof(int));
    if (!a) {
        fprintf(stderr, "out of memory\n");
        return 1;
    }
    for (size_t i = 0; i < n; i++) {
        a[i] = atoi(argv[i + 1]);
    }
    double *avg = prefix_avg(a, n);
    if (!avg) {
        free(a);
        fprintf(stderr, "out of memory\n");
        return 1;
    }
    for (size_t i = 0; i < n; i++) {
        printf("%.2f\n", avg[i]);
    }
    free(a);
    free(avg);
    return 0;
}
