#include <stdio.h>
#include <stdlib.h>

int main(int argc, char *argv[]) {
    if (argc != 3 || atoi(argv[2]) <= 0) {
        fprintf(stderr, "usage: tail file N (N > 0)\n");
        exit(EXIT_FAILURE);
    }
    long n = atoi(argv[2]);
    FILE *f = fopen(argv[1], "w");
    if (!f) {
        perror("fopen() failed");
        exit(EXIT_FAILURE);
    }
    int c;
    while ((c = getchar()) != EOF) {         // save standard input in the file
        fputc(c, f);
    }
    fclose(f);

    f = fopen(argv[1], "r");
    if (!f) {
        perror("fopen() failed");
        exit(EXIT_FAILURE);
    }
    fseek(f, 0, SEEK_END);
    long size = ftell(f);
    long start = size - n;
    if (start < 0) {
        start = 0;
    }
    printf("last %ld of %ld characters:\n", size - start, size);
    fseek(f, start, SEEK_SET);
    while ((c = fgetc(f)) != EOF) {
        putchar(c);
    }
    fclose(f);
    return 0;
}
