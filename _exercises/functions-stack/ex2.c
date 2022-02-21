long long result;
long long i = 6;

long long func(int a, long b, long long c, long long d, long long e, long long *f)
{
    return a + b + c + d + e + *f;
}

int main()
{
    result = func(1, 2, 3, 4, 5, &i);
}