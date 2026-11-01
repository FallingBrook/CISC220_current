// sumto.c: add up 1 + 2 + ... + n with a loop

#include <stdio.h>

int main(void) {
    const int n = 24;
    int total = 0;
    int i = 1;
    while (i <= n) {
        total += i;
        i++;
    }
    printf("sum of 1..%d = %d\n", n, total);
    printf("formula n*(n+1)/2 = %d\n", n * (n + 1) / 2);
    printf("average = %.2f\n", (double) total / n);
    return 0;
}
