// initials.c -- build a new string from the first character of each non-empty argument
#include <stdio.h>

int main(int argc, char *argv[]) {
    char s[argc];              // at most argc - 1 initials, plus '\0'
    int k = 0;                 // next free index in s
    for (int i = 1; i < argc; i++) {
        if (argv[i][0] != '\0') {
            s[k] = argv[i][0];
            k++;
        }
    }
    s[k] = '\0';
    puts(s);
    return 0;
}
