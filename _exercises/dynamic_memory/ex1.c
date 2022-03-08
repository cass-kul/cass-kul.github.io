void sum(int *in1, int *in2, int *out, int n) {
  for (int i = 0; i < n; i++) {
    *out = *in1 + *in2;
    out++;
    in1++;
    in2++;
  }
}
