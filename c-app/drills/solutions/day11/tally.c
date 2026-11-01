// tally.c: update two of main's variables through pointers
#include <stdio.h>
#include <stdlib.h>

// adds x to *total; if x is negative, adds 1 to *negs
void tally(int x, int *total, int *negs) {
    *total = *total + x;
    if (x < 0) {
        *negs = *negs + 1;
    }
}

int main(int argc, char *argv[]) {
    int total = 0;
    int negs = 0;
    for (int i = 1; i < argc; i++) {
        tally(atoi(argv[i]), &total, &negs);
    }
    printf("total = %d\n", total);
    printf("negatives = %d\n", negs);
    return 0;
}
