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

// Returns 1 on success, 0 if malloc fails.
int stack_push(struct stack *s, int elem) {
    struct node *n = malloc(sizeof(struct node));
    if (!n) {
        return 0;
    }
    n->elem = elem;
    n->next = s->top;
    s->top = n;
    s->size++;
    return 1;
}

// The stack must not be empty.
int stack_pop(struct stack *s) {
    struct node *oldtop = s->top;
    int elem = oldtop->elem;
    s->top = oldtop->next;
    s->size--;
    free(oldtop);
    return elem;
}

void stack_print(const struct stack *s) {
    printf("top : ");
    for (struct node *n = s->top; n != NULL; n = n->next) {
        if (n != s->top) {
            printf(", ");
        }
        printf("%d", n->elem);
    }
    printf(" : bottom\n");
}

void stack_free(struct stack *s) {
    if (!s) {
        return;
    }
    struct node *n = s->top;
    while (n) {
        struct node *next = n->next;
        free(n);
        n = next;
    }
    free(s);
}

int main(int argc, char *argv[]) {
    struct stack *a = stack_new();
    struct stack *b = stack_new();
    if (!a || !b) {
        fprintf(stderr, "out of memory\n");
        stack_free(a);
        stack_free(b);
        return 1;
    }
    for (int i = 1; i < argc; i++) {
        if (!stack_push(a, atoi(argv[i]))) {
            fprintf(stderr, "out of memory\n");
            stack_free(a);
            stack_free(b);
            return 1;
        }
    }
    printf("a: ");
    stack_print(a);
    size_t moved = 0;
    while (a->size > 0) {
        if (!stack_push(b, stack_pop(a))) {
            fprintf(stderr, "out of memory\n");
            stack_free(a);
            stack_free(b);
            return 1;
        }
        moved++;
    }
    printf("moved %zu\n", moved);
    printf("a: ");
    stack_print(a);
    printf("b: ");
    stack_print(b);
    stack_free(a);
    stack_free(b);
    return 0;
}
