int x = 10;
int y = 20;
int z;

int double_it(int a) {
    return a + a;
}

int sum(int a, int b) {
    return a + double_it(b);
}

int main(void) {
    z = sum(x, y);
}
