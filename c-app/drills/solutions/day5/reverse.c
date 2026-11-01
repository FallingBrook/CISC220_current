// reverse.c: reverse the integer arguments with a function that works in place
#include <stdio.h>
#include <stdlib.h>

void reverse(int a[], size_t n) {
    for (size_t i = 0; i < n / 2; i++) {
        int tmp = a[i];
        a[i] = a[n - 1 - i];
        a[n - 1 - i] = tmp;
    }
}

int main(int argc, char *argv[]) {
    if (argc < 2) {
        fprintf(stderr, "usage: %s n1 n2 ...\n", argv[0]);
        return 1;
    }
    int a[100];
    size_t n = argc - 1;
    for (size_t i = 0; i < n; i++) {
        a[i] = atoi(argv[i + 1]);
    }
    reverse(a, n);
    for (size_t i = 0; i < n; i++) {
        if (i > 0) {
            printf(" ");
        }
        printf("%d", a[i]);
    }
    printf("\n");
    return 0;
}
