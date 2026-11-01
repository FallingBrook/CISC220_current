// larger.c: a function that returns the larger of two ints

#include <stdio.h>

int larger(int a, int b) {
    if (a > b) {
        return a;
    }
    return b;
}

int main(void) {
    printf("larger(3, 7) = %d\n", larger(3, 7));
    printf("larger(10, -4) = %d\n", larger(10, -4));
    printf("larger(-2, -9) = %d\n", larger(-2, -9));
    printf("larger(5, 5) = %d\n", larger(5, 5));
    printf("largest of 8, 12, 3 = %d\n", larger(larger(8, 12), 3));
    return larger(0, 3);
}
