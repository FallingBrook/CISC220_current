#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int main(int argc, char *argv[]) {
    if (argc != 3 || strlen(argv[2]) != 1) {
        fprintf(stderr, "Usage: squeeze WORD C   (C is one character)\n");
        exit(1);
    }
    char c = argv[2][0];
    char word[strlen(argv[1]) + 1];
    strcpy(word, argv[1]);
    int removed = 0;
    char *p = strchr(word, c);
    while (p != NULL) {
        // move everything after p (including the '\0') one place left
        memmove(p, p + 1, strlen(p + 1) + 1);
        removed++;
        p = strchr(p, c);
    }
    printf("%s (%d removed)\n", word, removed);
    return 0;
}
