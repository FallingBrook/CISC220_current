#include <stdio.h>
#include <stdlib.h>

int main(int argc, char *argv[]) {
    if (argc < 2) {
        fprintf(stderr, "usage: %s k value...\n", argv[0]);
        return 1;
    }
    int k = atoi(argv[1]);
    if (k < 1 || k > 20) {
        fprintf(stderr, "k must be from 1 to 20\n");
        return 1;
    }
    unsigned int *count = calloc(k, sizeof(unsigned int));
    if (!count) {
        fprintf(stderr, "out of memory\n");
        return 1;
    }
    unsigned int other = 0;
    for (int i = 2; i < argc; i++) {
        int v = atoi(argv[i]);
        if (v >= 0 && v < k) {
            count[v]++;
        } else {
            other++;
        }
    }
    for (int i = 0; i < k; i++) {
        printf("%d: %u\n", i, count[i]);
    }
    printf("other: %u\n", other);
    free(count);
    return 0;
}
