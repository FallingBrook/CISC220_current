#include <stdio.h>
#include <stdlib.h>

int main(int argc, char *argv[]) {
    if (argc != 2) {
        fprintf(stderr, "usage: %s n (1 to 1000)\n", argv[0]);
        return 1;
    }
    int n = atoi(argv[1]);
    if (n < 1 || n > 1000) {
        fprintf(stderr, "usage: %s n (1 to 1000)\n", argv[0]);
        return 1;
    }
    int *sq = malloc(n * sizeof(int));
    if (!sq) {
        fprintf(stderr, "out of memory\n");
        return 1;
    }
    for (int i = 0; i < n; i++) {
        sq[i] = (i + 1) * (i + 1);
    }
    long sum = 0;
    for (int i = 0; i < n; i++) {
        if (i > 0) {
            printf(" ");
        }
        printf("%d", sq[i]);
        sum += sq[i];
    }
    printf("\nsum = %ld\n", sum);
    free(sq);
    return 0;
}
