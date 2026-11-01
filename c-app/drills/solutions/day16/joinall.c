#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int main(int argc, char *argv[]) {
    if (argc < 2) {
        fprintf(stderr, "Usage: joinall word...\n");
        exit(1);
    }
    char buf[31];
    buf[0] = '\0';
    for (int i = 1; i < argc; i++) {
        size_t need = strlen(buf) + strlen(argv[i]) + 1;
        if (i > 1) {
            need++;   // the '+'
        }
        if (need > sizeof(buf)) {
            fprintf(stderr, "joinall: too long\n");
            exit(1);
        }
        if (i > 1) {
            strcat(buf, "+");
        }
        strcat(buf, argv[i]);
    }
    printf("%s\n", buf);
    return 0;
}
