// geometric.c -- day 4 lab reference: 1 + r + r^2 + ... (n terms)
#include <math.h>
#include <stdio.h>
#include <stdlib.h>

double geometric(double r, int n) {
    double total = 0.0;
    for (int k = 0; k < n; k++) {
        total = total + pow(r, k);
    }
    return total;
}

int main(int argc, char *argv[]) {
    if (argc != 3) {
        fprintf(stderr, "Usage: geometric r n\n");
        return 1;
    }
    double r = atof(argv[1]);
    int n = atoi(argv[2]);
    printf("%.10f\n", geometric(r, n));
    return 0;
}
