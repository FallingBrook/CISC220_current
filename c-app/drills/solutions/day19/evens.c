#include <stdio.h>
#include <stdlib.h>

int main(int argc, char *argv[]) {
    size_t cap = 1;
    size_t n = 0;
    int *a = malloc(cap * sizeof(int));
    if (!a) {
        fprintf(stderr, "out of memory\n");
        return 1;
    }
    for (int i = 1; i < argc; i++) {
        int v = atoi(argv[i]);
        if (v % 2 == 0) {
            if (n == cap) {
                int *tmp = realloc(a, 2 * cap * sizeof(int));
                if (!tmp) {
                    free(a);
                    fprintf(stderr, "out of memory\n");
                    return 1;
                }
                a = tmp;
                cap = 2 * cap;
                printf("capacity %zu\n", cap);
            }
            a[n] = v;
            n++;
        }
    }
    for (size_t i = 0; i < n; i++) {
        if (i > 0) {
            printf(" ");
        }
        printf("%d", a[i]);
    }
    printf("\ncount = %zu\n", n);
    free(a);
    return 0;
}
