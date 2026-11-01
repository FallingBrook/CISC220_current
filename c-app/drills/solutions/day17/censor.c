#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int main(int argc, char *argv[]) {
    if (argc != 3 || strlen(argv[2]) == 0) {
        fprintf(stderr, "Usage: censor TEXT WORD   (WORD not empty)\n");
        exit(1);
    }
    size_t len = strlen(argv[2]);
    char buf[strlen(argv[1]) + 1];
    strcpy(buf, argv[1]);
    int count = 0;
    char *p = strstr(buf, argv[2]);
    while (p != NULL) {
        for (size_t i = 0; i < len; i++) {
            p[i] = '*';
        }
        count++;
        p = strstr(p + len, argv[2]);
    }
    printf("%s\n", buf);
    printf("%d replaced\n", count);
    return 0;
}
