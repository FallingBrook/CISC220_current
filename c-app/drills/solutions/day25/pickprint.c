#include <stdio.h>
#include <stdlib.h>

typedef void (*print_func)(const void *elem);

void print_int(const void *elem) {
    const int *p = elem;
    printf("%d\n", *p);
}

void print_double(const void *elem) {
    const double *p = elem;
    printf("%.2f\n", *p);
}

void print_string(const void *elem) {
    const char *p = elem;
    printf("\"%s\"\n", p);
}

int main(int argc, char *argv[]) {
    if (argc < 2 || argv[1][1] != '\0' ||
            (argv[1][0] != 'i' && argv[1][0] != 'd' && argv[1][0] != 's')) {
        fprintf(stderr, "usage: %s i|d|s values...\n", argv[0]);
        return 1;
    }
    char kind = argv[1][0];
    print_func f;
    if (kind == 'i') {
        f = print_int;
    } else if (kind == 'd') {
        f = print_double;
    } else {
        f = print_string;
    }
    for (int i = 2; i < argc; i++) {
        if (kind == 'i') {
            int v = atoi(argv[i]);
            f(&v);
        } else if (kind == 'd') {
            double v = atof(argv[i]);
            f(&v);
        } else {
            f(argv[i]);
        }
    }
    return 0;
}
