#include <stdio.h>
#include <string.h>

int main(int argc, char *argv[]) {
    if (argc != 2 || strlen(argv[1]) != 3) {
        fprintf(stderr, "Usage: rwx mode   (three octal digits, e.g. 754)\n");
        return 1;
    }
    unsigned int mode = 0;
    for (size_t i = 0; i < 3; i++) {
        char c = argv[1][i];
        if (c < '0' || c > '7') {
            fprintf(stderr, "rwx: %c is not an octal digit\n", c);
            return 1;
        }
        mode = (mode << 3) | (unsigned int) (c - '0');
    }
    char letters[] = "rwxrwxrwx";
    char out[10];
    for (int i = 0; i < 9; i++) {
        unsigned int mask = 1u << (8 - i);   // i = 0 is the user read bit, 0400
        out[i] = (mode & mask) ? letters[i] : '-';
    }
    out[9] = '\0';
    printf("%s\n", out);
    return 0;
}
