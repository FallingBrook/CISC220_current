#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int main(int argc, char *argv[]) {
    if (argc < 3) {
        fprintf(stderr, "usage: wordfile filename word...\n");
        exit(EXIT_FAILURE);
    }
    FILE *out = fopen(argv[1], "w");
    if (!out) {
        perror(argv[1]);
        exit(EXIT_FAILURE);
    }
    for (int i = 2; i < argc; i++) {
        fprintf(out, "%s %zu\n", argv[i], strlen(argv[i]));
    }
    fclose(out);

    FILE *in = fopen(argv[1], "r");
    if (!in) {
        perror(argv[1]);
        exit(EXIT_FAILURE);
    }
    char word[100];
    char longest[100] = "";
    size_t len;
    size_t best = 0;
    size_t total = 0;
    while (fscanf(in, "%99s %zu", word, &len) == 2) {
        total += len;
        if (len > best) {
            best = len;
            strcpy(longest, word);
        }
    }
    fclose(in);
    printf("total length: %zu\n", total);
    printf("longest: %s (%zu)\n", longest, best);
    return 0;
}
