#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int main(int argc, char *argv[]) {
    if (argc != 3 || strlen(argv[2]) != 1) {
        fprintf(stderr, "Usage: where TEXT C   (C is one character)\n");
        exit(1);
    }
    char *text = argv[1];
    char c = argv[2][0];
    char *first = strchr(text, c);
    if (first == NULL) {
        printf("%c does not occur in %s\n", c, text);
        return 0;
    }
    char *last = strrchr(text, c);
    printf("first: %td\n", first - text);
    printf("last: %td\n", last - text);
    return 0;
}
