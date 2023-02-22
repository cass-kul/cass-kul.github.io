int streq(const char *p1, const char *p2) {
  while (*p1 == *p2) {
    if (*p1 == '\0') {
      return 1;
    }
    p1++;
    p2++;
  }
  return 0;
}
