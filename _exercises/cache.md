---
layout: default
title: "Session 7: Caches and Microarchitectural Timing Attacks"
nav_order: 7
nav_exclude: true
search_exclude: true
has_children: false
has_toc: false
flush_reload:
    - /exercises/7-cache/flush_reload/flush_reload1.png
    - /exercises/7-cache/flush_reload/flush_reload2.png
    - /exercises/7-cache/flush_reload/flush_reload3.png
    - /exercises/7-cache/flush_reload/flush_reload4.png
    - /exercises/7-cache/flush_reload/flush_reload5.png
    - /exercises/7-cache/flush_reload/flush_reload6.png
prime_probe:
    - /exercises/7-cache/prime_probe/prime_probe1.png
    - /exercises/7-cache/prime_probe/prime_probe2.png
    - /exercises/7-cache/prime_probe/prime_probe3.png
    - /exercises/7-cache/prime_probe/prime_probe4.png
    - /exercises/7-cache/prime_probe/prime_probe5.png
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

Over the years, a performance gap has formed between the processor and the
memory unit. As show in the figure below, processor performance has been
increasing much faster than memory performance. Consequently, the processor has
become much faster than the memory, forming a bottleneck for the performance
of the computer in general.

![Illustration of the performance gap between memory and CPU](/exercises/7-cache/performance_gap.png){: .center-image }

To solve this issue, **caches** were introduced. Cache memories are not as fast
as registers, but can include more data, and are much faster than the main
memory. However, they are also more expensive than the main memory and therefore
a lot smaller. Most commercial CPU typically offer a hierarchy of cache: Level 1
cache (L1) is the fastest but also the smallest cache, Level 2 cache (L2) is
slower but larger, and Last Level Cache LLC which is the slowest but the
fastest. 

![Illustration of memory hierarchy in a computer](/exercises/7-cache/memory_hierarchy.png){: .center-image }

Caches can be local to a single processor core (this is typically for case for
L1 and L2 caches), or shared across multiple cores. Finally, the L1 cache is
usually split into an instruction cache (L1D), which contains program
instructions, and a data cache (L1I), which contains program data.

![Illustration of cache hierarchy in a computer](/exercises/7-cache/cache_hierarchy.png){: .center-image }


<!-- | ![Illustration of memory hierarchy in a computer](/exercises/7-cache/memory_hierarchy.png){: .center-image } | ![Illustration of cache hierarchy in a computer](/exercises/7-cache/cache_hierarchy.png){: .center-image } | -->

## Locality principle

Programs usually access a relatively small portion of the address space at a time.

In particular, when a program accesses a memory location, it is likely to access
it again in a near future. This is called **temporal locality**. Hence a memory
location that is accessed by a program can be cached to speed up future
accesses!

![Illustration of temporal locality](/exercises/7-cache/temporal_locality.png){:
.center-image }

Additionally, when a program accesses a memory location, it is likely to access
nearby memory location in a near future (think for instance about nearby
variables in the stack or array members). This is called **spatial locality**.
Hence when a memory location is accessed, we can transfer entire blocks
(multiple contiguous words) into the cache at once.

![Illustration of temporal locality](/exercises/7-cache/spatial_locality.png){:
.center-image }

By exploiting these two locality principles, cache can result in a huge
performance gain, even though they are small.


## Terminology
Consider a program that access a memory address: `lw x0, 0x10010000`.

We say that we have a **cache miss** if the address `0x10010000` is not in the
cache, (for instance if it is the first time it is accessed by the programs). In
that case, the value is requested from the DRAM and the memory access is *slow*.
The value is then placed in the cache for later use (following the temporal
locality principle).

We say that we have a **cache hit** if the address `0x10010000` is in the cache.
In this case, the corresponding value is directly served from the cache and the
memory access is *fast*.

Hit rate, miss rate? TODO

# Timing attacks
Because caches introduce *timing variations* based on the memory accesses of a
program, an attacker use timing to infer which memory addresses are accessed by
a victim! In particular, on shared architecture (like for instance a remote
server shared between multiple users), an attacker can *monitor the state of the
cache* (by observing cache hits and misses) to infer which cache lines are
accesses by a victim. If the memory addresses accessed by the victim depend on
secret data, the attacker can ultimately infer information about these secret
data, leading to critical security vulnerabilities. 

Attacks that exploit the *state of the cache* as a way to leak secret data, are
called **cache attacks**. They are part of a more general class of attacks,
called **timing attacks**, which exploit *timing variations* of a system to
leak secret data.

> :crystal_ball: We will see two different examples of cache attacks later in the session.
> But first, let's illustrate basic timing attack with some exercises.

TODO!!! Do the programs in this session still work on the M1?

