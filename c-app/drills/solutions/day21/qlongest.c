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

struct qstr *qstr_assign(struct qstr *lhs, const struct qstr *rhs) {
    if (!lhs) {
        return NULL;
    }
    if (!rhs || lhs == rhs) {
        return lhs;
    }
    const size_t REQ_CAPACITY = rhs->length + 1;
    struct qstr *tmp = qstr_ensure_capacity(lhs, REQ_CAPACITY);
    if (!tmp) {
        return NULL;
    }
    memcpy(lhs->data, rhs->data, rhs->length + 1);
    lhs->length = rhs->length;
    return lhs;
}

int main(int argc, char *argv[]) {
    if (argc < 2) {
        fprintf(stderr, "usage: %s word...\n", argv[0]);
        return 1;
    }
    struct qstr *best = qstr_new();
    if (!best) {
        return 1;
    }
    for (int i = 1; i < argc; i++) {
        struct qstr *w = qstr_fromcstr(argv[i]);
        if (!w) {
            qstr_destroy(best);
            return 1;
        }
        if (i == 1 || w->length > best->length) {
            if (!qstr_assign(best, w)) {
                qstr_destroy(w);
                qstr_destroy(best);
                return 1;
            }
            printf("new longest: %s (length %zu, capacity %zu)\n",
                   best->data, best->length, best->capacity);
        }
        qstr_destroy(w);
    }
    printf("longest: %s\n", best->data);
    qstr_destroy(best);
    return 0;
}
