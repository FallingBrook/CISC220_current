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
    struct stack *s = stack_new();
    if (!s) {
        fprintf(stderr, "out of memory\n");
        exit(EXIT_FAILURE);
    }
    for (int i = 1; i < argc; i++) {
        if (!stack_push(s, atoi(argv[i]))) {
            fprintf(stderr, "out of memory\n");
            exit(EXIT_FAILURE);
        }
    }
    if (s->top == NULL) {
        printf("top: none\n");
    } else {
        printf("top: %d\n", s->top->elem);
    }
    if (s->top == NULL || s->top->next == NULL) {
        printf("below top: none\n");
    } else {
        printf("below top: %d\n", s->top->next->elem);
    }
    printf("size: %zu\n", s->size);
    return 0;
}
