---
layout: default
title: "Session 1: C & assembly basics"
nav_order: 1
nav_exclude: false
has_children: false
has_toc: false
---

# Introduction

In the CASS exercise sessions, you will learn how programs are executed on computers.
We will explain high-level concepts in the programming language C,
then show how these concepts are translated to assembly code by the compiler.

You will also learn how the CPU executes the (generated) machine code, and
which hardware features are used to make this code more performant.

The following table shows how this course fits into the hardware-software stack
of computers that you learn about in different courses. CASS covers a broader
range in this stack than many other courses.

Course                              | Topics               | Example
-----------------------------------:|:---------------------|:--------------------
Methodiek van de Informatica        | Object-Oriented Code | `Car c = new Car();`
CASS                                | Procedural Code      | `malloc(sizeof(...));`
CASS                                | Assembly             | `add t0, t1, t2`
CASS                                | Machine Code         | `...0100110111010...`
Digitale Elektronica en Processoren | Digital Hardware     | Logic gates

The majority of the sessions will focus on writing assembly programs from scratch.
This first session is more theoretical, but it's very important for the later sessions
that you understand the concepts covered now. If you have any questions, ask your
teaching assistant or reach out to us on the Toledo forums!

# Architecture basics

Modern computers are made up of several hardware components. Most of these follow the so-called
von Neummann architecture. This means that the random access memory (RAM) contains both
program code and the data this program operates on. (This is in contrast to Harvard
architectures, where the instructions and data are stored in separate memory modules).

The computer's operation is sometimes called the `fetch, decode, execute cycle`.
Instructions are fetched from RAM, decoded by the control unit, then executed in the
arithmetic and logic unit (ALU). Finally, the result of the computation might be written back
to RAM.

The computations are usually performed on values stored in registers. These allow a small number of
values to be stored inside the CPU. This enables much faster computations than if the values
would have to be fetched from RAM. In fact, in later sessions we will see how caches are used
to speed up accesses to values that are not stored in registers and would have to be fetched from
RAM.

