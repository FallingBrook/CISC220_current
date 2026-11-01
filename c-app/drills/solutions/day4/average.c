// average.c -- day 4 lab reference: average of all command line numbers
#include <stdio.h>
#include <stdlib.h>

int main(int argc, char *argv[]) {
    if (argc < 2) {
        fprintf(stderr, "Usage: average x1 x2 ...\n");
        exit(1);
    }
    double total = 0.0;
    for (int i = 1; i < argc; i++) {
        total = total + atof(argv[i]);
    }
    printf("%.3f\n", total / (argc - 1));
    return 0;
}
