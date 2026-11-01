#include <stdio.h>
#include <stdlib.h>

struct node {
    int elem;
    struct node *next;
};

void print_list(const struct node *head) {
    printf("[");
    for (const struct node *n = head; n; n = n->next) {
        printf("%d", n->elem);
        if (n->next) {
            printf(",");
        }
    }
    printf("]\n");
}

void free_list(struct node *head) {
    while (head) {
        struct node *next = head->next;
        free(head);
        head = next;
    }
}

int main(int argc, char *argv[]) {
    if (argc < 2) {
        fprintf(stderr, "usage: %s index values...\n", argv[0]);
        return 1;
    }
    int k = atoi(argv[1]);
    struct node *head = NULL;
    struct node *last = NULL;
    for (int i = 2; i < argc; i++) {
        struct node *n = malloc(sizeof(struct node));
        if (!n) {
            fprintf(stderr, "out of memory\n");
            free_list(head);
            return 1;
        }
        n->elem = atoi(argv[i]);
        n->next = NULL;
        if (!head) {
            head = n;
        } else {
            last->next = n;
        }
        last = n;
    }
    struct node *prev = NULL;
    struct node *cur = head;
    for (int i = 0; cur && i < k; i++) {
        prev = cur;
        cur = cur->next;
    }
    if (k < 0 || !cur) {
        printf("no node at index %d\n", k);
        print_list(head);
        free_list(head);
        return 1;
    }
    if (!prev) {
        head = cur->next;
    } else {
        prev->next = cur->next;
    }
    printf("removed %d\n", cur->elem);
    free(cur);
    print_list(head);
    free_list(head);
    return 0;
}
