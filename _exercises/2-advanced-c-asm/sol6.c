unsigned int mylen(char *s) {
    unsigned int i;
    for (i = 0; s[i] != '\0'; ++i) {
        printf("%02x\n", s[i]);
    }
    return i;
}