### Exercise 2: Mount a timing attack
First, download the archive [code.zip](/exercises/7-cache/code.zip), which
contains the program for this exercise (and the next one). The file `passwd.c`
contains the code of a password checker. In this exercise, you have to infer the
value of the password using timing attacks (the password, given in `secret.h` so
for the sake of the exercise, please do not open the file).

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

#### Exercise 2.1: Guess the length
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

It's time to guess the password. First, we can notice that the program exits immediately if we provide a password with an incorrect length.

``` c
if (user_len != secret_len)
    return 0;
```

If we guess the length incorrectly, the program exits. If we guess it correctly, it continues to compare the individual characters in the password.

This means that based on the execution time, we can tell whether we guessed the length correctly: the program will take longer to execute in that case.

> :fire: Use timing measurements to guess the length of the password.

<!-- ``` bash -->
<!-- Enter super secret password ('q' to exit): 0 -->
<!-- time (med clock cycles): 68 -->
<!-- Enter super secret password ('q' to exit): 00 -->
<!-- time (med clock cycles): 70 -->
<!-- Enter super secret password ('q' to exit): 000 -->
<!-- time (med clock cycles): 372 -->
<!-- ``` -->

<!-- Now we know that the password consists of 3 characters. -->


#### Exercise 2.1: Guess the digits
Let us examine how the program compares the individual characters:

``` c
for (i = 0; i < user_len; i++)
{
    if (user[i] != secret_pwd[i])
        return 0;
}
```

The same principle applies here: the program quits at the first character that does not match. This means that the longer the execution takes, the more characters at the start of the password we managed to guess correctly.

This way, we can guess the characters one-by-one, starting from the start of the
string. Assuming that the password is a pin made of `N` digits, this means that
to guess the entire password, we need a total of `N * 10` guesses. Compare this
with `10^N` guesses if we could not guess one-by-one, but would have to iterate
over every possible combination!

> :fire: Use timing measurements to guess the value of the password, one character at a time.

<!-- ``` bash -->
<!-- Enter super secret password ('q' to exit): 200 -->
<!-- time (med clock cycles): 372 -->
<!-- Enter super secret password ('q' to exit): 300 -->
<!-- time (med clock cycles): 372 -->
<!-- Enter super secret password ('q' to exit): 400 -->
<!-- time (med clock cycles): 372 -->
<!-- Enter super secret password ('q' to exit): 500 -->
<!-- time (med clock cycles): 782 -->
<!-- ``` -->

<!-- ``` bash -->
<!-- Enter super secret password ('q' to exit): 510 -->
<!-- time (med clock cycles): 784 -->
<!-- Enter super secret password ('q' to exit): 520 -->
<!-- time (med clock cycles): 1072 -->
<!-- ``` -->

