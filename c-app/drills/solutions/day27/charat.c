#include <stdio.h>
#include <stdlib.h>

int main(int argc, char *argv[]) {
    if (argc != 3) {
        fprintf(stderr, "usage: charat file text\n");
        exit(EXIT_FAILURE);
    }
    FILE *f = fopen(argv[1], "w+");          // empty or create; read and write
    if (!f) {
        perror("fopen() failed");
        exit(EXIT_FAILURE);
    }
    fputs(argv[2], f);
    fseek(f, 0, SEEK_END);                   // a positioning call between write and read
    long size = ftell(f);
    printf("size: %ld\n", size);
    long pos;
    while (fscanf(stdin, "%ld", &pos) == 1) {
        if (pos >= 0 && pos < size) {
            fseek(f, pos, SEEK_SET);
            int c = fgetc(f);
            printf("%ld: %c\n", pos, c);
        }
        else {
            printf("%ld: out of range\n", pos);
        }
    }
    fclose(f);
    return 0;
}
