#include <stdio.h>
#include <stdlib.h>

// Stores a / b in *quot and a % b in *rem.
void divide(int a, int b, int *quot, int *rem) {
    *quot = a / b;
    *rem = a % b;
}

int main(int argc, char *argv[]) {
    if (argc != 3) {
        fprintf(stderr, "usage: %s a b\n", argv[0]);
        return 1;
    }
    int a = atoi(argv[1]);
    int b = atoi(argv[2]);
    if (b == 0) {
        fprintf(stderr, "%s: cannot divide by zero\n", argv[0]);
        return 1;
    }
    int q;
    int r;
    divide(a, b, &q, &r);
    printf("%d / %d = %d remainder %d\n", a, b, q, r);
    return 0;
}
