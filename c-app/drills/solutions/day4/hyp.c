// hyp.c -- day 4 lab reference: hypotenuse with sqrt and atof
#include <math.h>
#include <stdio.h>
#include <stdlib.h>

int main(int argc, char *argv[]) {
    if (argc != 3) {
        fprintf(stderr, "Usage: hyp a b\n");
        return 1;
    }
    double a = atof(argv[1]);
    double b = atof(argv[2]);
    printf("%.4f\n", sqrt(a * a + b * b));
    return 0;
}
