#include <stdio.h>
#include <stdlib.h>

int main(int argc, char *argv[]) {
    if (argc < 3 || argc > 102) {
        fprintf(stderr, "Usage: %s k n1 n2 ... (1 to 100 integers)\n", argv[0]);
        return 1;
    }
    int k = atoi(argv[1]);
    if (k < 0) {
        fprintf(stderr, "k must not be negative\n");
        return 1;
    }
    int n = argc - 2;
    int a[100];
    int b[100];
    for (int i = 0; i < n; i++) {
        a[i] = atoi(argv[i + 2]);
    }
    k = k % n;
    for (int i = 0; i < n; i++) {
        b[i] = a[(i + k) % n];
    }
    for (int i = 0; i < n; i++) {
        a[i] = b[i];
    }
    for (int i = 0; i < n; i++) {
        if (i > 0) {
            printf(" ");
        }
        printf("%d", a[i]);
    }
    printf("\n");
    return 0;
}
