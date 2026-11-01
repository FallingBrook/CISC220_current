#include <stdio.h>
#include <stdlib.h>

int main(int argc, char *argv[]) {
    if (argc < 2 || argc > 101) {
        fprintf(stderr, "usage: %s n1 [n2 ...] (at most 100 integers)\n", argv[0]);
        return 1;
    }
    int a[100];
    int n = argc - 1;
    for (int i = 0; i < n; i++) {
        a[i] = atoi(argv[i + 1]);
    }
    // elements 0, 2, 4, ... using a pointer
    for (int *p = a; p < a + n; p += 2) {
        printf("%d\n", *p);
    }
    // sum of all elements using a pointer
    int sum = 0;
    for (int *p = a; p < a + n; p++) {
        sum += *p;
    }
    printf("sum = %d\n", sum);
    return 0;
}
