// squares.c: a table of squares and cubes with fixed-width columns

#include <stdio.h>

int main(void) {
    printf(" n    n^2    n^3\n");
    for (int n = 1; n <= 12; n++) {
        printf("%2d %6d %6d\n", n, n * n, n * n * n);
    }
    return 0;
}