These designs are called `stored-program computers`, highlighting that the code that is
executed is stored in memory. These instructions are stored in [machine code](#) format, which
is usually compiled from a high-level program by a compiler.

Machine code refers to the binary format of instructions that the CPU can execute. These are usually
simple instructions, such as addition or subtraction (of [register](#) values), loading or storing values in memory.
The assembly language representation of these instructions is called the `mnemonic form`.
An `assembler` program can compile the mnemonic programs into machine code. You will see this in the
[RARS](#) environment.

- Machine code: 01010101
- Mnemonic format: `addi t0, zero, 5`

## Instruction set architectures (ISAs)

How do we know which instructions we (or the compiler) can use when writing assembly code?
Different processors can execute different instructions. The list of instructions a given CPU can
execute is defined in the instruction set architecture (ISA). This specification includes the list of
possible instructions (and their effects), but also the list of registers or other hardware features that must be supported
to be able to execute the instructions.

Today the most popular ISA is x86, which is implemented by most Intel and AMD processors. x86 is called a
CISC (complex instruction set computer), its specification has evolved over many years and currently includes
thousands of instructions, some of which are very specialized to increase performance (e.g., dedicated
instructions for performing AES encryption).

In this class, we will focus on a RISC (reduced instruction set computer) ISA, namely RISC-V. RISC ISAs
contain a lot fewer instructions and are easier to write by hand and understand. This does not necessarily mean
worse performance however! Apple's M1 processor also uses a RISC ISA (ARMv8) and outperforms many other
commercial processors.

RISC-V is an open standard, both the specification of the ISA and many of the development tools and
reusable components are open-source, which makes using the ISA, experimenting with it, and extending
it easier. These days it is being increasingly used not only in academia, but also in industry.

# The C language

In CASS, we will use the C language to showcase programming concepts, which we then translate to
RISC-V assembly. We chose this language because it's widely used in systems programming, its procedural
style is not so different from assembly as some other languages (such as object-oriented languages)
would be, and it's easy to examine the compiled assembly code using built-in tools in the operating system.

Many features in modern programming languages were inspired by C, so you will find many similarities with
modern languages when writing C. Some of these include how you declare and use variables, writing loops and
conditional statements, or working with functions.

In other aspects, C has a closer connection to the underlying operating system concepts. The programmer needs
to manage dynamic memory manually; for variable size objects (such as lists that can have an arbitrary length)
the programmer has to manually request memory chunks from the operating system and return them after
no longer needing them. Many features in C also require explicitly working with the (virtual) memory address
of certain variables, not only their values.

## Compiling C and running assembly

Let's test your [C compiler setup](#) with a simple `hello world` example.

```c
#include <stdio.h>

int main(void) {
    printf("Hello world!\n");
    return 0;
}
```

If you save the contents of this file into `hello.c`, you can compile and run your program with the
following commands:

```shell
$ gcc hello.c -o hello
$ ./hello
Hello world!
```

The `gcc` invocation creates an executable file `hello`, which we can then run with `./hello`.

If you're curious, you can also ask the compiler to create a human-readable assembly
file from your program (instead of the executable `hello` containing machine code). Don't worry
if you don't exactly understand what you're seeing!

```shell
$ gcc hello.c -S
$ cat hello.s
	.file	"hello.c"
	.text
	.section	.rodata
.LC0:
	.string	"Hello world!"
	.text
	.globl	main
	.type	main, @function
main:
.LFB0:
	.cfi_startproc
	endbr64
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	movq	%rsp, %rbp
```

If you're working on your computer, there is a good chance that you're compiling onto the x86
architecture, so the output you see here is x86 assembly code.

You can use the website [Godbolt](https://godbolt.org/) to see the assembly output of
different compilers, targeting different architectures. As an example, you can select the compiler
`RISC-V rv32gc gcc 10.2.0` on the site to see RISC-V assembly code as your output. This is a handy
tool for quick tests, but of course for larger projects you should stick with a local compiler setup.

## Dissecting `hello world`

Let's go back to the example code:

```c
#include <stdio.h>

int main(void) {
    printf("Hello world!\n");
    return 0;
}
```

The first line tells the compiler to include parts of the C standard library, this
enables us to use predefined functions, such as the `printf` we use to print to the
console. This `#include` directive is similar to `import` in Python or Java.
In this case, we include the `stdio.h` *header*, this includes functions related to
input/output (STanDard I/O).

We use the `printf` function from `stdio.h` to print the text "Hello world" followed
by a line break. Later in this session, we will see how to print variable values
as part of our string.

C programs always have to contain a `main` function. This is where the execution will
start from when we run our program. The signature `int main(void)` tells us that the
main function returns an integer value and does not take any parameters (`void`).
The return value of the `main` function usually signals whether the execution
was successful. `0` means success, while other values are interpreted as error codes.

---

## Integers in C and assembly

Integers, basic arithmetic

Side-by-side examples of C and RISC-V (just `c = a + b` or something).

Operating on registers, fast on-chip, later. Memroy too slow (cache inbetween).

## User input handling in C

scanf/printf

format strings to include variables.

scanf with ampersand (later).

### Exercise 1

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

# Registers in RISC-V

In the previous example, we've already seen registers being used, here is their list in RISC-V, along with register sizes and stuff.

different extensions: rv32i x0-x31
names and descriptions
conventions
interplay of software with register usage

## Breakdown of assembly instructions

Operation, destination, sources.

12 bits as immediate

[ go back to the previous example here ]

pseudo-instructions

## Pointers in C

Are C variables always stored in registers? What if we have too many? Storing them in memory. How can we see where they are stored?

virtual address, every byte has separate addresses

Pointers

go back to scanf

example with separate colors

use of star: *j is always an int

compiler warnings maybe?

Interactive example

## Memory segments in assembly

So can we store variables in memory from assembly?

Memory segments, example with a `word`.

data: space in ram, with initial value (loader will do this)

labels, globl main, rars starts there (otherwise line 1)

load address, load word

an exercise here?

## Other data types

Basic ones, char, float, double

comparison with register sizes

Size of data types: godbolt

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

start from main

recursive functions

# Static arrays

First example in C, with loop

Contiguous memory region of those values. Variable stores the first element's adres.

Amount of elements with sizeof

Index notation

Also strings: array of characters, terminating null byte: inconvenient to keep track of sizes
Example with puts?

use pointer to first character for string

string literals

# Arrays in assembly

### Exercise 5 from session 1 (although this is pretty boring)

### Exercise 6 from session 1

## Branches in assembly

### Exercise 2 from session 2 (also not fun)

### Exercise 5 from session 2

### Exercise 6 from session 2

### Exercise 7 from session 2

Before next: explain sizeof array

### Exercise 2 from session 1

# Structs

collection of different data types, with identifiers

padding

point operator
arrow ooperator

### Exercise 4 from session 1
