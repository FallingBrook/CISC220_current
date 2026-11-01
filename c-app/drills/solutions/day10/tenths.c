#include <math.h>
#include <stdio.h>
#include <stdlib.h>

int main(int argc, char *argv[]) {
    if (argc != 2) {
        fprintf(stderr, "Usage: tenths n\n");
        return 1;
    }
    int n = atoi(argv[1]);
    double sum = 0.0;
    for (int i = 0; i < n; i++) {
        sum += 0.1;
    }
    double exact = n / 10.0;
    printf("%.17f\n", sum);
    printf("%.17f\n", exact);
    if (sum == exact) {
        printf("equal\n");
    } else if (fabs(sum - exact) <= 1e-9) {
        printf("close\n");
    } else {
        printf("different\n");
    }
    return 0;
}
