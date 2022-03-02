unsigned int fact_tail(unsigned int n, unsigned int result) {
    if (n <= 1) return result;
    return fact_tail(n - 1, n * result);
}

unsigned int fact(unsigned int n){
    return fact_tail(n, 1);
}

int main(){
    int n = 5;
    int r;
    r = fact(n);
}