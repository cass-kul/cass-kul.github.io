#include <stdio.h>

struct st {
    float f;
    double d;
    long l;
    int *p;
    char c;
};

int main(void) {
    printf("The size of the struct is %lu bytes\n", sizeof(struct st));
    struct st obj;
    printf("f: %p\nd: %p\nl: %p\np: %p\nc: %p\n", &obj.f, &obj.d, &obj.l, &obj.p, &obj.c);
    return 0;
}
