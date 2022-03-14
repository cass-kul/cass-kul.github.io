---
layout: default
title: "Session 4: Dynamic memory"
nav_order: 4
nav_exclude: false
search_exclude: false
has_children: false
has_toc: false
gallery_images:
    - album/generalized_dynamic_alloc-1.png
    - album/generalized_dynamic_alloc-2.png
    - album/generalized_dynamic_alloc-3.png
    - album/generalized_dynamic_alloc-4.png
---
## Table of contents
{: .no_toc .text-delta }

1. TOC
{:toc}

# Introduction
In the previous sessions, you have seen how to allocate fixed (*static*) amounts of
memory to store programs variables or arrays in the `.data` section. In this
session, you will learn how to *dynamically allocate memory* for data structures
that can be resized at runtime (for instance, Python lists or Java
`ArrayList`s).

## Recap: pointers in C
In the [first exercise session](/exercises/c-asm-basics/#pointers-in-c), you had
an introduction to pointers in C. This is a quick reminder about how to use
pointers. In this session we will use pointers a lot, so, if necessary, you can
come back to the explanations in the [first exercise
session](/exercises/c-asm-basics/#pointers-in-c) or ask your teaching assistant
for more explanations.

Variables are stored in memory and have an **address**. The address of a
variable `i` can be obtained with `&i`. For instance, if an integer `i` is
stored in the memory at address `0x7f698878`, then `&i` returns `0x7f698878`.

A **pointer** is a variable that stores an *address*. For instance, a pointer
that points to the variable `i` is declared with `int *j = &i`, meaning `j`
contains the address of `i`. A pointer can be **dereferenced** to access the
corresponding data. In C, dereferencing the pointer `j` is written `*j` and
returns the value at the address pointed by `j` (here the value of `i`).

Here is an example of a C program using pointers. Remember that `%p` is used to print pointers:
<table>
<tr>
<th>pointers.c</th>
<th>Output</th>
</tr>
<tr>
<td>
{% highlight c %}
#include <stdio.h>
int main(void) {
   int i = 5;
   int *j = &i;
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

Using the information that was printed, we can reconstruct the memory layout of the program during the execution:

| Address    | Value      | Program variable |
|:----------:|:----------:|:----------------:|
| ...        | ...        |                  |
| 0x7f698878 | 0x00000005 | i                |
| 0x7f69887c | 0x00000005 | k                |
| 0x7f698880 | 0x7ffe5f78 | j                |
| ...        | ...        |                  |

> :warning: Notice that the order of variables in memory chosen by the compiler
> is not necessary the same as the order you declared your variables in the
> program.

## Pointer arithmetic
A pointer is an address, which is a numeric value, therefore one may wonder if
it is possible to perform arithmetic operations on pointers. However, if you
think about it, it does not really make sense to try to multiply pointers or add
two pointers to each other. Thus, only a few arithmetic operations are allowed
on pointers:
- Increment/decrement pointers
- Add/subtract integers to pointers
- Subtract two pointers of the same type (we won't detail this use case but if
  you're interested you can have a look at this [external
  resource](https://www.geeksforgeeks.org/pointer-arithmetics-in-c-with-examples/))

In the following program, we increment a `char` pointer and an `int` pointer and print the resulting value:
``` c
#include <stdio.h>

int main(void) {
  int a = 1;
  char *c = "abcd";
  int *p = &a;
  printf("    c = %p,     p = %p\n", c, p);
  printf("c + 1 = %p, p + 1 = %p\n", c + 1, p + 1);
}
```
Suppose the first `printf` prints `c = 0x50000044, p = 0x80000044`.
What output do you expect for the second `printf`?

> :fire: Warm-up 1: Try to run this program on your computer. Does the output
> match your expectation?

<details closed markdown="block">
  <summary>
    Solution
  </summary>
  {: .text-gamma .text-blue-000 }

> If the first `printf` prints `c = 0x50000044, p = 0x80000044`, the second
> `printf` will print `c + 1 = 0x50000045, p + 1= 0x80000048`. The pointer on
> `char` increases by 1 while the pointer on `int` increases by 4.

</details>

In C, pointer arithmetic does not follow the same rules as standard integer
arithmetic: when a pointer is incremented, its value increases by the *size of
its corresponding data type*. Hence, incrementing a pointer of type `char *`
increases its value by 1 (because the size of a `char` is 1 byte) whereas
incrementing a pointer of type `int *` or `char **` increases its value by 4
(because the size of `int` or `char *` is 4 bytes).

More generally, if you have a pointer `type *p` and an integer `n`, `p += n`
actually increases the value of the pointer `p` by `n * sizeof(type)`.
The same rule holds when subtracting a pointer with an integer: `p -= n`
decreases the value of the pointer `p` by `n * sizeof(type)`.

> :crystal_ball: As we will see in the next section, pointer arithmetic is
> especially convenient for iterating through arrays.

## Pointers and arrays
In the [second exercise session](/exercises/advanced-c-asm/#fixed-length-arrays)
we have seen how to represent a collection of homogeneous elements using **arrays**.

For instance, an array of 4 integers can be defined like this:
```c
int a[] = {1, 2, 3, 4};
```

The value of the array `a` is the address of the first element of the array: `a
== &a[0]`. It is even possible to use `*a = 5` to assign 5 to the first element
of the array, just like with a pointer! In that sense, an array is a bit similar
to a pointer to the first element of the array.

> :warning: Contrary to pointers, arrays variables cannot be modified (they are
> immutable). Hence, you can not do `a = a + 1`.

However, it is possible to define a pointer `int *p = a` to iterate through the
array:

<table>
<tr>
<th>Example.c</th>
<th>Output</th>
</tr>
<tr>
<td>
{% highlight c %}
#include <stdio.h>

int main(void) {
  int a[] = {1, 2, 3, 4};
  unsigned int size = 4;
  int *p = a; // NOT &a as a is already the address of the first element!

  for (int i = 0; i < size; i++) { // Iterate until p has reached the last element of the array
    printf("%p -> %d\n", p, *p);
    p = p + 1;
  }
}
{% endhighlight %}
</td>
<td>
{% highlight bash %}
0xfff9a20c -> 1
0xfff9a210 -> 2
0xfff9a214 -> 3
0xfff9a218 -> 4
{% endhighlight %}
</td>
</tr>
</table>

<!--
## Pointer and structs
It is also possible to define a pointer to a struct. For instance, if you have the following structure:
``` c
struct person {
  int age;
  int grade;
};
struct person s;
s.age = 13
```
You can use `struct person *p` to define a pointer to `s`.

A first solution to access the elements of the struct through `p` is to
dereference the pointer before accessing an element of the struct: `(*p).age`.
However, because working with pointers to structs is very common in C, the language defines
a dedicated operator, `->`, to facilitate accessing struct elements through
pointers. Thus, `p->age` is equivalent to `(*p).age`.

The following program illustrates how to use pointers to structures:
```c
void print_person(struct person *p) {
  printf("Age: %d, Grade: %d\n", p->age, p->grade);
}

int main(void) {
  struct person s;
  struct person *p;
  p = &s;
  p->age = 13;   // Sets s.age to 13
  (*p).age = 13; // Same as above
  p->grade = 18; // Sets s.grade to 18
  print_person(p);
}
```
-->

### Exercise 1
Consider the following C function, where `in1`, `in2` and `out` are all pointers
to arrays of `n` integers. What does the function do? Translate this function to RISC-V.

```c
{% include_relative dynamic-memory/ex1.c %}
```

{% if site.solutions.show_session_4 %}
#### Solution

```armasm
{% include_relative dynamic-memory/sol1.asm %}
```
{% endif %}

### Exercise 2
The following C function compares two strings. It returns 1 if they are equal
and 0 if they are not. Notice how we don't need to pass the length of the strings for this function!
Translate this function to RISC-V.

```c
{% include_relative dynamic-memory/ex2.c %}
```

{% if site.solutions.show_session_4 %}
#### Solution

```armasm
{% include_relative dynamic-memory/sol2.asm %}
```
{% endif %}

# Dynamic data structures
Arrays in C are static: they must be declared with a fixed length that is known
at compile time. This comes with some limitations, for instance if the **size is
not known at compile time** but only determined at runtime, or when the size
**grows dynamically** (the size increases or decreases at runtime).

Dynamic (i.e. resizeable) data structures come by default with many high-level
programming languages, such as `List` in Python or `ArrayList` in Java, but not
in C. Then how can we create the equivalent of a Python `List` in C?

A possible solution is to reserve a very large static array for every list.

**Problem**:
- We have to allocate more than we actually need and the extra-allocated memory
  is wasted;
- What if the list grows even bigger?

In the next sections, we will first see how to create dynamic data structures
starting with [lists](#linked-lists), and then
[generalize](#generalize-to-all-data-structures-the-heap)
to any dynamic data structures.

## Linked lists
Assume that a program reserves a big chunk of memory that it can use to store several lists:
``` armasm
.data
    list_memory: .space 1000000
```

> :fire: Warm-up 2: Can you think of a way to combine multiple fixed size arrays
> to make a dynamically growing list in `list_memory`?

<details closed markdown="block">
  <summary>Solution:</summary>  {: .text-gamma .text-blue-000 }
  <blockquote>
  A list can be implemented as a set of static arrays chained together using pointers. When one of the arrays is full, just create a new array and chain it with the previous one! This is called a linked list.
  </blockquote>
</details>

Let's illustrate the concept of linked lists with a running example:
1. **Initialization**: We use a pointer, called *list pointer* to record the
address of the next free memory location. (This is a bit similar to the stack pointer that you've seen in the last session.)
![Empty memory with list pointer](/exercises/img/list1.png)
2. **Define a new list**: We will use arrays of size 10 as the basic building
   block to implement our lists. Here we have defined two lists, meaning that we
   have allocated two consecutive arrays of size 10, and moved the *list pointer*
   to point to the next free memory location.
![Empty memory with list pointer](/exercises/img/list2.png)
3. **Increase size of a list**: When `List 1` is full, we can extend it by
   allocating a new array in the free memory. In order to chain both arrays and
   get a list, we keep a pointer to the second array in the last cell of the
   first array. In the end, we just need the pointer to the first array of `List
   1` to reconstruct the whole list!
![Empty memory with list pointer](/exercises/img/list3.png)


### RISC-V implementation
Let us now see how to implement this in RISC-V.

First, we need to store the list pointer in a register. Let us (randomly) pick `s9`.
```armasm
la s9, list_memory
```

Then, to create a list we need to:
- Reserve space for a new array and update the list pointer in `s9` to point to
  the next free memory location. This means increasing the value of `s9` by
  the size of the array (40);
- Return a pointer to the newly allocated array (i.e. the old value of `s9`).

``` armasm
allocate_list:          # Assume s9 keeps track of next free memory location
    mv    a0, s9        # Return old value of s9 as a pointer to new list
    addi  s9, s9, 40    # Update the value of list pointer in s9
    ret
```

When the list is full, we need to:
- Allocate a new array by calling `allocate_list`
- Link it to the previous one by storing the address of the newly created array
  in the last cell of the previous array.
Assuming the pointer to the previous list is located in `s0`, this can be achieved with the following code:

```armasm
jal allocate_list   # Allocate new array
sw a0, 36(s0)       # Link the second part of the list to the first one
```

> :fire: Warm-up 3: put all pieces together to reconstruct the illustration with
> `List 1` and `List 2` given above. You can store the pointer to `List 1` in
> `s0` and the pointer to `List 2` in `s1`

<details closed markdown="block">
  <summary>
    Solution
  </summary>
  {: .text-gamma .text-blue-000 }

``` armasm
{% include_relative dynamic-memory/warm-up3.asm %}
```
</details>

We now have a dedicated memory to store lists and an allocator to make our lists
grow (almost) as large as we want! However, our solution only allows lists,
while there are many more useful data structures. Let's see how we can extend
our solution to work with other data structures.

## Generalize to all data structures: the heap
In the RISC-V memory layout, illustrated below, the `.data` segment is used to
store statically allocated data (such as C arrays or constants) while the `heap`
segment holds dynamically allocated data structures like lists, trees, etc.

![Memory Layout in RISC-V](/exercises/img/memory-layout.png "Memory Layout in RISC-V")

In the next session, you will see how to actually ask the operating to dynamically allocate memory for your program. For now, we will adopt a simpler approach and consider that we have a dedicated space for the heap in the `.data` section:
``` armasm
.data
    heap: .space 1000000
```

What we want is to use that heap to allocate arbitrary data structures. For
instance, in the following example: we first allocate a list, then a binary
tree, and finally extend the first list (click or slide through the images).

{% include gallery.html images=page.gallery_images ratio_image="album/ratio.png" %}

To be able to allocate memory for different data structures, we need to
generalize the allocator that we defined before (`allocate_list`) to allocate
arbitrary large chunks. This is simple, we can just add the size as a parameter
to the function:

``` armasm
allocate_space:      # Assume that s9 keeps track of the next free memory location in the heap
    mv    t0, a0     # The size to allocate is provided as an argument to the function
    mv    a0, s9     # Return old value of s9 as a pointer to the new allocated space
    add   s9, s9, t0 # Update the value of heap pointer in s9
    ret
```

Finally, we can re-implement our simple list allocator using our new
`allocate_space`:

``` armasm
allocate_list:
    addi   sp, sp, -4
    sw     ra, (sp)
    li     a0, 40
    jal    allocate_space
    lw     ra, (sp)
    addi   sp, sp, 4
    ret

main:
    la     s9, heap
    jal    allocate_list
```

### Exercise 3
Create a dynamic [stack data
structure](https://www.tutorialspoint.com/data_structures_algorithms/stack_algorithm.htm)
on the heap (see the illustration below for an example). Use the simple
allocator `allocate_space` given below and write the following functions in
RISC-V (consider that `stack_pointer` is the type of the pointer to the `top`
pointer):
- `stack_pointer stack_create(void)`: Creates a new, empty stack: basically it
  allocate space for the `top` pointer.
  1. Allocates enough heap memory to store a pointer to the top of the stack.
  2. Since the stack is empty, initialize this `top` pointer to `0`: (this is
  called a *null pointer*).
  3. Return the address of this `top` pointer in `a0`. This can be considered the
  address of the stack (in the main you should keep this pointer in a safe
  place, it is the pointer that you will use to reconstruct the whole stack!).
- `void stack_push(stack_pointer, int)`: Adds a new element at the top of the
  stack.
  1. The function takes the address of the `top` pointer in `a0` and the value to
  be pushed on the stack in `a1`.
  2. It allocates enough heap memory to store the new value and to store a
  reference to the previous top.
  3. It updates 
  3. It also modifies the `top` pointer to point to the newly allocated element.
- `int stack_pop(stack_pointer)`: Removes and returns the top element from a stack.
  1. The function takes the `top` pointer in `a0`.
  2. It updates the `top` pointer to point to the element before the actual top
     element.
  3. Finally, it return the value of the popped element in `a0`.
Don't forget the calling conventions!

<center>
<img src="/exercises/img/stack_representation.png" alt="Illustration of a stack with three elements. Every square corresponds to a 32-bit region on the heap." />
</center>

```armasm
{% include_relative dynamic-memory/ex3.asm %}
```

{% if site.solutions.show_session_4 %}

#### Solution

```armasm
{% include_relative dynamic-memory/sol3.asm %}
```

{% endif %}


### Exercise 4
Would it be possible to allocate growing data structures, like a binary tree or
a linked list, on the call stack? The following code provides a suggestion for a
simple allocator that tries to do exactly this. Can you see any problems with
this approach?

```armasm
{% include_relative dynamic-memory/ex4.asm %}
```

<details closed markdown="block">
  <summary>Solution:</summary>  {: .text-gamma .text-blue-000 }

Allocating dynamic memory on the stack is not possible:
1. The `sp` register is callee-save, so the `allocate_stack` function breaks
   the calling conventions.
2. That also means that when you call `allocate_stack`, your function will break
   the calling conventions if it doesn't restore the stack pointer.
3. If you do restore the stack pointer, you are also deallocating dynamic memory
   that has been reserved in this function. In theory, yes, you can allocate on
   the stack. But then the allocated dynamic memory can never live longer than
   the function itself, since you need to restore the stack pointer (deallocate
   the memory) before returning. That makes a simple function such as the
   `stack_create` or `stack_push` from previous exercises impossible to write.
   They simply can't return addresses to newly allocated stack space - it has to
   be deallocated first!

</details>

### Exercise 5
Can you come up with an allocator function that allows you to free previously
allocated memory? The allocator should re-use previously freed memory. The
following steps might help:
1. Store the address of the first empty (free) heap region in a global variable,
1. Allocate space for metadata when creating chunks,
1. Store the size of a chunk in the chunk metadata,
1. For free chunks, also store the address of the next free chunk in the chunk
metadata.

{% if site.solutions.show_session_4 %}

#### Solution

```armasm
{% include_relative dynamic-memory/sol5.asm %}
```

{% endif %}
