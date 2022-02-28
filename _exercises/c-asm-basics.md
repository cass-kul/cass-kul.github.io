---
layout: default
title: "Session 1: C & assembly basics"
nav_order: 1
nav_exclude: false
search_exclude: false
has_children: false
has_toc: false
---

## Table of contents
{: .no_toc .text-delta }

1. TOC
{:toc}

# Introduction

In the CASS exercise sessions, you will learn how programs are executed on computers.
We will explain high-level concepts in the C programming language,
then show how these concepts are translated to assembly code by the compiler.
You will also learn how the CPU executes the (generated) machine code, and
which hardware features are used to make this code more performant.

The following table shows which layers of the hardware-software stack
of computers is covered by CASS and by other courses. CASS covers a broader
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
also come back here to refresh your knowledge when these concepts come up in later sessions.

If you have any questions or anything is unclear, ask your
teaching assistant or reach out to us on the Toledo forums!

# Architecture basics

Modern computers are made up of several hardware components. Most of these follow the so-called
*von Neummann* architecture. This means that the random access memory (RAM) contains both
program code and the data this program calculates on. (This is in contrast to Harvard
architectures, where the instructions and data are stored in separate memory modules).

The computer's operation is sometimes called the `fetch`, `decode`, `execute` cycle.
Instructions are fetched from RAM, decoded by the control unit, then executed in the
arithmetic and logic unit (ALU). Finally, the result of the computation might be written back
to RAM.

<center>
<img src="/exercises/img/fetch-decode-execute.png" alt="Fetch-decode-execute cycle" />
</center>

These designs are called *stored-program computers*, highlighting that the code that is
executed is stored in memory. These instructions are stored in **machine code** format, which
is often directly compiled from a high-level program by a compiler.

