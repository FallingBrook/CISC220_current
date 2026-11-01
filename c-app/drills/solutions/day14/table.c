#include <stdio.h>
#include <stdlib.h>

void fill(int rows, int cols, int m[rows][cols]) {
    for (int i = 0; i < rows; i++) {
        for (int j = 0; j < cols; j++) {
            m[i][j] = (i + 1) * (j + 1);
        }
    }
}

int main(int argc, char *argv[]) {
    if (argc != 3) {
        fprintf(stderr, "Usage: %s rows cols\n", argv[0]);
        return 1;
    }
    int rows = atoi(argv[1]);
    int cols = atoi(argv[2]);
    if (rows < 1 || rows > 10 || cols < 1 || cols > 10) {
        fprintf(stderr, "rows and cols must be from 1 to 10\n");
        return 1;
    }
    int m[10][10];
    fill(10, 10, m);
    int total = 0;
    for (int i = 0; i < rows; i++) {
        for (int j = 0; j < cols; j++) {
            printf("%4d", m[i][j]);
            total += m[i][j];
        }
        printf("\n");
    }
    printf("total = %d\n", total);
    return 0;
}
