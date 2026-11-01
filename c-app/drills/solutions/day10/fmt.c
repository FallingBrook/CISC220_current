#include <stdio.h>
#include <stdlib.h>

int main(int argc, char *argv[]) {
    if (argc != 2) {
        fprintf(stderr, "Usage: fmt x\n");
        return 1;
    }
    double x = atof(argv[1]);
    printf("%f\n", x);
    printf("%.2f\n", x);
    printf("%e\n", x);
    printf("%.3e\n", x);
    printf("%g\n", x);
    return 0;
}
