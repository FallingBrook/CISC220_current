#include <stdio.h>
#include <stdlib.h>

int main(int argc, char *argv[]) {
    if (argc < 2) {
        fprintf(stderr, "usage: %s int...\n", argv[0]);
        return 1;
    }
    size_t n = argc - 1;
    int *a = malloc(n * sizeof(int));
    if (!a) {
        fprintf(stderr, "out of memory\n");
        return 1;
    }
    for (size_t i = 0; i < n; i++) {
        a[i] = atoi(argv[i + 1]);
    }
    for (size_t i = n; i > 0; i--) {
        printf("%d\n", a[i - 1]);
    }
    free(a);
    return 0;
}
