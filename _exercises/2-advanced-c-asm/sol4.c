#include <stdio.h>

void print_array(int *array, int size) {
    for (int i = 0; i < size; ++i) {
        printf("%d ", array[i]);
    }
    printf("\n");
}

int main(void) {
    int array[] = {1, 2, 3, 4, 5};
    int array_size = 5;
    print_array(array, array_size);

    int mul;
    printf("The number to multiply with: ");
    scanf("%d", &mul);
    for (int i = 0; i < array_size; ++i) {
        array[i] *= mul;
    }
    print_array(array, array_size);
    return 0;
}
