#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int main(int argc, char *argv[]) {
    if (argc < 2) {
        fprintf(stderr, "Usage: ordered word...\n");
        exit(1);
    }
    for (int i = 1; i < argc; i++) {
        if (strlen(argv[i]) > 20) {
            fprintf(stderr, "ordered: argument %d is longer than 20 characters\n", i);
            exit(1);
        }
    }
    for (int i = 2; i < argc; i++) {
        if (strcmp(argv[i - 1], argv[i]) > 0) {
            printf("arguments out of order:\n");
            printf("  %s\n", argv[i - 1]);
            printf("  %s\n", argv[i]);
            exit(1);
        }
    }
    printf("arguments are in order\n");
    return 0;
}
