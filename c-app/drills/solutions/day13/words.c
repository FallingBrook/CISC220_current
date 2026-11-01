#include <stdio.h>
#include <string.h>

#define MAX_WORDS 20

struct wordinfo {
    char first;
    size_t len;
};

// Fills info[0..n-1] from words[0..n-1].
void fill(struct wordinfo info[], char *words[], size_t n) {
    for (size_t i = 0; i < n; i++) {
        info[i].first = words[i][0];
        info[i].len = strlen(words[i]);
    }
}

int main(int argc, char *argv[]) {
    if (argc < 2 || argc - 1 > MAX_WORDS) {
        fprintf(stderr, "usage: %s word [word ...] (at most %d words)\n", argv[0], MAX_WORDS);
        return 1;
    }
    size_t n = argc - 1;
    struct wordinfo info[MAX_WORDS];
    fill(info, argv + 1, n);

    size_t best = 0;
    for (size_t i = 0; i < n; i++) {
        printf("%c %zu\n", info[i].first, info[i].len);
        if (info[i].len > info[best].len) {
            best = i;
        }
    }
    printf("longest: %s (%zu)\n", argv[1 + best], info[best].len);
    return 0;
}
