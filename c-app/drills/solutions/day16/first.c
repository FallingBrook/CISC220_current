#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int main(int argc, char *argv[]) {
    if (argc < 2) {
        fprintf(stderr, "Usage: first word...\n");
        exit(1);
    }
    int best = 1;
    for (int i = 2; i < argc; i++) {
        if (strcmp(argv[i], argv[best]) < 0) {
            best = i;
        }
    }
    printf("first: %s (argument %d)\n", argv[best], best);
    return 0;
}
