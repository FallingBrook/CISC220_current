#include <stdio.h>
#include <stdlib.h>
#include <string.h>

struct qstr {
    size_t length;
    size_t capacity;
    char *data;
};

static size_t QSTR_DEFAULT_CAPACITY = 8;

struct qstr *qstr_alloc(size_t capacity) {
    struct qstr *q = malloc(sizeof(struct qstr));
    if (!q) {
        fprintf(stderr, "qstr allocation error\n");
        return NULL;
    }
    if (capacity == 0) {
        capacity = 1;
    }
    char *buf = calloc(capacity, 1);
    if (!buf) {
        free(q);
        fprintf(stderr, "qstr->data allocation error\n");
        return NULL;
    }
    q->length = 0;
    q->capacity = capacity;
    q->data = buf;
    return q;
}

struct qstr *qstr_new(void) {
    return qstr_alloc(QSTR_DEFAULT_CAPACITY);
}

struct qstr *qstr_fromcstr(const char *s) {
    if (!s) {
        return qstr_new();
    }
    size_t len = strlen(s);
    struct qstr *q = qstr_alloc(len + 1);
    if (q) {
        q->length = len;
        strcpy(q->data, s);
    }
    return q;
}

void qstr_destroy(struct qstr *s) {
    if (!s) {
        return;
    }
    free(s->data);
    free(s);
}

struct qstr *qstr_remrange(struct qstr *s, size_t start, size_t stop) {
    if (!s || start > stop || stop > s->length) {
        return NULL;
    }
    size_t n_removed = stop - start;
    size_t n_tomove = s->length - stop + 1;
    memmove(s->data + start, s->data + stop, n_tomove);
    s->length -= n_removed;
    return s;
}

int main(int argc, char *argv[]) {
    if (argc != 2) {
        fprintf(stderr, "usage: %s string\n", argv[0]);
        return 1;
    }
    struct qstr *s = qstr_fromcstr(argv[1]);
    if (!s) {
        return 1;
    }
    size_t removed = 0;
    size_t i = 1;
    while (i < s->length) {
        if (s->data[i] == s->data[i - 1]) {
            qstr_remrange(s, i, i + 1);
            removed++;
        } else {
            i++;
        }
    }
    printf("%s\n", s->data);
    printf("removed = %zu\n", removed);
    qstr_destroy(s);
    return 0;
}
