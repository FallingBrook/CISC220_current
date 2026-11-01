// reverse.c -- build a new string that is argv[1] backwards, then print it
#include <stdio.h>
#include <string.h>

int main(int argc, char *argv[]) {
    if (argc != 2) {
        fprintf(stderr, "usage: %s word\n", argv[0]);
        return 1;
    }
    size_t n = strlen(argv[1]);
    char r[n + 1];
    for (size_t i = 0; i < n; i++) {
        r[i] = argv[1][n - 1 - i];
    }
    r[n] = '\0';
    printf("%s\n", r);
    return 0;
}
