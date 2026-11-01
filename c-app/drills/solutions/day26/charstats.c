#include <stdio.h>

int main(void) {
    int c;
    int chars = 0;
    int lines = 0;
    int digits = 0;
    while ((c = fgetc(stdin)) != EOF) {
        chars++;
        if (c == '\n') {
            lines++;
        }
        else if (c >= '0' && c <= '9') {
            digits++;
        }
    }
    printf("characters: %d\n", chars);
    printf("lines: %d\n", lines);
    printf("digits: %d\n", digits);
    return 0;
}
