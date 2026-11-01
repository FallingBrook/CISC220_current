// widths.c: one double printed with different widths and precisions

#include <stdio.h>

int main(void) {
    double x = 22.0 / 7.0;
    printf("[%f]\n", x);
    printf("[%.3f]\n", x);
    printf("[%8.2f]\n", x);
    printf("[%24.17f]\n", x);
    printf("[%24.17f]\n", -x);
    printf("[%.0f]\n", x);
    printf("%d%% done\n", 100);
    return 0;
}
