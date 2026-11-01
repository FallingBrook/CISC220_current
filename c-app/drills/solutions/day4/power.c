// power.c -- day 4 lab reference: x to the power n without pow
#include <stdio.h>
#include <stdlib.h>

double power(double x, unsigned int n) {
    double result = 1.0;
    for (unsigned int i = 0; i < n; i++) {
        result = result * x;
    }
    return result;
}

int main(int argc, char *argv[]) {
    if (argc != 3) {
        fprintf(stderr, "Usage: power x n\n");
        return 1;
    }
    double x = atof(argv[1]);
    int n = atoi(argv[2]);
    printf("%f\n", power(x, n));
    return 0;
}
