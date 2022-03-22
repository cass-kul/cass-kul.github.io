#include <stdlib.h>
#include <stdio.h>

struct person {
    char *name;
    int age;
};

void init_person(struct person *p, char *name, int age) {
    p->age = age;
    p->name = name;
}

void print_person(struct person *p) {
    printf("%s is %d years old\n", p->name, p->age);
}

int increase_age(struct person *p) {
    p->age += 1;
}

int main() {
    // allocate enough memory on the heap for a person
    struct person *p = malloc(sizeof(struct person));

    if (p == 0) {
        abort();
    }

    init_person(p, "Dave", 21);
    print_person(p);
    increase_age(p);
    print_person(p);

    // we no longer need 'p', so we free it
    free(p);
}