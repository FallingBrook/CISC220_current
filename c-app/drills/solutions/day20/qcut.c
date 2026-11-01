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

int main(int argc, char *argv[]) {
    if (argc != 3 || strlen(argv[2]) != 1) {
        fprintf(stderr, "usage: %s string char\n", argv[0]);
        return 1;
    }
    struct qstr *s = qstr_fromcstr(argv[1]);
    if (!s) {
        return 1;
    }
    char sep = argv[2][0];
    for (size_t i = 0; i < s->length; i++) {
        if (*qstr_get(s, i) == sep) {
            qstr_set(s, i, '\0');
        }
    }
    printf("length = %zu\n", s->length);
    printf("strlen = %zu\n", strlen(s->data));
    for (size_t i = 0; i < s->length; i++) {
        char c = *qstr_get(s, i);
        printf("%c", c == '\0' ? '|' : c);
    }
    printf("\n");
    qstr_destroy(s);
    return 0;
}
