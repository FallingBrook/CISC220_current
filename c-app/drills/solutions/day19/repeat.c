#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int main(int argc, char *argv[]) {
    if (argc != 3) {
        fprintf(stderr, "usage: %s word n\n", argv[0]);
        return 1;
    }
    int n = atoi(argv[2]);
    if (n < 1 || n > 50) {
        fprintf(stderr, "n must be 1 to 50\n");
        return 1;
    }
    char *str = malloc(1);
    if (!str) {
        fprintf(stderr, "out of memory\n");
        return 1;
    }
    str[0] = '\0';
    for (int k = 1; k <= n; k++) {
        char *tmp = realloc(str, strlen(str) + strlen(argv[1]) + 1);
        if (!tmp) {
            free(str);
            fprintf(stderr, "out of memory\n");
            return 1;
        }
        str = tmp;
        strcat(str, argv[1]);
        printf("%d: %s\n", k, str);
    }
    printf("length = %zu\n", strlen(str));
    free(str);
    return 0;
}
