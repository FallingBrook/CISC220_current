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

// Removes every node holding target; stores how many in *count. Returns the new head.
struct node *remove_all(struct node *head, int target, int *count) {
    *count = 0;
    struct node *prev = NULL;
    struct node *cur = head;
    while (cur) {
        if (cur->elem == target) {
            struct node *next = cur->next;
            if (!prev) {
                head = next;
            } else {
                prev->next = next;
            }
            free(cur);
            (*count)++;
            cur = next;           // prev stays where it is
        } else {
            prev = cur;
            cur = cur->next;
        }
    }
    return head;
}

int main(int argc, char *argv[]) {
    if (argc < 2) {
        fprintf(stderr, "usage: %s target values...\n", argv[0]);
        return 1;
    }
    int target = atoi(argv[1]);
    struct node *head = NULL;
    struct node *last = NULL;
    for (int i = 2; i < argc; i++) {
        struct node *n = malloc(sizeof(struct node));
        if (!n) {
            fprintf(stderr, "out of memory\n");
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
    int count;
    head = remove_all(head, target, &count);
    printf("removed %d\n", count);
    print_list(head);
    while (head) {
        struct node *next = head->next;
        free(head);
        head = next;
    }
    return 0;
}
