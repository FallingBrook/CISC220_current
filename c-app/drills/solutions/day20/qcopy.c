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

char *qstr_get(const struct qstr *s, size_t index) {
    if (!s || index >= s->length) {
        return NULL;
    }
    return s->data + index;
}

char *qstr_set(const struct qstr *s, size_t index, char c) {
    char *res = qstr_get(s, index);
    if (!res) {
        return NULL;
    }
    s->data[index] = c;
    return res;
}

struct qstr *qstr_copy(const struct qstr *s) {
    if (!s) {
        return qstr_new();
    }
    struct qstr *q = qstr_alloc(s->capacity);
    if (q) {
        memcpy(q->data, s->data, s->length + 1);
        q->length = s->length;
    }
    return q;
}

int is_vowel(char c) {
    return c == 'a' || c == 'e' || c == 'i' || c == 'o' || c == 'u';
}

int main(int argc, char *argv[]) {
    if (argc != 2) {
        fprintf(stderr, "usage: %s string\n", argv[0]);
        return 1;
    }
    struct qstr *s = qstr_fromcstr(argv[1]);
    struct qstr *t = qstr_copy(s);
    if (!s || !t) {
        qstr_destroy(s);
        qstr_destroy(t);
        return 1;
    }
    size_t changed = 0;
    for (size_t i = 0; i < t->length; i++) {
        if (is_vowel(*qstr_get(t, i))) {
            qstr_set(t, i, '*');
            changed++;
        }
    }
    printf("original: %s\n", s->data);
    printf("copy: %s\n", t->data);
    printf("changed: %zu\n", changed);
    qstr_destroy(s);
    qstr_destroy(t);
    return 0;
}
