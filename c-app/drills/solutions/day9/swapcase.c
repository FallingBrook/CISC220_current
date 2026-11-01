#include <stdio.h>

int main(int argc, char *argv[]) {
    if (argc < 2) {
        fprintf(stderr, "usage: %s word...\n", argv[0]);
        return 1;
    }
    for (int i = 1; i < argc; i++) {
        for (size_t j = 0; argv[i][j] != '\0'; j++) {
            char c = argv[i][j];
            if ((c >= 'A' && c <= 'Z') || (c >= 'a' && c <= 'z')) {
                c = c ^ 32;
            }
            printf("%c", c);
        }
        if (i < argc - 1) {
            printf(" ");
        }
    }
    printf("\n");
    return 0;
}
