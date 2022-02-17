---
layout: default
title: "Session 1: C & assembly basics"
nav_order: 1
nav_exclude: false
has_children: false
has_toc: false
---

## Table of contents
{: .no_toc .text-delta }

1. TOC
{:toc .toc_levels 1..2}

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
This first session is more theoretical and might be a bit overwhelming, but understanding
the concepts covered now will be very important for the later sessions. You can
also come back here later to refresh your knowledge when these concepts come up in later sessions.

If you have any questions, ask your
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

> Warm-up 1: Make sure that this works on your computer!

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

> Warm-up 2: Check the RISC-V assembly code on Godbolt for the `hello world` program!

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

## Integers in C and assembly

You can use integer variables and basic arithmetic operations in C like in many other languages.

```c
int a = 4;
int b = 5;
int c = (a + 3) * b;
```

Every variable (`a`, `b`, `c`) in C is stored at a given memory location. By performing operations on
these variables (such as addition or multiplication), we basically perform these operations at the values stored
at the corresponding memory locations.

> Tip for later: you can access the memory address of a variable by adding `&` in front of the variable name. For example, in the above example, `a` refers to the value `4`, but `&a` refers to the memory address where that `4` value is stored.

In contrast, in RISC-V we can only perform arithmetic on values stored in registers:

```armasm
addi t0, zero, 4  # t0 = 4
addi t1, zero, 5  # t1 = 5
addi t2, t0, 3    # t2 = t0 + 3
mul  t2, t2, t1   # t2 = t2 * t1
```

> Warm-up 3: Try out this example in [RARS](#)! Check whether you see the correct value in `t2` after executing the program.

## User input handling in C

Programs that do not deal with any inputs and do not print any results are pretty useless.
We have already seen how to use `printf` to write a *string literal* to the console. We can also print out
the values of variables using `printf`. In the other direction, we can use the function `scanf` to read user
input into variables.

`printf` and `scanf` are functions that can take an arbitrary number of arguments. The first argument of
these functions is called the *format string*. This specifies the format (the "shape") of the string we
want to print out or read in. We can include *format specifiers* in this string, these are placeholders for
the variables we want to include in the string.

If for example we want to print out the value of an `int age;` variable as part of our string, we would include the
`%d` (decimal) format specifier in the format string as a placeholder for the value of the variable: `"I am %d years old."`.

For different types of variables, we need to use different format specifiers; `%c` for characters, `%u` for unsigned integers, etc. After the format string, we include the variables as arguments to the `printf` functions in the order of
the format specifiers.

```c
int age = 21;
int ects = 36;

printf("I am %d years old and I have %d ECTS this semester. Phew!\n", age, ects);
```

With `scanf`, there are two things you need to watch out for. First, you need to pass the *memory location*
where you want the input to be written. In practice, this often means taking the memory address of a given
variable:

```c
int input;
printf("Enter your favorite number: ");
scanf("%d", &input);
```

Second, notice how we printed the prompt to the user using `printf`, not as part of the
`scanf` format string. Remember, the `scanf` format string describes the shape of the string
the user has to enter! In this case, we want the user to simply enter `5`, or another decimal number,
so the format specifier `%d` is all we have in the format string.

If we want the user to enter their favorite time in the day, we could have a prompt like
`scanf("%d:%d", &hour, &minute);`. In this case, if the user enters a string like `13:37`, the number
13 will be saved to the `hour` variable, 37 will be saved to `minute`, and the `:` in the middle will
be ignored.

In general, if the user's input does not respect the format specified in `scanf`, strange values
can appear in your program.

### Exercise 1

Write a C program that asks the user for an integer value and prints out the square
of this value, together with the original number.

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

As mentioned previously, RISC-V instructions perform operations on values stored inside registers,
which are located inside the CPU. RISC-V is actually a collection of ISAs, it has different variants
and extensions for different purposes. You can find the descriptions of all base ISA variants and the
extensions in the [RISC-V specification](https://riscv.org/wp-content/uploads/2017/05/riscv-spec-v2.2.pdf).

In CASS, we will use the RV32I (32-bit integer) instruction set. This specifies a total of 32 32-bit
registers and 47 instructions. The instructions are also encoded as 32-bit words.

> You might have heard about computers switching from 32-bit instruction sets to 64-bit ones. One important
> reason for this change is that memory is usually addressed by a value stored in a register. In other
> words, the size of one register limits the size of addressable memory. 32-bit registers can only store
> numbers up to 2^32, which means that you can only address about 4 GB of memory, which is increasingly
> not sufficient today.

All registers `x0-x31` are given a standard name that refers to their conventional usage
(you can use these names when writing RISC-V assembly). These can be found
[here](https://github.com/riscv-non-isa/riscv-asm-manual/blob/master/riscv-asm.md#general-registers)
in full. For example, the first register, `x0` is referred to as `zero`, because reading from it
always returns `0` and writes to it are ignored.

Number | Name | Role
:-----:|:----:|-----
x0 | zero | Always returns 0
x2 | sp | Stack pointer
x5 | t0 | Temporary register 0
... | ... | ...

The other 31 registers could be used for any purpose in theory, but in practice they all have assigned
roles. What does this mean? If all the software on the computer is written by you, you can choose to
use the registers as you please, as you have complete control over the instructions that are executing.

In most cases however, the programs you write will have to cooperate with other software:
you will want to use the operating system to write to the console or into files, and you will
want to call functions defined in libraries (e.g., `printf`). This means that your programs will have
to use the registers in a way that's in line with the expectations of other software. This is very
important for example when passing arguments to a library function, or saving the return value of
that same function call. You also don't want those function calls to overwrite important data that
you store in registers at the time of calling.

The rules for the register usage are called `calling conventions`, and we will deal with them in more
detail in later sessions.

## Breakdown of assembly instructions

We have already seen an example of RISC-V assembly:

```armasm
addi t2, t0, 3    # t2 = t0 + 3
mul  t2, t2, t1   # t2 = t2 * t1
```

We can already learn something from these instructions:
1. The instruction always starts with the desired operation (`addi`, `mul`).
2. If there is a destination register (where the result is written), it is the first parameter of the instruction.
3. The subsequent parameters are used for the operation, and they can be either other registers (`t2`, `t1`) or immediate values (`3`). The `i` at the end of `addi` also refers to this immediate value (adding two register values would use the `add` instruction).

There are four different types of instructions, these two are I-type (immediate) and R-type (register), respectively.
Later in the course we will also see the other two types used for jump and branch instructions.

When working with RARS, you might notice that after compiling your code, certain instructions
are assembled into two consecutive machine code instructions, or your instruction is switched out
for another. This happens when you use `pseudo-instructions`. These instructions are part of the ISA,
but they do not have a machine code representation. Instead, they are implemented using other instructions,
which are automatically substituted by the assembler.

One example is the `mv t0, t1` instruction (copy `t1` into `t0`), which is implemented using the
`addi t0, t1, 0` instruction (adding `0` to the value in `t1` and writing it to `t0`).
You can also see how the `lw` (load word) instruction is translated to two separate instructions in
the [RARS tutorial](#).

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
