#include <stdio.h>

int main(void) {
    int n;
    printf("Your number: ");
    scanf("%d", &n);
    int square = n * n;
    printf("The square of %d is %d\n", n, square);
    return 0;
}