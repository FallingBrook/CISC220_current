#include <stdio.h>
#include <stdlib.h>
#include <string.h>

// names is an array of strings whose last element is NULL. For each name,
// writes its first letter and, if it contains a space, the letter after its
// last space. Initials of different names are separated by one space.
void initials(char *names[], char *dest) {
    size_t k = 0;
    for (int i = 0; names[i] != NULL; i++) {
        if (i > 0) {
            dest[k] = ' ';
            k++;
        }
        dest[k] = names[i][0];
        k++;
        char *space = strrchr(names[i], ' ');
        if (space != NULL) {
            dest[k] = space[1];
            k++;
        }
    }
    dest[k] = '\0';
}

int main(int argc, char *argv[]) {
    if (argc < 2) {
        fprintf(stderr, "Usage: initials NAME...\n");
        exit(1);
    }
    for (int i = 1; i < argc; i++) {
        if (argv[i][0] == '\0' || argv[i][0] == ' ' || argv[i][strlen(argv[i]) - 1] == ' ') {
            fprintf(stderr, "initials: argument %d is empty or starts or ends with a space\n", i);
            exit(1);
        }
    }
    char result[3 * (argc - 1) + 1];
    initials(argv + 1, result);   // argv[argc] is NULL, so argv + 1 ends with NULL
    printf("%s\n", result);
    return 0;
}
