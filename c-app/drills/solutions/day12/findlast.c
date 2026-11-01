#include <stdio.h>
#include <stdlib.h>

// Returns a pointer to the LAST element of arr equal to target, or NULL.
int *find_last(int *arr, size_t n, int target) {
    int *found = NULL;
    for (int *p = arr; p < arr + n; p++) {
        if (*p == target) {
            found = p;
        }
    }
    return found;
}

int main(int argc, char *argv[]) {
    if (argc < 3 || argc > 102) {
        fprintf(stderr, "usage: %s target n1 [n2 ...] (at most 100 integers)\n", argv[0]);
        return 1;
    }
    int target = atoi(argv[1]);
    int a[100];
    size_t n = argc - 2;
    for (size_t i = 0; i < n; i++) {
        a[i] = atoi(argv[i + 2]);
    }
    int *p = find_last(a, n, target);
    if (p == NULL) {
        printf("%d not found\n", target);
        return 1;
    }
    printf("%d found at index %td\n", target, p - a);
    return 0;
}
