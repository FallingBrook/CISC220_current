#include <stdio.h>
#include <stdlib.h>

struct node {
    int elem;
    struct node *next;
};

struct stack {
    struct node *top;
    size_t size;
};

struct stack *stack_new(void) {
    struct stack *s = malloc(sizeof(struct stack));
    if (!s) {
        return NULL;
    }
    s->top = NULL;
    s->size = 0;
    return s;
}

struct stack *stack_push(struct stack *s, int elem) {
    if (!s) {
        return NULL;
    }
    struct node *n = malloc(sizeof(struct node));
    if (!n) {
        return NULL;
    }
    n->elem = elem;
    n->next = s->top;
    s->top = n;
    s->size++;
    return s;
}

int main(int argc, char *argv[]) {
    if (argc != 2) {
        fprintf(stderr, "usage: digits n\n");
        exit(EXIT_FAILURE);
    }
    int value = atoi(argv[1]);
    if (value < 0) {
        fprintf(stderr, "digits: n must not be negative\n");
        exit(EXIT_FAILURE);
    }
    struct stack *s = stack_new();
    if (!s) {
        fprintf(stderr, "out of memory\n");
        exit(EXIT_FAILURE);
    }
    // push the last digit first, so the first digit ends up on top
    if (value == 0) {
        stack_push(s, 0);
    }
    while (value > 0) {
        if (!stack_push(s, value % 10)) {
            fprintf(stderr, "out of memory\n");
            exit(EXIT_FAILURE);
        }
        value = value / 10;
    }
    for (struct node *n = s->top; n != NULL; n = n->next) {
        printf("%d", n->elem);
        if (n->next != NULL) {
            printf(" ");
        }
    }
    printf("\n");
    printf("pushed %zu nodes\n", s->size);
    return 0;
}
