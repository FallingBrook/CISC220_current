#include <stdio.h>

// returns 1 on the first call, 2 on the second, and so on
int next_id(void) {
    static int id = 0;      // set to 0 once; keeps its value between calls
    id++;
    return id;
}

int main(int argc, char *argv[]) {
    if (argc < 2) {
        fprintf(stderr, "Usage: ids word ...\n");
        return 1;
    }
    for (int i = 1; i < argc; i++) {
        printf("%d: %s\n", next_id(), argv[i]);
    }
    return 0;
}
