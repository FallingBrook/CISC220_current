#include <stdio.h>
#include <stdlib.h>

void print(int n, const int a[n]) {
    for (int i = 0; i < n; i++) {
        if (i > 0) {
            printf(" ");
        }
        printf("%d", a[i]);
    }
    printf("\n");
}

int minidx(int n, const int a[n], int start) {
    int idx = start;
    for (int i = start + 1; i < n; i++) {
        if (a[i] < a[idx]) {
            idx = i;
        }
    }
    return idx;
}

int main(int argc, char *argv[]) {
    if (argc < 2 || argc > 101) {
        fprintf(stderr, "Usage: %s n1 n2 ... (1 to 100 integers)\n", argv[0]);
        return 1;
    }
    int n = argc - 1;
    int a[100];
    for (int i = 0; i < n; i++) {
        a[i] = atoi(argv[i + 1]);
    }
    for (int j = 0; j < n - 1; j++) {
        int idx = minidx(n, a, j);
        int tmp = a[j];
        a[j] = a[idx];
        a[idx] = tmp;
        printf("pass %d: ", j);
        print(n, a);
    }
    printf("sorted: ");
    print(n, a);
    return 0;
}
