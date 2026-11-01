#include <stdio.h>
#include <stdlib.h>
#include <string.h>

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
    struct stack *s = stack_new();
    if (!s) {
        fprintf(stderr, "out of memory\n");
        return 1;
    }
    for (int i = 1; i < argc; i++) {
        const char *t = argv[i];
        int is_op = strcmp(t, "+") == 0 || strcmp(t, "-") == 0 || strcmp(t, "x") == 0;
        int value;
        if (is_op) {
            if (s->size < 2) {
                fprintf(stderr, "error: not enough operands for %s\n", t);
                stack_free(s);
                return 1;
            }
            int b = stack_pop(s);     // the top is the RIGHT operand
            int a = stack_pop(s);
            if (t[0] == '+') {
                value = a + b;
            } else if (t[0] == '-') {
                value = a - b;
            } else {
                value = a * b;
            }
        } else {
            value = atoi(t);
        }
        if (!stack_push(s, value)) {
            fprintf(stderr, "out of memory\n");
            stack_free(s);
            return 1;
        }
    }
    if (s->size != 1) {
        fprintf(stderr, "error: %zu values left on the stack\n", s->size);
        stack_free(s);
        return 1;
    }
    printf("%d\n", s->top->elem);
    stack_free(s);
    return 0;
}
