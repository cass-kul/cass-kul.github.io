---
layout: default
title: "Session 7: Caches and Microarchitectural Timing Attacks"
nav_order: 7
nav_exclude: true
search_exclude: true
has_children: false
has_toc: false
---

## Table of contents
{: .no_toc .text-delta }

1. TOC
{:toc}

!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

There's a lot of prose in the exercise pdf as well, maybe some of it can be directly copy and pasted here!

The solutions contain a lot of information, some of it probably should be moved to a regular explanation.

!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

# Introduction

Over the years, a performance gap has formed between the processor and the memory unit, forming a
bottleneck for the performance of the computer in general.

To solve this issue, caches were introduced. These are not as fast as registers, but can include more data,
and are much faster than the main memory.

A lot smaller though. There is even a hierarchy of caches in most commercial CPUs: L1I, L1D, L2, LLC.

# Locality principle

Programs usually access a relatively small portion of the address space at a time.

Temporal locality (same value again) and spatial locality (nearby variables, array members). Transfer entire blocks (multiple contiguous words) into the cache at once.

# Terminology

Cache miss: on first use, value not in cache

Cache hit: value already in cache, no need to consult the DRAM.

Hit rate, miss rate

# Timing attacks

TODO!!! Do we want to obscure the secret a little bit in the header by e.g., xoring together two numbers
that make up the key, so that if someone accidentally opens it, they don't get spoiled?

TODO!!! Do the programs in this session still work on the M1?

### Exercise 2.1

We start by compiling the downloaded program and running it with an arbitrary input.

``` bash
$ gcc passwd.c -o passwd
$ ./passwd
Enter super secret password ('q' to exit): 32349
--> You entered: '32349'
 _______________
< ACCESS DENIED >
 ---------------
        \
         \
    \|/ ____ \|/
    "@'/ .. \`@"
    /_| \__/ |_\
       \__U_/

time (med clock cycles): 68
```

### Exercise 2.2

In the program ( `passwd.c` ), we see that the printed execution time is the calculated median over 100, 000 measurements:

``` c
for (j = 0; j < NUM_SAMPLES; j++)
{
    tsc1 = rdtsc_begin();
    allowed = check_pwd(pwd);
    tsc2 = rdtsc_end();
    diff[j] = tsc2 - tsc1;
}
// ...
qsort(diff, NUM_SAMPLES, sizeof(uint64_t), compare);
med = diff[NUM_SAMPLES/2];
```

Even with this measure, we might notice different time values for the same inputs. This happens because the timing of one execution depends on many factors. Modern processors include a wide range of microarchitectural optimizations, such as instruction and data caches, pipelining, branch prediction, dynamic frequency scaling, out-of-order execution, etc. The execution can also be delayed by external events, such as an interrupt that is handled by the operating system. Taking the median instead of the average reduces the effect of such outliers.

### Exercise 2.3

It's time to guess the password. First, we can notice that the program exits immediately if we provide a password with an incorrect length.

``` c
if (user_len != secret_len)
    return 0;
```

If we guess the length incorrectly, the program exits. If we guess it correctly, it continues to compare the individual characters in the password.

This means that based on the execution time, we can tell whether we guessed the length correctly: the program will take longer to execute in that case.

``` bash
Enter super secret password ('q' to exit): 0
time (med clock cycles): 68
Enter super secret password ('q' to exit): 00
time (med clock cycles): 70
Enter super secret password ('q' to exit): 000
time (med clock cycles): 372
```

Now we know that the password consists of 3 characters. Let us examine how the program compares the individual characters:

``` c
for (i = 0; i < user_len; i++)
{
    if (user[i] != SECRET_PWD[i])
        return 0;
}
```

The same principle applies here: the program quits at the first character that does not match. This means that the longer the execution takes, the more characters at the start of the password we managed to guess correctly.

``` bash
Enter super secret password ('q' to exit): 200
time (med clock cycles): 372
Enter super secret password ('q' to exit): 300
time (med clock cycles): 372
Enter super secret password ('q' to exit): 400
time (med clock cycles): 372
Enter super secret password ('q' to exit): 500
time (med clock cycles): 782
```

``` bash
Enter super secret password ('q' to exit): 510
time (med clock cycles): 784
Enter super secret password ('q' to exit): 520
time (med clock cycles): 1072
```

This way, we can guess the characters one-by-one, starting from the start of the string. With a password that is 3 characters long, this means that to guess the entire password, we need a total of `3 * 10 = 30` guesses. Compare this with `10^3 = 1000` guesses if we could not guess one-by-one, but would have to iterate over every possible combination. Of course, for longer passwords, the effect is even more severe.

