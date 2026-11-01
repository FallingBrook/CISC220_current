// arglens.c -- print each command line argument with its length
#include <stdio.h>
#include <string.h>

int main(int argc, char *argv[]) {
    if (argc == 1) {
        puts("no arguments");
        return 0;
    }
    for (int i = 1; i < argc; i++) {
        printf("%d: \"%s\" has length %zu\n", i, argv[i], strlen(argv[i]));
    }
    return 0;
}
