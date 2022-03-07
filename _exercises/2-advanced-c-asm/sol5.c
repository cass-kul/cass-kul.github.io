#include <stdio.h>
#include <string.h>

unsigned int mylen(char *s) {
    unsigned int i;
    for (i = 0; s[i] != '\0'; ++i) {
    }
    return i;
}

int main(void) {
    char str[100];              // we need to have an arbitrary limit (100) for the length
    printf("Enter a string: ");
    fgets(str, 100, stdin);     // and make sure we don't read more characters than that
    printf("Length: %lu %u\n", strlen(str), mylen(str));
    return 0;
}
