#include <stdio.h>
#include <stdlib.h>
#include <string.h>

struct node {
    void *elem;
    struct node *next;
};

struct gstack {
    struct node *top;
    size_t size;
};

void push(struct gstack *s, void *elem) {
    struct node *n = malloc(sizeof(struct node));
    if (!n) {
        fprintf(stderr, "out of memory\n");
        exit(EXIT_FAILURE);
    }
    n->elem = elem;
    n->next = s->top;
    s->top = n;
    s->size++;
}

void *pop(struct gstack *s) {
    struct node *oldtop = s->top;
    void *elem = oldtop->elem;
    s->top = oldtop->next;
    s->size--;
    free(oldtop);
    return elem;
}

void print_stack(const struct gstack *s, void (*print_elem)(const void *)) {
    printf("top : ");
    for (struct node *n = s->top; n; n = n->next) {
        print_elem(n->elem);
        if (n->next) {
            printf(", ");
        }
    }
    printf(" : bottom\n");
}

void free_stack(struct gstack *s, void (*free_elem)(void *)) {
    struct node *n = s->top;
    while (n) {
        struct node *next = n->next;
        if (free_elem) {
            free_elem(n->elem);
        }
        free(n);
        n = next;
    }
    s->top = NULL;
    s->size = 0;
}

void print_string(const void *elem) {
    const char *str = elem;
    printf("%s", str);
}

void free_string(void *elem) {
    free(elem);
}

int main(int argc, char *argv[]) {
    if (argc < 2) {
        fprintf(stderr, "usage: %s word...\n", argv[0]);
        return 1;
    }
    struct gstack s = {NULL, 0};
    for (int i = 1; i < argc; i++) {
        char *copy = malloc(strlen(argv[i]) + 1);
        if (!copy) {
            fprintf(stderr, "out of memory\n");
            free_stack(&s, free_string);
            return 1;
        }
        strcpy(copy, argv[i]);
        push(&s, copy);
    }
    print_stack(&s, print_string);
    char *top = pop(&s);
    printf("popped %s, size %zu\n", top, s.size);
    free(top);
    print_stack(&s, print_string);
    free_stack(&s, free_string);
    return 0;
}
