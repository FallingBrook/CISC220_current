#include <stdio.h>
#include <stdlib.h>

int main(void) {
    int x;
    int count = 0;
    long sum = 0;
    int n;
    while ((n = fscanf(stdin, "%d", &x)) == 1) {
        count++;
        sum += x;
    }
    printf("count = %d\n", count);
    printf("sum = %ld\n", sum);
    if (n != EOF) {
        fprintf(stderr, "total: stopped at input that is not an integer\n");
        exit(EXIT_FAILURE);
    }
    return 0;
}
