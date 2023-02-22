unsigned int fact(unsigned int n) {
    if (n < 2) return 1;
    return n*fact(n-1);
}