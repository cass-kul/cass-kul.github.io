int x = 10;
int y = 20;
int z;

int doubleIt(int a)
{
    return a + a; 
}

int sum(int a, int b)
{
    return a + doubleIt(b); 
} 

int main()
{
    z = sum(x, y);
}