``` bash
Enter super secret password ('q' to exit): 522
time (med clock cycles): 1070
Enter super secret password ('q' to exit): 523
time (med clock cycles): 1070
Enter super secret password ('q' to exit): 524
--> You entered: '524'
 _______________
< ACCESS ALLOWED >
 ---------------
        \
         \
        .--.
       |o_o |
       |:_/ |
      //   \ \
     (|     | )
    /'\_   _/`\
    \___)=(___/

time (med clock cycles): 1342
```

## Timing attacks on the cache

Can we use timing differences in the cache to exploit programs?

The CPU allows us to flush (empty) the cache contents.

Attacker can measure the difference in timing between cache hits and misses.

Flush+Reload: requires shared memory, attacker directly flashes a line from the victim's memory.

### Exercise 3.2

The `flush-and-reload.c` file contains the following function:

``` c
void secret_vote(char candidate)
{
    if (candidate == 'a')
        votes_a++;
    else
        votes_b++;
}
```

We want to detect which of the candidates the user voted for. To increase the vote count, the program first has to load the current number of votes from memory. This is the access we will try to detect. Based on whether `votes_a` or `votes_b` has been fetched, we know which candidate got the vote.

Using the Flush+Reload technique, we need to take the following steps:

1. Flush `votes_a` from the cache.
2. Let the `secret_vote` function execute with a secret input. This will load the value of either `votes_a` or `votes_b` from memory, caching it in the process.
3. After the execution is done, reload `votes_a`. If the access time is low, this signals a cache hit. A cache hit in turn indicates that the victim process has accessed `votes_a`, which means a vote for *candidate A*. On the other hand, if the access time is high, this means the value has not been cached, this is not the candidate the user voted for.

Of course, the above process could be executed with `votes_b` in place of `votes_a` . Since there are only two candidates, it suffices to check whether one of the two variables has been accessed.

### Exercise 3.3

In order to draw a conclusion in the above example, we need to have an idea about what a "low" and "high" access time is. To make our job easier, we can just measure the access time of both the `votes_a` and `votes_b` variables and see which one takes considerably less time: that one is the one the user voted for.

Using the provided functions, this is simply:

``` c
flush(&votes_a);
flush(&votes_b);
secret_vote('b');
time_a = reload(&votes_a);
time_b = reload(&votes_b);
```

Similarly to the previous example, we will compensate for variations in the timings by averaging the measurements over multiple executions. The final code is thus:

``` c
int SAMPLES = 1000;
unsigned long long time_a = 0, time_b = 0;
for (int i = 0; i < SAMPLES; ++i) {
    flush(&votes_a);
    flush(&votes_b);
    secret_vote('b');
    time_a += reload(&votes_a);
    time_b += reload(&votes_b);
}
printf("A avg: %llu, B avg: %llu\n", time_a / SAMPLES, time_b / SAMPLES);
```

This will provide us with an output from which it is clear to see which candidate has been voted for:

``` bash
$ gcc flush-and-reload.c -o fnr
$ ./fnr
A avg: 419, B avg: 120
```

# Cache organization

Direct mapping

Set-associativity

## More advanced cache attacks

Utilizing knowledge about the cache organization to attack across protection domains

## Exercise 4.1

Let us start with the structure of the cache. The cache is a table that contains multiple rows, these are called the cache sets.

```

+---+------------+------------+
| V |    Tag     |    Data    |
+---+------------+------------+
|   |            |            |  <-- Cache set
+---+------------+------------+
|   |            |            |
+---+------------+------------+
|   |            |            |
+---+------------+------------+
```

A cache set can include one or more cache blocks (or cache lines). These are labeled as "Data" on the figure. The data in one cache line typically contains more than one byte. This is to enable spatial locality: when the data from a certain address is loaded, the contents of the neighboring memory locations are also placed in the cache, in case they are also accessed in the future. The size of one of these data blocks is called the *block size*, which in this case is `B = 2^b` bytes.

When two addresses map to the same cache line, and these addresses are accessed quickly in an alternating fashion, this leads to many cache misses, causing a performance loss. To mitigate this problem, we can duplicate our cache structure into multiple *ways*, where a given address can be placed into any of the ways. In this case, we have `A` number of ways.

```

             Way 1                            Way 2                               Way A
+---+------------+------------+  +---+------------+------------+ ... +---+------------+------------+
| V |    Tag     |    Data    |  | V |    Tag     |    Data    | ... | V |    Tag     |    Data    |
+---+------------+------------+  +---+------------+------------+ ... +---+------------+------------+
|   |            | .......... |  |   |            | .......... | ... |   |            | .......... |
+---+------------+------------+  +---+------------+------------+ ... +---+------------+------------+
|   |            |            |  |   |            |            | ... |   |            |            |
+---+------------+------------+  +---+------------+------------+ ... +---+------------+------------+
|   |            |            |  |   |            |            | ... |   |            |            |
+---+------------+------------+  +---+------------+------------+ ... +---+------------+------------+
```

Another piece of information we are given is the cache data size, `S` bytes. This is the total size of all the data blocks, across all ways and sets.
This already gives us enough information to calculate the number of sets. The total cache data size is `S` , this divided by the number of ways, `A` , gives us the data size of one way ( `= S/A` ). Dividing this with the block size, `B` , gives us the number of blocks in one way, which is the number of sets ( `= S/(A*B)` ).

We are told that the memory is byte-addressable (one memory address corresponds to one byte of data). One such address consists of `k` bits. In the context of the cache, this address is divided into three parts.

```

k                                    0
+-----+-------------+----------------+
| Tag | Block index | Index in block |
+-----+-------------+----------------+
       log2(S/(A*B))        b
```

The least significant bits select the addressed byte from the data block. This data block contains `2^b` bytes, which are addressable using exactly `b` bits (as the number `x` can be represented using `log_2(x)` bits).

The next bits select the cache set (referred to as the block index). The same principle applies here. As we know that there are `S/(A*B)` sets, these can be indexed using `log_2(S/(A*B))` bits.

The remainder of the address is used as the *tag* in the cache. This part of the address makes sure that even if the lower bits of two addresses are equal, the value of one cannot be loaded from the cache when the other one is accessed (because the tag equality check is going to fail). The size of this tag is thus `k - log_2(S/(A*B)) - b` bits (the total length of the address minus the previous two fields).

We can now calculate the total size of the cache. There are a total number of `S/B` blocks (total data size / block size).
Each block contains `8B` data bits and contains the following metadata: `1` valid bit and the tag bits. All together, the cache size is:

 `= S/B * (8B + 1 + (k - log_2(S/(A*B)) - b))`

## Exercise 4.2

We see that we have a total number of 1024 blocks. Because this is a direct mapped cache, we also know that the number of blocks equals the number of sets, as there are no additional ways in the cache. From this, we can already conclude that we need `log_2(1024) = 10` index blocks to select the set.

We also know that one block contains 8 words. To index one of these words, we need `log_2(8) = 3` bits. The 32-bit addressing mode means that one word is 32 bits, 4 bytes long. To select one byte from this word, we need thus `log_2(4) = 2` more bits.

This completes the addressing, which means that the remainder of the memory address is used as the tag in the cache. This is `32 - 10 - 3 - 2 = 17` bits.

The total size of the cache is, using a similar calculation as before:

 `= 1024 * (8 * 32 + 1 + 17)`

For each set, we have a block size of `8 * 32` bits, and we have one valid bit and `17` tag bits per line.

## Exercise 4.3

You can try out all of these exercises in the [cache simulator](#cache-simulator) below!

Whenever we have to decide to which set a given address belongs to, it is useful to think about the address' representation in binary notation. If the block contains multiple words, the least significant bits of the address will determine the word index within the block. The following bits will determine the index of the set. The most significant bits are kept as the tag, which does not play a role in this exercise.

For the direct-mapped cache with 16 1-word blocks, we do not have any word index bits, as one block only contains one word. To index 16 bits, we need the least significant `log_2(16) = 4` bits of the address. We might notice that these 4 bits of the address always equal to the result of `address % 16` , as the more significant bits represent a part of the address that is a multiple of 16.

Taking `42 = 101010` as an example:

```

6    4      0
+----+------+
| 10 | 1010 |
+----+------+
```

The lowest 4 bits (the set index) give the result of `42 % 16 = 10` , while the upper bits (the tag) give the result of integer division: `42 // 16 = 2` . Of course, the sum of these is the original address: `2 * 16 + 10 = 42` .

Using this method, we can place all of the addresses in the first exercise, by using the modulo operation to find the correct set. If a given address maps to a block that is already occupied, we simply replace the contained value (and in practice, we would also replace the tag to know which address the value belongs to).

```

+----+----+
|  S |  W |
+----+----+
|  0 | 48 |
|  1 | -- |
|  2 |  2 |
|  3 |  3 |
|  4 |  4 |
|  5 | 21 |
|  6 | 22 |
|  7 | -- |
|  8 | -- |
|  9 | -- |
| 10 | -- |
| 11 | 11 |
| 12 | -- |
| 13 | 13 |
| 14 | -- |
| 15 | -- |
+----+----+
One hit at the second reference to 11.
```

If one block contains multiple words, we need to pay attention to two things: first, the lowest bits of the address will be used to index the word within the block, not the set.

In the second exercise, we have a block size of 4 bits, so we use the least significant 2 bits of the address to index these.

As the total size is 16 bits, we only have 4 sets. This means that the next two bits of the address will be used to index these sets.

Taking the example of address `42` again, the last two bits are `10` , so within a block, this address will be assigned to the third (watch out, we start from 0!) word. The next two bits in the address are coincidentally also `10` , so we know that it belongs to set 2.

We can again use a trick: we see that the position of the address in the cache is completely determined by the last 4 bits, so the result of the `% 16` operation again enough to place it.

The second thing we need to pay attention to is that when a word within a block is loaded, the neighboring values are also updated (cf. spatial locality). In other words, if address 1 is loaded from memory, the values of the memory locations of 0-3 are all loaded into the block in set 1.

```

+---+----+----+----+----+
| S | W0 | W1 | W2 | W3 |
+---+----+----+----+----+
| 0 |  0 |  1 |  2 |  3 |
| 1 |  4 |  5 |  6 |  7 |
| 2 |  8 |  9 | 10 | 11 |
| 3 | 12 | 13 | 14 | 15 |
+---+----+----+----+----+
2, 3 (H), 11, 16, 21, 13, 64, 48, 19, 11 (H), 3, 22 (H), 4, 27, 11
```

If our cache has multiple ways, that does not change the addressing. Within one set, the same addresses can be assigned to any of the blocks in each of the ways. If only some of the ways have valid values stored, a new address will be stored in an unoccupied way. If all of the ways are taken, we usually follow a Least Recently Used (LRU) replacement strategy, which means that we replace the block that has been accessed the longest time ago.

In the third exercise, we have a 2-word block size, so the last bit of the address is used for indexing the word. We know that the cache is 2-way set associative, and has a total size of 16 words. With the block size, this gives us 8 blocks, which are divided into 4 sets, as each set contains two blocks (2-way).

4 sets can be indexed with 2 bits, so in total we use 3 bits of the address for indexing, we can take `address % 8` to determine which set and word an address belongs to. The choice of block within the set is down to the replacement strategy we use. Once again, we also need to make sure to only replace full blocks, not just one word in the block.

```

+---+---+----+----+
| S | B | W0 | W1 |
+---+---+----+----+
| 0 | 0 | 48 | 49 |
|   | 1 | 64 | 65 |
| 1 | 2 | 26 | 27 |
|   | 3 | 10 | 11 |
| 2 | 4 |  4 |  5 |
|   | 5 | 12 | 13 |
| 3 | 6 | 22 | 23 |
|   | 7 | -- | -- |
+---+---+----+----+
2, 3 (H), 11, 16, 21, 13, 64, 48, 19, 11 (H), 3, 22, 4, 27, 11
```

## Exercise 4.4

The strength of the 1-word block cache is that it has 16 separate blocks.  Although the set-associative has just as many blocks, each block has twice as many potential memory addresses mapped on it. If we use a FIFO replacement, a sequence of 8, 16, 0 would insert and remove 8 out of a set-associative cache. The direct mapped cache would still have the 8.

## Cache simulator

<script src="/exercises/7-cache/script.js"></script>

<script>
    let cache = [];

    function drawCache() {
        let set = document.getElementById('setcount').value;
        let way = document.getElementById('waycount').value;
        let block = document.getElementById('blocksize').value;

        cache = construct(set, way, block);
        draw(cache, 'cache');
    }

    function insert() {
        let address = document.getElementById('address').value;
        let hit = insertAddress(cache, parseInt(address), 'cache');
        let span = document.getElementById('hit');
        if (hit) {
            span.innerText = 'Hit!';
        } else {
            span.innerText = 'Miss!';
        }
    }
</script>

Number of sets:
<input type="number" placeholder="Number of sets" id="setcount" />
<br>
Number of ways:
<input type="number" placeholder="Number of ways" id="waycount" />
<br>
Block size (words):
<input type="number" placeholder="Block size (words)" id="blocksize" />
<br>
<input type="button" onclick="drawCache();" value="Draw cache" />

Insert element (address): <input type="number" placeholder="Address" id="address" />
<br>
<input type="button" onclick="insert();" value="Go" /> <span id='hit'></span>

<div id='cache'></div>
