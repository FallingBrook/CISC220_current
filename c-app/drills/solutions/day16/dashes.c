#include <stdio.h>
#include <stdlib.h>

int main(int argc, char *argv[]) {
    if (argc != 2) {
        fprintf(stderr, "Usage: dashes word\n");
        exit(1);
    }
    for (char *p = argv[1]; *p != '\0'; p++) {
        if (p != argv[1]) {
            printf("-");
        }
        printf("%c", *p);
    }
    printf("\n");
    return 0;
}
