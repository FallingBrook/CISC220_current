#include <stdio.h>
#include <stdlib.h>

struct point2 {
    double x;
    double y;
};

// Returns the point halfway between a and b.
struct point2 midpoint(struct point2 a, struct point2 b) {
    struct point2 m = { (a.x + b.x) / 2, (a.y + b.y) / 2 };
    return m;
}

int main(int argc, char *argv[]) {
    if (argc != 5) {
        fprintf(stderr, "usage: %s x1 y1 x2 y2\n", argv[0]);
        return 1;
    }
    struct point2 p = { atof(argv[1]), atof(argv[2]) };
    struct point2 q = { atof(argv[3]), atof(argv[4]) };
    struct point2 m = midpoint(p, q);
    printf("midpoint = (%.2f, %.2f)\n", m.x, m.y);
    return 0;
}
