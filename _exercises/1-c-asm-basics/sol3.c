#include <stdio.h>

int main(void) {
    int num;
    printf("Your number: ");
    scanf("%d", &num);
    printf("Address: %p, value: %d, size: %lu\n", &num, num, sizeof(num));

    int *pointer = &num;
    printf("Address: %p, value: %p, size: %lu\n", &pointer, pointer, sizeof(pointer));
    return 0;
}