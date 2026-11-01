#include <stdio.h>
#include <stdlib.h>

void reverse(int n, int a[n]) {
    int i = 0;
    int j = n - 1;
    while (i < j) {
        int tmp = a[i];
        a[i] = a[j];
        a[j] = tmp;
        i++;
        j--;
    }
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
    reverse(n, a);
    for (int i = 0; i < n; i++) {
        if (i > 0) {
            printf(" ");
        }
        printf("%d", a[i]);
    }
    printf("\n");
    return 0;
}
