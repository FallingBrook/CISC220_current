#include <stdio.h>
#include <stdlib.h>

struct point2 {
    double x;
    double y;
};

// Returns a pointer to the first point farthest from the origin (requires n >= 1)
struct point2 *farthest(struct point2 *pts, size_t n) {
    struct point2 *best = pts;
    for (size_t i = 1; i < n; i++) {
        double d = pts[i].x * pts[i].x + pts[i].y * pts[i].y;
        if (d > best->x * best->x + best->y * best->y) {
            best = &pts[i];
        }
    }
    return best;
}

void print_all(const struct point2 *pts, size_t n) {
    for (size_t i = 0; i < n; i++) {
        printf("(%.2f, %.2f)\n", pts[i].x, pts[i].y);
    }
}

int main(int argc, char *argv[]) {
    if (argc < 3 || (argc - 1) % 2 != 0) {
        fprintf(stderr, "usage: %s x y [x y ...]\n", argv[0]);
        return 1;
    }
    size_t n = (argc - 1) / 2;
    struct point2 *pts = malloc(n * sizeof(struct point2));
    if (!pts) {
        fprintf(stderr, "out of memory\n");
        return 1;
    }
    for (size_t i = 0; i < n; i++) {
        pts[i].x = atof(argv[2 * i + 1]);
        pts[i].y = atof(argv[2 * i + 2]);
    }
    print_all(pts, n);
    struct point2 *f = farthest(pts, n);
    printf("farthest: (%.2f, %.2f)\n", f->x, f->y);
    f->x = 0;
    f->y = 0;
    printf("after:\n");
    print_all(pts, n);
    free(pts);
    return 0;
}
