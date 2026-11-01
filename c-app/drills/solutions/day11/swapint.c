// swapint.c: swap two ints through pointers
#include <stdio.h>
#include <stdlib.h>

void swap(int *x, int *y) {
    int tmp = *x;
    *x = *y;
    *y = tmp;
}

int main(int argc, char *argv[]) {
    if (argc != 3) {
        fprintf(stderr, "Usage: swapint a b\n");
        return 1;
    }
    int a = atoi(argv[1]);
    int b = atoi(argv[2]);
    printf("before: a = %d, b = %d\n", a, b);
    swap(&a, &b);
    printf("after: a = %d, b = %d\n", a, b);
    return 0;
}
