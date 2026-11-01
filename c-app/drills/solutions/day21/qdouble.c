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

struct qstr *qstr_ensure_capacity(struct qstr *s, size_t capacity) {
    if (s->capacity >= capacity) {
        return s;
    }
    char *buf = realloc(s->data, capacity);
    if (!buf) {
        fprintf(stderr, "qstr->data reallocation error\n");
        return NULL;
    }
    s->data = buf;
    s->capacity = capacity;
    return s;
}

struct qstr *qstr_concat(struct qstr *lhs, const struct qstr *rhs) {
    if (!lhs) {
        return NULL;
    }
    if (!rhs) {
        return lhs;
    }
    const size_t REQ_CAPACITY = lhs->length + rhs->length + 1;
    struct qstr *tmp = qstr_ensure_capacity(lhs, REQ_CAPACITY);
    if (!tmp) {
        return NULL;
    }
    memmove(lhs->data + lhs->length, rhs->data, rhs->length + 1);
    lhs->length = lhs->length + rhs->length;
    return lhs;
}

int main(int argc, char *argv[]) {
    if (argc != 3) {
        fprintf(stderr, "usage: %s word n\n", argv[0]);
        return 1;
    }
    int n = atoi(argv[2]);
    if (n < 1 || n > 6) {
        fprintf(stderr, "n must be 1 to 6\n");
        return 1;
    }
    struct qstr *s = qstr_fromcstr(argv[1]);
    if (!s) {
        return 1;
    }
    printf("0: %s (length %zu, capacity %zu)\n", s->data, s->length, s->capacity);
    for (int k = 1; k <= n; k++) {
        if (!qstr_concat(s, s)) {
            qstr_destroy(s);
            return 1;
        }
        printf("%d: %s (length %zu, capacity %zu)\n", k, s->data, s->length, s->capacity);
    }
    qstr_destroy(s);
    return 0;
}
