// sort3.c: put three ints in increasing order using swap
#include <stdio.h>
#include <stdlib.h>

void swap(int *x, int *y) {
    int tmp = *x;
    *x = *y;
    *y = tmp;
}

// afterwards *a <= *b <= *c
void sort3(int *a, int *b, int *c) {
    if (*a > *b) {
        swap(a, b);
    }
    if (*b > *c) {
        swap(b, c);
    }
    if (*a > *b) {
        swap(a, b);
    }
}

int main(int argc, char *argv[]) {
    if (argc != 4) {
        fprintf(stderr, "Usage: sort3 a b c\n");
        return 1;
    }
    int a = atoi(argv[1]);
    int b = atoi(argv[2]);
    int c = atoi(argv[3]);
    sort3(&a, &b, &c);
    printf("%d %d %d\n", a, b, c);
    return 0;
}
