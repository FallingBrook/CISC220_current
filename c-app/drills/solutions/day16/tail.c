#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int main(int argc, char *argv[]) {
    if (argc != 3) {
        fprintf(stderr, "Usage: tail word n\n");
        exit(1);
    }
    size_t len = strlen(argv[1]);
    int n = atoi(argv[2]);
    if (n < 0 || (size_t) n > len) {
        fprintf(stderr, "tail: n must be between 0 and %zu\n", len);
        exit(1);
    }
    char rest[len - n + 1];
    strcpy(rest, argv[1] + n);
    printf("%s (length %zu)\n", rest, strlen(rest));
    return 0;
}
