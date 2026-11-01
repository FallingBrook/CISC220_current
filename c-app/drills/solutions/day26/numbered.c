#include <stdio.h>
#include <string.h>

int main(void) {
    char buf[100];
    int n = 0;
    while (fgets(buf, 100, stdin) != NULL) {
        n++;
        size_t len = strlen(buf);
        if (len > 0 && buf[len - 1] == '\n') {
            buf[len - 1] = '\0';
        }
        printf("%3d| %s\n", n, buf);
    }
    printf("%d lines\n", n);
    return 0;
}
