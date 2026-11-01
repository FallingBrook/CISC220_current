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

void show(const struct qstr *q) {
    printf("\"%s\": length = %zu, capacity = %zu\n", q->data, q->length, q->capacity);
}

int main(int argc, char *argv[]) {
    if (argc == 1) {
        struct qstr *e = qstr_new();
        if (!e) {
            return 1;
        }
        show(e);
        qstr_destroy(e);
        return 0;
    }
    for (int i = 1; i < argc; i++) {
        struct qstr *q = qstr_fromcstr(argv[i]);
        if (!q) {
            return 1;
        }
        show(q);
        qstr_destroy(q);
    }
    return 0;
}
