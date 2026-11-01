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

// Inserts elem as the second node (just below the top).
// Returns 1 if it was inserted, 0 if the stack is empty or memory runs out.
int insert_second(struct stack *s, int elem) {
    if (s->top == NULL) {
        return 0;
    }
    struct node *n = malloc(sizeof(struct node));
    if (!n) {
        return 0;
    }
    n->elem = elem;
    n->next = s->top->next;
    s->top->next = n;
    s->size++;
    return 1;
}

int main(int argc, char *argv[]) {
    if (argc < 2) {
        fprintf(stderr, "usage: insert2 value [elements...]\n");
        exit(EXIT_FAILURE);
    }
    struct stack *s = stack_new();
    if (!s) {
        fprintf(stderr, "out of memory\n");
        exit(EXIT_FAILURE);
    }
    for (int i = 2; i < argc; i++) {
        if (!stack_push(s, atoi(argv[i]))) {
            fprintf(stderr, "out of memory\n");
            exit(EXIT_FAILURE);
        }
    }
    if (!insert_second(s, atoi(argv[1]))) {
        fprintf(stderr, "insert2: nothing to insert after\n");
        exit(EXIT_FAILURE);
    }
    for (struct node *n = s->top; n != NULL; n = n->next) {
        printf("%d", n->elem);
        if (n->next != NULL) {
            printf(" ");
        }
    }
    printf("\n");
    printf("size %zu\n", s->size);
    return 0;
}