<!-- ``` bash -->
<!-- Enter super secret password ('q' to exit): 522 -->
<!-- time (med clock cycles): 1070 -->
<!-- Enter super secret password ('q' to exit): 523 -->
<!-- time (med clock cycles): 1070 -->
<!-- Enter super secret password ('q' to exit): 524 -->
<!-- -\-> You entered: '524' -->
<!--  _______________ -->
<!-- < ACCESS ALLOWED > -->
<!--  --------------- -->
<!--         \ -->
<!--          \ -->
<!--         .--. -->
<!--        |o_o | -->
<!--        |:_/ | -->
<!--       //   \ \ -->
<!--      (|     | ) -->
<!--     /'\_   _/`\ -->
<!--     \___)=(___/ -->

<!-- time (med clock cycles): 1342 -->
<!-- ``` -->

## Basic cache attack: Flush+Reload
Cache attack, just as the timing attack on the password checker illustrated
above, exploit variations of execution time to infer secret data. By measuring
the execution time of a *memory access*, an attacker can determine whether a
memory access results in a *cache hit* or a *cache miss*. Using this
information, the attacker can determine if a victim has accessed the same memory
location!

Let us look at a basic cache attack, called Flush+Reload **Flush+Reload**.
Flush+Reload rely on an instructions, offered by some CPUs, to *flush* the
cache. We illustrate **Flush+Reload** with a step-by-step example (notice that
each bullet number corresponds to a slide in the slideshow below):
1. Consider that an attacker and a victim share some memory so that a variable
   `a` is accessible to both the attacker and a victim;
2. **Flush:** the attacker flushes the address `&a` from the cache;
3. **Victim execute:** The attacker let the victim execute. Assuming `secret = 1`, the victim
   requests the address `&a`, which produces a cache miss;
4. The address `&a` is then requested from DRAM and placed in the cache;
5. **Reload:** The attacker tries to access again the address `&a` and *time the memory
   access*. If the access is fast (cache hit) then the attacker can infer that
   the value has been accessed by the victim, and therefore that `secret = 1`;
6. Alternatively, the attacker can try to access the variable `b`. Because the
   access is slow (cache miss), the attacker can infer that the value has *not*
   been accessed by the victim, and again conclude that `secret = 1`.
   
{% include gallery.html images=page.flush_reload  ratio_image="/exercises/7-cache/flush_reload/ratio.png" %}

Flush+Reload is a *very reliable and easy* attack as it does not require
knowledge of internal cache organization. However, it requires a *shared memory*
between an attacker and its victim in order to flush the victim's cache lines
and hence is only applicable in a limited number of scenarios.

### Exercise 3: Mount a Flush+Reload attack
The `flush-and-reload.c` of the [code.zip](/exercises/7-cache/code.zip) archive
file contains the following function:

``` c
void secret_vote(char candidate)
{
    if (candidate == 'a')
        votes_a++;
    else
        votes_b++;
}
```

We want to detect which of the candidates the user voted for. To increase the
vote count for candidate `a` or for candidate `b`, the program first has to load
the corresponding current number of votes from memory (i.e. `votes_a` or
`votes_b`). This is the access we will try to detect. Based on whether `votes_a`
or `votes_b` has been accessed, we know which candidate got the vote.

> :fire: Detail the three steps to mount a successful flush + reload attack
> onthis program.

<details closed markdown="block">
  <summary>
    Solution
  </summary>
  {: .text-gamma .text-blue-000 }

Using the Flush+Reload technique, we need to take the following steps:
1. Flush `votes_a` from the cache;
2. Let the `secret_vote` function execute with a secret inpu `candidate`. This
   will load the value of either `votes_a` or `votes_b` from memory, and place
   it in the cache;
3. After the execution is done, reload `votes_a`. If the access time is low,
   this signals a cache hit. A cache hit in turn indicates that the victim
   process has accessed `votes_a`, which means a vote for *candidate A*. On the
   other hand, if the access time is high, this means the value has not been
   cached, this is not the candidate the user voted for.

Of course, the above process could be executed with `votes_b` in place of `votes_a` . Since there are only two candidates, it suffices to check whether one of the two variables has been accessed.
</details>

Edit the `main` function in `flush-and-reload.c` to implement the missing
*flush* and *reload* attacker phases. You can use respectively the provided
`void flush(void *adrs)` and `int reload(void *adrs)` functions. The latter
returns the CPU cycle timing difference needed for the reload. If necessary,
compensate for timing noise from modern processor optimizations by repeating the
experiment (steps 1-3 above) a sufficient amount of times and taking the median
or average.

<!-- In order to draw a conclusion in the above example, we need to have an idea about what a "low" and "high" access time is. To make our job easier, we can just measure the access time of both the `votes_a` and `votes_b` variables and see which one takes considerably less time: that one is the one the user voted for. -->

<!-- Using the provided functions, this is simply: -->

<!-- ``` c -->
<!-- flush(&votes_a); -->
<!-- flush(&votes_b); -->
<!-- secret_vote('b'); -->
<!-- time_a = reload(&votes_a); -->
<!-- time_b = reload(&votes_b); -->
<!-- ``` -->

<!-- Similarly to the previous example, we will compensate for variations in the timings by averaging the measurements over multiple executions. The final code is thus: -->

<!-- ``` c -->
<!-- int SAMPLES = 1000; -->
<!-- unsigned long long time_a = 0, time_b = 0; -->
<!-- for (int i = 0; i < SAMPLES; ++i) { -->
<!--     flush(&votes_a); -->
<!--     flush(&votes_b); -->
<!--     secret_vote('b'); -->
<!--     time_a += reload(&votes_a); -->
<!--     time_b += reload(&votes_b); -->
<!-- } -->
<!-- printf("A avg: %llu, B avg: %llu\n", time_a / SAMPLES, time_b / SAMPLES); -->
<!-- ``` -->

<!-- This will provide us with an output from which it is clear to see which candidate has been voted for: -->

<!-- ``` bash -->
<!-- $ gcc flush-and-reload.c -o fnr -->
<!-- $ ./fnr -->
<!-- A avg: 419, B avg: 120 -->
<!-- ``` -->

# Cache placement policies
The cache placement policy determines *where* a memory address should be placed
in the cache.

## Direct mapping
Let us start with the structure of the cache. The cache is a table that contains
multiple rows, these are called the **cache sets**. A cache set can include one or more cache blocks (or cache lines).

The simplest cache placement policy, called **direct mapping**, maps every
memory address to a *unique* block in the cache.

Take for instance the cache model given below, where each cache set only
contains a single block. Given a memory address, the index of the corresponding
cache set is determined using the two least significant bits (`index = adress %
4`). Because multiple address map to a single cache line, the cache also needs
to keep track of a **tag**, corresponding to the most significant bits of the
address. Therefore, given an address, the index determine where to look for the
data in the cache and the tag indicate whether we have a cache hit or a cache
miss.

![Illustration of a direct mapped
cache](/exercises/7-cache/direct_mapped_cache1.png){: .center-image }

A memory address, composed of a tag `t` and an index `i`, is in the cache (cache
hit) if the tag at index `i` in the cache matches `t`. For instance, accessing
the address `0001` (i.e. tag=`00`, index=`01`) results in a cache hit because
the tag in the cache at index `01` is `00`. However, accessing the address
`0010` (i.e. tag=`00`, index=`10`) results in a cache miss because the tag in
the cache at index `10` is `10`.


The data in one cache line typically contains more than one byte. This is to
enable spatial locality: when the data from a certain address is loaded, the
contents of the neighboring memory locations are also placed in the cache, in
case they are also accessed in the future. The size of one of these data blocks
is called the *block size*.

For instance in the cache model given below, each cache set is made of 4 blocks.
The lower bits of the address correspond to the offset of the data in a cache
set (i.e. which cache block). For instance, the address `001000` corresponds to
the value `A0`, while the address `001001` corresponds to the value `A1`.

![Illustration of a direct mapped
cache where a cache set contains 2 cache blocks](/exercises/7-cache/direct_mapped_cache2.png){: .center-image }

> :bulb: **Summary.**\\
> A cache is made of 2^k sets (or cache lines), containing 2^b blocks.
> A memory address (of size 32 bits) is composed of:
> 1. an offset (b least significant bits) which determines the cache block;
> 2. an index (next k bits), which determine the cache set;
> 3. a tag (remaining 32-(k+b) most significant bits), which determine whether
> we have a cache miss or a cache hit.
> Additionally, the cache contains a *Valid* bit, which indicates whether a
> cache line is valid or not (e.g. in order to synchronize data across
> different caches).

![Summary of a direct mapped cache](/exercises/7-cache/direct_mapped_cache_summary.png){: .center-image }

## Set-associativity
A limitation of direct-mapped caches is that there is only one block available
in a set. Every time a new memory is referenced to the same set, the block is
replaced is replaced, which causes conflict miss. Imagine for instance a program
that accesses frequently addresses `000100` and `010100` in the above
illustration. Because both address map to the same cache set (at index `01`),
accessing `010100` evicts `000100` from the cache (and vice versa). Hence,
accessing both addresses alternatively results in a sequence of cache miss,
which causes a performance loss.

To mitigate this problem, we can duplicate our cache structure into multiple
**ways**, where a given address can be placed into any of the ways. We
illustrate below a 2-way cache. Now, even though `000100` and `010100` map to
the same cache set (at index `01`), they can be placed in two different way and
can be in the cache at the same time!

![Illustration of a 2-way set-associative cache](/exercises/7-cache/2-way_associative_cache.png){: .center-image }


Finally, a **fully associative cache** is made of a *single cache set*
containing multiple ways. Hence a memory address can occupy any of the ways and
is solely identified with its tag (no need for an index because there is only
one set!). Fully-associative caches ensure full utilization of the cache: a
block is never evicted if the cache is not full. When the cache is full, the
evicted line is determined by a replacement policy (e.g. the least recently used
block is replaced). However, searching for an address in a fully associative
cache is expensive: it takes time (and power) to iterate through all cache
blocks and find a matching tag.

> :bulb: Notice that a 1-way associative cache corresponds to a direct-mapped
> cache. Hence, a n-way set-associative cache provides an interesting tradeoff
> between a direct-mapped cache and a fully associative cache.

![Illustration of a n-way set-associative cache](/exercises/7-cache/n-way_associative_cache.png){: .center-image }

## More advanced cache attacks: Prime+Probe
Utilizing knowledge about the cache organization (i.e. placement policies and
cache collisions), an attacker can perform cache attacks across protection
domains!

**Prime+Probe** is a cache attack that allows an attacker to infer information a
a victim memory accesses without requiring shared memory (unlike Flush+Reload):
1. Consider that an attacker and a victim executing on the same machine (but
   without shared memory). The victim has access to a variable `a` and the
   attacker has access to a variable `c` such that `a` and `c` map to the same
   cache line;
2. The attacker evicts the address `&a` from the cache by accessing the address
   `&c`;
3. The attacker let the victim execute. Assuming `secret = 1`, the victim
   requests the address `&a`, which produces a cache miss;
4. The address `&a` is then requested from DRAM and placed in the cache,
   evicting the attacker's data `c`;
5. The atttacker tries to access again the address `&c` and *times the memory
   access*. If the access is slow (cache miss) then the attacker can infer that
   `a` has been accessed by the victim, and therefore that `secret = 1`;

{% include additional_gallery.html images=page.prime_probe ratio_image="/exercises/7-cache/flush_reload/ratio.png" %}


# TODO
## Exercise 4.1
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