The computations are usually performed on values stored in **registers**. These allow a small number of
values to be stored inside the CPU. Accessing registers
is much quicker than accessing the RAM, so registers enable faster computations
than if the values were fetched directly from RAM. In fact, in later sessions we will see how caches are used
to speed up accesses to values that are not stored in registers and have to be fetched from
RAM. The following diagram shows this memory hierarchy; access times increase [dramatically](https://i.imgur.com/k0t1e.png) when moving towards the right.

<center>
<img src="/exercises/img/memory.png" alt="The memory hierarchy" />
</center>

**Machine code** refers to the binary format of instructions that the CPU can execute. These are usually
simple instructions, such as adding or subtracting register values, or loading and storing memory values.
The (human readable) assembly language representation of these instructions is called the **mnemonic form**.
An **assembler** program can compile the mnemonic programs into machine code. You will see this in the
[RARS](/tutorials/rars) environment.

- Machine code: `00000000010100000000001010010011`
- Mnemonic form: `addi t0, zero, 5`

## Instruction set architectures (ISAs)

How do we know which instructions we (or the compiler) can use when writing assembly/machine code?
Different processors can execute different instructions. The list of instructions a given CPU can
execute is defined in the instruction set architecture (ISA). This specification includes the list of
possible instructions (and their behavior), but also the list of registers or other hardware features that must be supported
to be able to execute these instructions.

The most popular ISA today is x86, which is implemented by almost all Intel and AMD processors. x86 is called a
CISC (*complex* instruction set computer) ISA, its specification has evolved over many years and currently includes
thousands of instructions, some of which are very specialized to increase performance (e.g., dedicated
instructions for performing AES encryption).

In this course, we will focus on a RISC (*reduced* instruction set computer) ISA, namely **RISC-V**. RISC ISAs
contain a lot fewer instructions and are easier to write by hand and understand. This does not necessarily mean
worse performance however! Apple's M1 processor also uses a RISC ISA (ARMv8) and outperforms many other
commercial CPUs.

RISC-V is an open standard, both the [specification](https://riscv.org/wp-content/uploads/2017/05/riscv-spec-v2.2.pdf) of the ISA and many of the development tools and
reusable components are open-source, which makes using the ISA, experimenting with it, and extending
it easier. These days it is being increasingly used not only in academia, but also in industry.

# The C programming language

In CASS, we will use the C programming language to showcase programming concepts which we then translate to
RISC-V assembly. We chose this language because it's widely used in systems programming, its procedural
style is not so different from assembly as some other languages (such as object-oriented languages),
and it's easy to examine the compiled assembly code using built-in tools of the operating system.

## C and other languages

Many features in modern programming languages were inspired by C, so you will find plenty of similarities with
modern languages when writing C, hopefully making the transition easier.
Some of these include how you declare and use variables, writing loops and
conditional statements, or working with functions.

In other aspects, C has a closer connection to the underlying operating system concepts. The programmer needs
to manage dynamic memory manually; for variable length objects (such as lists containing an arbitrary number of elements)
the programmer has to manually request memory chunks from the operating system and return them once they are
no longer needed. Many features in C also require explicitly working with the memory address
of certain variables, not only their values.

## Compiling C

Let's test your [C compiler setup](/tutorials/compiling-c) with a simple `hello world` example.

```c
#include <stdio.h>

int main(void) {
    printf("Hello world!\n");
    return 0;
}
```

If you save this program into a file `hello.c`, you can compile and run your program with the
following commands:

```shell
$ gcc hello.c -o hello
$ ./hello
Hello world!
```

The `gcc` invocation on the first line creates an executable file `hello`, which we can then run with `./hello`.

> :fire: Warm-up: Make sure that this works on your computer!

If you're curious, you can also ask the compiler with the `-S` flag to create a human-readable assembly
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

If you're working on your computer, there is a good chance that you're compiling for the x86
architecture, so the output you see here is x86 assembly code (not RISC-V).

You can use the website [Godbolt](https://godbolt.org/) to see the assembly output of
different compilers, targeting different architectures. As an example, you can select the compiler
`RISC-V rv32gc gcc 10.2.0` on the site to see RISC-V assembly code as your output. This is a handy
tool for quick experiments, but of course for larger projects you should stick with a local compiler setup.

> :fire: Warm-up: Check the RISC-V assembly code on Godbolt for the `hello world` program!

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
In this case, we include the `stdio.h` *header*, which includes functions related to
input/output (**st**an**d**ard **i/o**).

We use the `printf` function from `stdio.h` to print the text "Hello world" followed
by a line break (`\n`). Later in this session, we will see how to print values of variables
as part of our string.

C programs always have to contain a `main` function. This is where the execution will
start from when we run our program. The signature `int main(void)` tells us that the
main function returns an integer value and does not take any parameters (`void`).
The return value of the `main` function usually signals whether the execution
was successful. `0` means success, while other values may be interpreted as error codes.

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

> :crystal_ball: A look [forward](#pointers-in-c): You can access the memory address of a variable by adding `&` in front of the variable name. For example, in the program above, `a` refers to the value `4`, but `&a` refers to the memory address where that `4` value is actually stored.

In contrast, in RISC-V assembly we can only perform arithmetic operations on values stored in registers:

```armasm
addi t0, zero, 4      # t0 = 4
addi t1, zero, 5      # t1 = 5
addi t2, t0, 3        # t2 = t0 + 3
mul  t2, t2, t1       # t2 = t2 * t1
```

> :pencil: Hashmarks `#` represent line comments in RISC-V assembly, while in C we can use `//` for the same purpose.

> :fire: Warm-up: Try out this example in [RARS](/tutorials/rars)! Check whether you see the correct value in `t2` after executing the program.

## Handling user input in C

Programs that do not deal with any inputs and do not print any results are pretty useless.
We have already seen how to use `printf` to write a *string literal* to the console. It's also possible to print out
the values of variables using `printf`. In the other direction, we can use the function `scanf` to read user
input into variables.

`printf` and `scanf` are functions that can take an arbitrary number of arguments. The first argument of
these functions is called the *format string*. This specifies the format (the "shape") of the string we
want to print out or read in. We can include *format specifiers* in this string, these are placeholders for
the variables we want to include in the string.

If for example we want to print out the value of an `int age` variable as part of our string, we would include the
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

{% if site.solutions.show_session_1 %}
#### Solution
```c
{% include_relative c-asm-basics/sol1.c %}
```
{% endif %}

# Registers in RISC-V

RISC-V is actually a collection of ISAs, it has different variants
and extensions for different purposes. You can find the descriptions of all base ISA variants and the
extensions in the [RISC-V specification](https://riscv.org/wp-content/uploads/2017/05/riscv-spec-v2.2.pdf).

In CASS, we will use the RV32I (32-bit integer) instruction set. This specifies a total of 32 32-bit
registers and 47 instructions. The instructions are also encoded as 32-bit words.

> :pencil: You might have heard about computers switching from 32-bit instruction sets to 64-bit ones. One important
> reason for this change is that RAM is usually addressed by a value stored in a register. In other
> words, the size of one register limits the size of addressable memory. 32-bit registers can only store
> numbers up to 2^32, which means that you can only address about 4 GB of memory, which is increasingly
> insufficient today.

As mentioned previously, RISC-V instructions perform operations on values stored in registers,
which are located inside the CPU.
All registers `x0-x31` are given a standard name that refers to their conventional usage
(you can use these names when writing RISC-V assembly in RARS). These can be found
[here](https://github.com/riscv-non-isa/riscv-asm-manual/blob/master/riscv-asm.md#general-registers)
in full. You can also find the short description and names of all registers on the [RISC-V card](/files/riscv-card.pdf).
For example, the first register, `x0`, is referred to as `zero` because reading from it
always returns `0` and writes to it are ignored.

Number | Name | Role
:-----:|:----:|-----
x0 | zero | Always returns 0
x2 | sp | Stack pointer
x5 | t0 | Temporary register 0
... | ... | ...

In theory, the other 31 registers (other than `zero`) could be used for any purpose, but in practice they all have assigned
roles. What does this mean? If all the software on the computer is written by you, you can choose to
use the registers as you please (e.g., storing your first variable in `x1`, the second in `x2`, ...),
as you have complete control over the instructions that are executing.

In most cases, however, the programs you write will have to cooperate with other software:
you will want to use the operating system to write to the console or into files, and you will
want to call functions defined in libraries (e.g., `printf`). This means that your programs will have
to use the registers in a way that's in line with the expectations of other software. This is very
important, for example, when passing arguments to a library function or saving the return value of
that same function call. You also don't want those function calls to overwrite important data that
you store in registers at the time of calling.

The rules for register usage are called *calling conventions*, and we will deal with them in more
detail in later sessions.

## Breakdown of assembly instructions

We have already seen an example of RISC-V assembly:

```armasm
addi t2, t0, 3        # t2 = t0 + 3
mul  t2, t2, t1       # t2 = t2 * t1
```

We can already deduct some things from these instructions:
1. Instructions always start with the desired operation (`addi`, `mul`) called the **mnemonic**, followed by its **operands**.
2. If there is a destination register (where the result of the operation is written), it is the first parameter of the instruction.
3. The subsequent parameters are used for the operation, and they can be either other registers (`t2`, `t1`) or immediate values (`3`). The `i` at the end of `addi` also refers to this immediate value (adding two register values would use the `add` instruction).

There are four different types of instructions, the two above are called *I-type* (immediate) and *R-type* (register) instructions, respectively.
Later in the course we will see the other two types used for jump and branch instructions.

### Pseudo-instructions

When working with RARS, you might notice that after assembling your code, certain instructions
are assembled into two consecutive machine code instructions, or your instruction is switched out
for another one. This happens when you use *pseudo-instructions*. These instructions are part of the ISA,
but they do not have a machine code representation. Instead, they are implemented using other instructions,
which are automatically substituted by the assembler.

One example is the `mv t0, t1` instruction (copy `t1` into `t0`), which is implemented using the
`addi t0, t1, 0` instruction (adding `0` to the value in `t1` and writing it to `t0`).
You can also see how the `lw` (load word) instruction is translated to two separate instructions at the end of
the [RARS tutorial](/tutorials/rars).

# Pointers in C

As mentioned [before](#integers-in-c-and-assembly), variables in C are stored in memory locations.
Of course, now we see that to perform operations on these values, first they need to be loaded into
registers (usually using the `lw` instruction).

You can use the `&` operator to get the memory address of a given variable. Notice that we have already
used this syntax in `scanf`, where we needed to specify *where in memory* the user input should be written.
Later, we will see other examples where the memory addresses play an important role in how C works.

Given the importance of addresses, C allows us to store them in special variables called **pointers**
(*pointing* to a memory location). These variables have an asterisk in their type to indicate that they
are pointing towards a value with that given type:

```c
int a = 5;    // a regular integer, stored somewhere in memory, `a` stores the value 5
int *p = &a;  // a pointer to an integer value, `p` stores the memory location of `a`
```

We can visualize the memory layout the following way (ignore `x` for now):

<center>
<img src="/exercises/img/pointers.png" alt="Pointer example" />
</center>

In the picture, each cell represents a location in memory, the addresses of these locations are
displayed in gray in the top right corner. When we create a variable in C (identifier in blue, bottom left),
it will get assigned to one of these locations. The contents of the memory location are displayed in the middle.

Integer values are displayed in green, while pointers are in shades of red. Pointing to a memory location (visualized
as an arrow) simply means storing the address of that cell.

We can print out the value of a pointer using the `%p` format specifier:

```c
printf("The address of `a`: %p, its value: %d\n", p, *p);
// The address of `a`: 0x0101, its value: 5
```

Notice how we got the value of the pointed memory location by using `*p`.
So while writing `p` gives us the address of `a`, writing `*p` gives us the
value *at the pointed address*. Writing the asterisk is the equivalent of following
an arrow in the picture above to arrive at the pointed value.
We can also use this to change the value at that address:

```c
int a = 5;
int *p = &a;
*p = 6;
printf("a = %d\n", a);
// a = 6
```

Pointers will allow us to change the values of variables that we do not have direct access to.
We will see examples of this later.

As you can see, `p` is also a variable, it also has an address:
`p` needs to store its value (the address of `a`) somewhere
in memory, so it necessarily has its own address, which you can get with `&p`.

So what type of variable do you need to use if you want to store *the address* of `p` (in variable `x` in the example above)?
<details>
  <summary>Solution</summary>
<code class="language-plaintext highlighter-rouge">int **x = &p;</code>
<p>If you see a variable with a pointer type, and you want to find out what type of value it points to,
a handy trick is to cover the asterisk closest to the name. This will give you the type of the variable the pointer
points to. For example, with <code class="language-plaintext highlighter-rouge">int *p = &a;</code>, by covering the asterisk,
we see that it points to an integer variable (<code class="language-plaintext highlighter-rouge">a</code>). With <code class="language-plaintext highlighter-rouge">int **x = &p;</code>,
when we cover the last asterisk, we still have <code class="language-plaintext highlighter-rouge">int *</code>
remaining, so we know x points to an integer pointer (<code class="language-plaintext highlighter-rouge">p</code>)!</p>
</details>


# Memory segments in assembly

So far, we have only used registers to store values in assembly. But in many cases, we want to store
values in memory (e.g., if we have more variables than the number of available registers). This is of
course also possible in assembly.

A program is made up of multiple **memory segments**. The C compiler manages this for us transparently,
but when writing assembly, we need to note these explicitly. If you go back to the [first assembly example](#compiling-c)
we've seen, you'll see the string `"Hello world"` is stored in `.section .rodata`.

## The `.text` section

In RISC-V assembly, we will make use of two segments. The program code (the instructions) are
stored in the `.text` section. If you only write instructions in RARS, it will automatically put
them in this section, this is why the warm-up program worked as it did. But it's good practice to always define it:

```armasm
.text
main:
    addi t2, t0, 3
    mul  t2, t2, t1
```

Notice that we've also added `main:` to our program. This is called a **label**, and it can be used to
point to a certain instruction or data in memory. In the x86 example above, you can also find a `main:` label,
but also `.LC0:`, which points to the string literal.

`main:` is a special label, RARS will start execution from here if it can find it. This is useful if you have
a longer file, and you don't necessarily want RARS to start executing from the first line. (This will be useful
for example when you will define multiple functions in the same file).

To enable external programs to also use these labels, you can use the `.globl` directive. For example,
writing `.globl main` will allow other programs to start executing your program from the `main:` label.
We will always add this directive when working in RARS.

```armasm
.globl main
.text
main:
    addi t2, t0, 3
```

## The `.data` section

We can store variables in the `.data` section. These will work very similar to C variables, but there is
a weaker notion of data types in assembly. For integers, we will usually reserve a word (32 bits) of memory,
which corresponds to the size of `int` in C in most cases (an `int` in C does not have a concretely defined
size in the specification).

We also use a label (`a:`) to give a name to our word in memory, otherwise it would be difficult to
refer back to it.

```armasm
.data
    a: .word 5
.text
    la t0, a
    lw t1, (t0)
    addi t1, t1, 3
    sw t1, (t0)
```

When reserving a `word`, we can also give it an initial value in memory. In the above example,
we chose to give our variable `a` the initial value 5. In our program, we first load the address
of `a` into `t0` (`la`), then load the word at this address (now contained in `t0`)
into `t1`. After increasing this value by 3, we write it back to the original memory location.

If you want to reserve space in the data section with a byte granularity (not full words),
you can use the `.space N` directive, where `N` is the number of bytes you want to reserve.
For example, you can reserve 4 bytes of space with `empty: .space 4`. In this case,
you can't provide initial values for the memory, you need to store a value in it
from your program.

### Exercise 2

Write a RISC-V program that calculates the following: `c = a^2 + b^2`.
Use the data section to reserve memory for `a`, `b`, and `c`.
Use the debugging features in RARS (memory viewer, register contents) to make sure
that your program works as intended!

{% if site.solutions.show_session_1 %}
#### Solution
```armasm
{% include_relative c-asm-basics/sol2.S %}
```
{% endif %}

# Other data types

So far, we've only seen integers in C. Already with integers, you can come across many
variants in C:

- `int`: signed integer, at least 16 bits in size
- `unsigned int`: unsigned integer (non-negative values)
- `long`: signed integer, at least 32 bits
- `unsigned long`, `long long`, `unsigned long long`...

For floating point numbers, you can use `float` and `double` (where the latter has double the precision).

Characters can be stored in the `char` type. This is 1 byte in size, so it stores the character in the [ASCII](asciitable.com/)
encoding.

In your C programs, you can find the precise size of a data type or a variable (in bytes) with the `sizeof()` function:
`sizeof(int)` or `sizeof(a)`.

### Exercise 3

Write a C program that asks the user for an integer. Print the address, the value
and the size in bytes of this integer. Now store the address of this integer in a pointer.
Then print the address, the value and the size in bytes of this pointer.

> In the [picture](#pointers-in-c) demonstrating pointers, we have made some simplifications
> regarding the sizes of variables. Can you see what wasn't realistic in that example?

{% if site.solutions.show_session_1 %}
#### Solution

In the picture, integers and pointers are stored as a single byte (the memory cells
have addresses that increase by 1), whereas according to the [standard](#other-data-types)
they should be at least 2 bytes long. This program will tell you exactly how many
bytes these types use on your computer.

```c
{% include_relative c-asm-basics/sol3.c %}
```
{% endif %}

### Exercise 4

Write a C program that asks the user for a positive integer and iteratively computes the
factorial of this integer.

> Hint: loops work the same way in C as they do in many other languages.

{% if site.solutions.show_session_1 %}
#### Solution
```c
{% include_relative c-asm-basics/sol4.c %}
```
{% endif %}

# Branches

In C, you can create conditional branches and loops like in other languages:

```c
if (a != b) {
    a = b;
} else {
    calculate(a);
}
```

```c
while (a <= b) {
    a++;
}
```

In assembly, constructing these control structures is a bit more tricky. We will
once again need to make use of the labels that were previously introduced.
In the branch and jump instructions we include these labels as jump targets.

```armasm
loop:
    addi t0, t0, 1
    j loop
```

The above is a simple example of an infinite loop; `j loop` will always jump back
to the instruction following the `loop:` label, so the `t0` register will be incremented
until the heat death of the universe.

This is of course not very useful, so there are many instructions that perform
conditional branching.

```armasm
    mv t0, zero
    addi t1, zero, 5
loop:
    addi t0, t0, 1
    bne t0, t1, loop
    mul t2, t0, t1
```

In this example, we used the `bne` instruction, which only jumps to the `loop:` label
if the two register operands are not equal. Otherwise, the program continues executing
at the next instruction (`mul`). You can find other useful branching instructions on the
[RISC-V card](/files/riscv-card.pdf).

### Exercise 5

Translate the program from exercise 4 to RISC-V. You don't have to ask for user input,
store the input integer in the data section.

{% if site.solutions.show_session_1 %}
#### Solution
```armasm
{% include_relative c-asm-basics/sol5.S %}
```
{% endif %}

### Exercise 6

Write a RISC-V program that calculates: `c = a^b`.
Make sure that your solution works for all `b >= 0`!

{% if site.solutions.show_session_1 %}
#### Solution
```armasm
{% include_relative c-asm-basics/sol6.S %}
```
{% endif %}
