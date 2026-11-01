#include <stdio.h>
#include <stdlib.h>

// returns the largest value it has been given so far (including x)
int running_max(int x) {
    static int seen = 0;    // 0 until the first call
    static int max;
    if (seen == 0 || x > max) {
        max = x;
        seen = 1;
    }
    return max;
}

int main(int argc, char *argv[]) {
    for (int i = 1; i < argc; i++) {
        int x = atoi(argv[i]);
        printf("%d %d\n", x, running_max(x));
    }
    return 0;
}
