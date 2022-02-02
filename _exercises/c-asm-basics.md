---
layout: default
title: "Session 1: C & assembly basics"
nav_order: 1
nav_exclude: false
has_children: false
has_toc: false
---

# Perspective

These exercise sessions will teach you how compilers translate high-level (procedural)
code, written in C, into assembly code, which is then executed on the CPU in a
machine code format.

-----------------------------------------:|:--------------------:|:--------------------
Methodiek van de Informatica              | Object-Oriented Code | `Car c = new Car();`
                                          | Procedural Code      | `malloc(sizeof(...));`
Computer Architecture and System Software | Assembly             | `add t0, t1, t2`
                                          | Machine Code         | `...0100110111010...`
Digitale Elektronica en Processoren       | Digital Hardware     | Logic gates

First, we will explain how the computer executes the machine code. Then we will
see how code written in a high-level programming language (C) is compiled into
assembly code.

In the majority of the exercise sessions, we will see how certain programming
concepts are represented at the assembly code level. Towards the end of the semester,
we will see some methods for increasing the performance of programs.

# Architecture basics

The computer is made up of several parts: control unit, ALU, RAM, registers. The RAM stores both instructions and data (Von Neumann architecture). The instructions stored in memory are in machine code format, which strongly relates to assembly code.

Assembly code manipulates the hardware and uses registers to compute (faster, but finite).

Different instruction sets of assembly for different architectures: x86, ARM, RISC-V.

Binary, mnemonic form.

RISC-V: open source, not CISC.

# The language C

C is a high level language that compiles directly to assembly. We will use this in the course to demonstrate high-level ideas before implementing them in assembly. One example of the high-levelness of C is that the programmer operates on variables, not registers.

But not as high level as other languages (Java, python): manual memory management, transparent memory locations, procedural, no error handling.

## Compiling C and running assembly

You can run the hello world example on [Godbolt](https://godbolt.org/).

Hello world example

Godbolt link, but you should set up gcc/clang locally for bigger projects.

See assembly output with `-S` .

Run handwritten assembly with RARS.

## Integers in C and assembly

Integers, basic arithmetic

Side-by-side examples of C and RISC-V (just `c = a + b` or something).

## User input handling in C

scanf/printf

### Exercise 0 (new)

Write a C program that asks the user for an integer value and prints out the square
of this value.

#### Solution

```c
#include <stdio.h>

int main(void) {
    int n;
    printf("Your number: ");
    scanf("%d", &n);
    int square = n * n;
    printf("The square of %d is %d\n", n, square);
    return 0;
}
```

## Registers in RISC-V

In the previous example, we've already seen registers being used, here is their list in RISC-V, along with register sizes and stuff.

## Breakdown of assembly instructions

Operation, destination, sources.

[ go back to the previous example here ]

## Pointers in C

Are C variables always stored in registers? What if we have too many? Storing them in memory. How can we see where they are stored?

Pointers

Interactive example

## Memory segments in assembly

So can we store variables in memory from assembly?

Memory segments, example with a `word`.

## Other data types

Basic ones, char, float, double

Size of data types

### Exercise 1 (2/1)

Write a RISC-V program that calculates the following: `c = a^2 + b^2`.
Use the data section to reserve memory for `a`, `b`, and `c`.

#### Solution

```armasm
.data
    a: .word 3
    b: .word 4
    c: .space 4
.text
    lw t0, a          # t0 = *a;
    lw t1, b          # t1 = *b;
    la a2, c          # a2 = c;
    mul t0, t0, t0    # t0 = t0 * t0;
    mul t1, t1, t1    # t1 = t1 * t1;
    add t2, t0, t1    # t2 = t0 + t1;
    sw t2, (a2)       # *a2 = t2;
```

### Exercise 2 (1/3)

Write a C program that asks the user for an integer. Print the address, the value
and the size in bytes of this integer. Now store the address of this integer in a pointer.
Then print the address, the value and the size in bytes of this pointer.

#### Solution

```c
#include <stdio.h>

int main(void) {
    int num;
    printf("Your number: ");
    scanf("%d", &num);
    printf("Address: %p, value: %d, size: %lu\n", &num, num, sizeof(num));

    int *pointer = &num;
    printf("Address: %p, value: %p, size: %lu\n", &pointer, pointer, sizeof(pointer));
    return 0;
}
```

### Exercise 3 (1/1)

Write a C program that asks the user for a positive integer and iteratively computes the
factorial of this integer.

> Hint: loops work the same way in C as they do in many other languages.

#### Solution

```c
#include <stdio.h>

int main(void) {
    int n;
    int fac = 1;
    printf("Your number: ");
    scanf("%d", &n);
    while (n > 0) {
        fac *= n;
        n--;
    }
    printf("The factorial is %d\n", fac);
    return 0;
}
```

# Branches

What are branches, how to use them in assembly, also to create loops.

Interactive example?

### Exercise 4 (2/3)

Translate the previous program to RISC-V. You don't have to ask for user input,
store the input integer in the data section of the memory.

#### Solution

```armasm
.data
    number:  .word 5
.text
    lw t0, number        # t0 = *number;
    mv t1, t0            # t1 = t0;
loop:                    # do {
    addi t1, t1, -1      #     t1--;
    ble t1, zero, end    #     if (t1 <= 0) { goto end; }
    mul t0, t0, t1       #     t0 *= t1;
    j loop               # } while (true);
end:
```

### Exercise 5 (2/4)

Write a RISC-V program that calculates: `c = a^b`.
Make sure that your solution works for all `b >= 0`!

#### Solution

```armasm
.data
    a: .word 2
    b: .word 1
    c: .space 4
.text
    lw t0, a            # t0 = *a;
    lw t1, b            # t1 = *b;
    la a2, c            # a2 = c;
    addi t2, zero, 1    # t2 = 1;
loop:
    beqz t1, end        # while (t1 != 0) {
    mul t2, t2, t0      #     t2 = t2 * t0;
    addi t1, t1, -1     #     t1--;
    j loop              # }
end:
    sw t2, (a2)         # *a2 = t2;
```

# Functions

The whole stack also here?

# Static arrays

# Structs
