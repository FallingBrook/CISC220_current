#include <stdio.h>
#include <stdlib.h>

int main(int argc, char *argv[]) {
    if (argc != 2) {
        fprintf(stderr, "usage: savelines filename\n");
        exit(EXIT_FAILURE);
    }
    FILE *out = fopen(argv[1], "w");
    if (!out) {
        perror(argv[1]);
        exit(EXIT_FAILURE);
    }
    char buf[100];
    int n = 0;
    while (fgets(buf, 100, stdin) != NULL) {
        n++;
        fprintf(out, "%d: ", n);
        fputs(buf, out);
    }
    fclose(out);

    FILE *in = fopen(argv[1], "r");
    if (!in) {
        perror(argv[1]);
        exit(EXIT_FAILURE);
    }
    int c;
    while ((c = fgetc(in)) != EOF) {
        putchar(c);
    }
    fclose(in);
    printf("saved %d lines in %s\n", n, argv[1]);
    return 0;
}
