// grades.c: if / else if / else inside a loop

#include <stdio.h>

int main(void) {
    for (int mark = 45; mark <= 95; mark += 10) {
        printf("%3d: ", mark);
        if (mark >= 80) {
            puts("A");
        } else if (mark >= 70) {
            puts("B");
        } else if (mark >= 50) {
            puts("pass");
        } else {
            puts("fail");
        }
    }
    return 0;
}
