// clamp.c: change the caller's variable through a pointer
#include <stdio.h>
#include <stdlib.h>

// if *x is below lo, set it to lo; if above hi, set it to hi
void clamp(int *x, int lo, int hi) {
    if (*x < lo) {
        *x = lo;
    } else if (*x > hi) {
        *x = hi;
    }
}

int main(int argc, char *argv[]) {
    if (argc != 4) {
        fprintf(stderr, "Usage: clamp x lo hi\n");
        return 1;
    }
    int x = atoi(argv[1]);
    int lo = atoi(argv[2]);
    int hi = atoi(argv[3]);
    if (lo > hi) {
        fprintf(stderr, "clamp: lo must not be greater than hi\n");
        return 1;
    }
    clamp(&x, lo, hi);
    printf("%d\n", x);
    return 0;
}
