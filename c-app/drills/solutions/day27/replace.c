#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int main(int argc, char *argv[]) {
    if (argc != 4 || strlen(argv[2]) != 1 || strlen(argv[3]) != 1) {
        fprintf(stderr, "usage: replace file targetchar replacementchar\n");
        exit(EXIT_FAILURE);
    }
    FILE *f = fopen(argv[1], "w");
    if (!f) {
        perror("fopen() failed");
        exit(EXIT_FAILURE);
    }
    int c;
    while ((c = getchar()) != EOF) {
        fputc(c, f);
    }
    fclose(f);

    f = fopen(argv[1], "r+");
    if (!f) {
        perror("fopen() failed");
        exit(EXIT_FAILURE);
    }
    char target = argv[2][0];
    char replacement = argv[3][0];
    int count = 0;
    while ((c = fgetc(f)) != EOF) {
        if (c == target) {
            fseek(f, -1, SEEK_CUR);
            fputc(replacement, f);
            fflush(f);
            count++;
        }
    }
    rewind(f);
    while ((c = fgetc(f)) != EOF) {
        putchar(c);
    }
    printf("replaced %d\n", count);
    fclose(f);
    return 0;
}
