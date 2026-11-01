#include <stdio.h>
#include <stdlib.h>

typedef struct {
    char name[20];
    int goals;
    int assists;
} player;

int main(void) {
    player p[10];
    char line[100];
    int n = 0;
    while (fgets(line, 100, stdin) != NULL) {
        player tmp;
        if (sscanf(line, "%19s %d %d", tmp.name, &tmp.goals, &tmp.assists) != 3) {
            fprintf(stderr, "line %d: bad input\n", n + 1);
            exit(EXIT_FAILURE);
        }
        if (n < 10) {
            p[n] = tmp;
        }
        n++;
    }
    int stored = n < 10 ? n : 10;
    int best = 0;
    for (int i = 0; i < stored; i++) {
        int points = p[i].goals + p[i].assists;
        printf("%s %d\n", p[i].name, points);
        if (points > p[best].goals + p[best].assists) {
            best = i;
        }
    }
    if (stored == 0) {
        printf("no players\n");
    }
    else {
        printf("best: %s (%d points)\n", p[best].name, p[best].goals + p[best].assists);
    }
    printf("%d players, %d stored\n", n, stored);
    return 0;
}
