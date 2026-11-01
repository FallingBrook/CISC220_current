#include <stdio.h>
#include <stdlib.h>

struct rect {
    int width;
    int height;
};

// Multiplies both sides of the rectangle that r points at by factor.
void scale(struct rect *r, int factor) {
    r->width *= factor;
    r->height *= factor;
}

// Returns the area of the rectangle that r points at.
int area(const struct rect *r) {
    return r->width * r->height;
}

int main(int argc, char *argv[]) {
    if (argc != 4) {
        fprintf(stderr, "usage: %s width height factor\n", argv[0]);
        return 1;
    }
    struct rect r = { atoi(argv[1]), atoi(argv[2]) };
    printf("before: %d x %d, area %d\n", r.width, r.height, area(&r));
    scale(&r, atoi(argv[3]));
    printf("after: %d x %d, area %d\n", r.width, r.height, area(&r));
    return 0;
}
