// count.c -- count how many times a character appears in argv[1]
#include <stdio.h>
#include <string.h>

int main(int argc, char *argv[]) {
    if (argc != 3) {
        fprintf(stderr, "usage: %s text char\n", argv[0]);
        return 1;
    }
    if (strlen(argv[2]) != 1) {
        fprintf(stderr, "%s: the second argument must be exactly one character\n", argv[0]);
        return 1;
    }
    char c = argv[2][0];
    size_t n = strlen(argv[1]);
    int count = 0;
    for (size_t i = 0; i < n; i++) {
        if (argv[1][i] == c) {
            count++;
        }
    }
    printf("%d\n", count);
    return 0;
}
