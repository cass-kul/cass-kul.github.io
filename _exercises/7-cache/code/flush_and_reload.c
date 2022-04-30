#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdint.h>
#include "cacheutils.h"

/*
 * NOTE: the following ensures vote_a and vote_be are placed on different
 * memory pages, so that they are guaranteed to fall in different cache lines.
 * We also make sure the lines are sufficiently far apart so the CPU prefetcher
 * does not introduce noise...
 */
#define PAGE_SIZE   0x1000
#define LINE_SIZE   64
#define LINE_A      2
#define LINE_B      15
char __attribute__((aligned(PAGE_SIZE))) my_buf[PAGE_SIZE] = {0};
#define votes_a     my_buf[LINE_A*LINE_SIZE+2]
#define votes_b     my_buf[LINE_B*LINE_SIZE+2]

void secret_vote(char candidate)
{
    if (candidate == 'a')
        votes_a++;
    else
        votes_b++;
}

int main()
{
    /* 1. Flush */
    // TODO

    /* 2. Victim executes */
    secret_vote('b');

    /* 3. Reload */
    // TODO

    printf("Thank you, your vote has been securely registered.\n");
    return 0;
}
