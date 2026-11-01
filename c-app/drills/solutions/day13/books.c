#include <stdio.h>
#include <stdlib.h>

#define MAX_BOOKS 10

struct book {
    char *title;      // points at a command line argument
    char *author;
    int year;
};

void print_book(const struct book *b) {
    printf("%s by %s (%d)\n", b->title, b->author, b->year);
}

int main(int argc, char *argv[]) {
    int nargs = argc - 1;
    if (nargs == 0 || nargs % 3 != 0 || nargs / 3 > MAX_BOOKS) {
        fprintf(stderr, "usage: %s title author year [title author year ...]\n", argv[0]);
        return 1;
    }
    struct book shelf[MAX_BOOKS];
    size_t n = nargs / 3;
    for (size_t i = 0; i < n; i++) {
        shelf[i].title = argv[1 + 3 * i];
        shelf[i].author = argv[2 + 3 * i];
        shelf[i].year = atoi(argv[3 + 3 * i]);
    }

    size_t best = 0;
    for (size_t i = 0; i < n; i++) {
        print_book(&shelf[i]);
        if (shelf[i].year < shelf[best].year) {
            best = i;
        }
    }
    printf("oldest: ");
    print_book(&shelf[best]);
    return 0;
}
