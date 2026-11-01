#include <stdio.h>
#include <stdlib.h>

unsigned int calls = 0;     // global: every function below can use it

int cube(int x) {
    calls++;
    return x * x * x;
}

int main(int argc, char *argv[]) {
    for (int i = 1; i < argc; i++) {
        int x = atoi(argv[i]);
        printf("cube(%d) = %d\n", x, cube(x));
    }
    printf("cube was called %u times\n", calls);
    return 0;
}
