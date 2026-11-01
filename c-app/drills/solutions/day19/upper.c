#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int main(int argc, char *argv[]) {
    size_t n = argc - 1;
    if (n == 0) {
        fprintf(stderr, "usage: %s word ...\n", argv[0]);
        return 1;
    }
    char **copies = malloc(n * sizeof(char *));
    if (!copies) {
        fprintf(stderr, "out of memory\n");
        return 1;
    }
    for (size_t i = 0; i < n; i++) {
        copies[i] = malloc(strlen(argv[i + 1]) + 1);
        if (!copies[i]) {
            for (size_t j = 0; j < i; j++) {
                free(copies[j]);
            }
            free(copies);
            fprintf(stderr, "out of memory\n");
            return 1;
        }
        strcpy(copies[i], argv[i + 1]);
        for (char *p = copies[i]; *p != '\0'; p++) {
            if (*p >= 'a' && *p <= 'z') {
                *p = *p - 'a' + 'A';
            }
        }
    }
    for (size_t i = 0; i < n; i++) {
        printf("%s\n", copies[i]);
    }
    printf("originals:");
    for (size_t i = 0; i < n; i++) {
        printf(" %s", argv[i + 1]);
    }
    printf("\n");
    for (size_t i = 0; i < n; i++) {
        free(copies[i]);
    }
    free(copies);
    return 0;
}
