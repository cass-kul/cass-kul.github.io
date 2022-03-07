#include <stdio.h>

int fact(int n) {
    if (n < 2) {
        return 1;
    } else {
        return n * fact(n - 1);
    }
}

int main(void) {
    for (int i = 1; i <= 10; ++i) {
        printf("The factorial of %d is %d\n", i, fact(i));
    }
    return 0;
}
