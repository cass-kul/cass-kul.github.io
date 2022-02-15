---
layout: default
title: "Session 4: Dynamic memory"
nav_order: 1
nav_exclude: false
has_children: false
has_toc: false
---

# Perspective

In this session, you will learn about dynamic allocation in C.

# Quick recap on pointers
## Definition of a pointer
Variables are stored in memory and have an ***address***. In C, the address of a
variable `i` can be obtained using `&i`. From instance, if an integer `i` is
stored in the memory at address `0x7f698878`, then `&i` returns `0x7f698878`.

A **pointer** is a variable which stores an *address*. For instance, in C, a
pointer that points to the variable `i` is declared with `int* j = &i`, meaning
`j` contains the address of `i`. A pointer can be **dereferenced** to access the
corresponding data. In C, dereferencing the pointer `j` is written `*j` and
returns the value of `i`.

**Example:**  
Example of a C program manipulating pointers where `p` is used  to print pointers:
<table>
<tr>
<th>Code pointers.c</th>
<th>Execution</th>
</tr>
<tr>
<td>
{% highlight c %}
#include <stdio.h>
int main() {
   int i = 5;
   int* j = &i;
   int k = *j;
   printf("  Value of i: %i\n", i);
   printf("Address of i: %p\n", &i);
   printf("  Value of j: %p\n", j);
   printf("Address of j: %p\n", &j);
   printf("  Value of k: %i\n", k);
   printf("Address of k: %p\n", &k);
}
{% endhighlight %}
</td>
<td>
{% highlight bash %}
$ gcc pointers.c -o run-pointers
$ ./run-pointers
  Value of i: 5
Address of i: 0x7f698878
  Value of j: 0x7f698878
Address of j: 0x7f698880
  Value of k: 5
Address of k: 0x7f69887c
{% endhighlight %}
</td>
</tr>
</table>

Memory layout after the execution:

| Address    | Value      | Program variable |
|:----------:|:----------:|:----------------:|
| ...        | ...        |                  |
| 0x7f698878 | 0x00000005 | i                |
| 0x7f69887c | 0x00000005 | k                |
| 0x7f698880 | 0x7ffe5f78 | j                |
| ...        | ...        |                  |

Notice that the order of variables in memory, chosen by the compiler, is not
necessary the same as the order of declaration in the program.

## Pointer arithmetic

## Pointers and arrays

## Pointer and structs

# Dynamic data structures
Arrays in C are static: they must be declared with a fixed length that is known
at compile time. This comes with some limitations, for instance if the **size is
not known at compile time** but only determined at runtime, or when the size
**grows dynamically** (the size increases or decreases at runtime).

Dynamic (i.e. resizeable) data structures come by default with many high-level
programming languages, such as `List` in Python or `ArrayList` in Java, but not
in C. Then how can we create the equivalent of a Python `List` in C?

**Solution?** Reserve a very large static array for every list.  
**Problem**:
- We have to allocate more than we actually need and the extra-allocated memory
  is wasted;
- What if the list grows even bigger?

In this session, we will first see how to create dynamic data structures
starting with lists, and then generalize to any dynamic data structures.

## Linked lists
Assume that a program reserves a big chunk of memory that it can use to store several lists:
``` armasm
.data
list_memory: .space 1000000
```
How can we use this to implement Lists?

> Hint: How can we combine multiple fixed size arrays to make a dynamically
> growing list in `list_memory`?

<details>
  <summary>Solution: you can click on arrow to expand but try to think about a solution first ;)</summary>
  <blockquote>
  A list can be implemented as a set of static arrays chained together using pointers. When the list is full, just create a new array and chain it with the previous one! This is called a linked list.
  </blockquote>
</details>

### Illustration:
1. **Initialization**: We use a pointer, called `list pointer` to record the
address of the next free memory location.  
![Empty memory with list pointer](/tutorials/img/list1.png)  
2. **Define a new list**: Let's use arrays of size 10 as the basic building
   block to implement our lists. Here we have defined two lists, meaning that we
   have allocated two consecutive arrays of size 10, and moved the `list pointer`
   to point to the next free memory location.  
![Empty memory with list pointer](/tutorials/img/list2.png)  
3. **Increase size of a list**: When `List 1` is full, we can extend it by
   allocating a new array in the free memory. In order to chain both array and
   get a list, we keep a pointer to the second array in the last cell of the
   first array. In the end, we just need the pointer to the first array of `List
   1` to reconstruct the whole list!  
![Empty memory with list pointer](/tutorials/img/list3.png)


### Implementation
Here is the RISC-V implementation that builds the linked list `List 1`:
1. Store list pointer in register, e.g. `s9` (random choice!)
2. Create a list:
   - Move list pointer in `s9` to next free memory location, i.e. increment it
     by 40 because size of allocated array = number of cells (10) * size of int
     (4 bytes);
   - Return a pointer to the newly allocated array (i.e. the old value of `s9`).
3. When the list is full:
   - Create new list and link it to the previous one
   - Notice that `s9` might have incremented between the first and the second
     calls to `create_list`, for instance to create a new list `List 2` like in
     the previous illustration.

``` armasm
.data
list_memory: .space 1000000
.globl main

.text
create_list:            # s9 keeps track of next free memory location
    mv    a0, s9        # return old value of s9 as pointer to new list
    addi  s9, s9, 40    # update the value of list pointer in s9
    ret
main:
    la s9, list_memory # Initialize list pointer s9
    jal create_list    # Create a new list and 
    mv t0, a0          # store a pointer to it in t0
    [...]              # Fill the list with data
    jal create_list    # Expand the list
    sw a0, 36(t0)      # Link the second part of the list to the first one
```

## Generalize to any data structures: Heap


### Implementation
``` armasm
.data
heap: .space 1000000

.globl main
.text

allocate_space:
    mv    t0, a0
    mv    a0, gp
    add   gp, gp, t0 # gp keeps track of the heap allocation
    ret

create_list:
    li     a0, 40
    addi   sp, sp, -4
    sw     ra, (sp)
    jal    allocate_space
    lw     ra, (sp)
    addi   sp, sp, 4
    ret

main:
    la     gp, heap  # initialize gp!
    jal     create_list
```


## Discussion

<!-- ### Exercise 0 (new) -->

<!-- Write a C program that asks the user for an integer value and prints out the square -->
<!-- of this value. -->

<!-- #### Solution -->

<!-- ```c -->
<!-- #include <stdio.h> -->

<!-- int main(void) { -->
<!--     int n; -->
<!--     printf("Your number: "); -->
<!--     scanf("%d", &n); -->
<!--     int square = n * n; -->
<!--     printf("The square of %d is %d\n", n, square); -->
<!--     return 0; -->
<!-- } -->
<!-- ``` -->
