---
layout: default
title: "Session 3: Functions and the stack"
nav_order: 3
nav_exclude: false
search_exclude: false
has_children: false
has_toc: false
gallery_images:
    - stack-album/convention-example-11.png
    - stack-album/convention-example-12.png
    - stack-album/convention-example-13.png
    - stack-album/convention-example-14.png
    - stack-album/convention-example-15.png
    - stack-album/convention-example-16.png
    - stack-album/convention-example-17.png
    - stack-album/convention-example-18.png
    - stack-album/convention-example-19.png
    - stack-album/convention-example-20.png
    - stack-album/convention-example-21.png
    - stack-album/convention-example-22.png
    - stack-album/convention-example-23.png
---

## Table of contents
{: .no_toc .text-delta }

1. TOC
{:toc}

# Introduction

In the last sessions you have already gained first experience with assembly code in RISC-V and by now also have a basic understanding of C code.
In this session, we will dive deeper into what difficulties arise when writing larger programs, how we can extend our registers by using memory, and how this helps us to also write code elements that resemble functions as you know them from higher-level languages.

## Recap: Functions in C

Let's first take a look at functions in C. Below you see an example program with a helper function that calculates a simple sum.

<table>
<tr>
<th>sum.c</th>
<th>Console</th>
</tr>
<tr>
<td>
{% highlight c %}
// Include I/O library functions (printf, scanf)
# include <stdio.h>

// This function allows us to calculate the sum of two numbers.
// With this, we can reuse the sum calculation at different
// locations of our code as an abstract operation.
int sum(int a, int b) {
    return a + b;
}

// Main function where the program starts
int main(void) {
    int n;
    printf("Enter a number:\n");
    scanf("%d", &n);
    printf("Result: n+2=%d\n", sum(n, 2));
    return 0;
}
{% endhighlight %}
</td>
<td>
{% highlight bash %}
$ gcc sum.c -o sum
$ ./sum
Enter a number:
5
Result: n+2=7
{% endhighlight %}
</td>
</tr>
</table>

You already know functions from other languages than C, they are very useful to bundle common tasks or make the program simpler to think about. In essence, functions allow for **abstraction** via *parameters* and *return values*.

But how can we do this in assembly? There is almost no concept of a *function* in assembly. If languages like C are compiled to assembly code, how do they transform their functions to assembly code then?
The answer is simple and slightly difficult at the same time:

1. Functions can be implemented using **common low-level primitives** such as **labels**, **jumps**, and **registers**. Doing this is simple, and you may already have done so intuitively during the last sessions.
1. *However*, making sure that you can **always** and **deterministically** reuse or call a function requires some effort. You may already have experienced that different developers use different registers to do the same thing. What if you use register `t0` to pass a parameter to a function, but the other developer expects the parameter in `t1`? What happens if we run out of registers? These and other situations require for a clear set of (**calling**) **conventions** that we expect everyone to adhere to - even (or especially) compilers! This is the slightly difficult part of functions in assembly.

# First steps towards common calling conventions

> :bulb: TL;DR: The official *calling conventions* are [here on the official RISC-V website](https://riscv.org/wp-content/uploads/2015/01/riscv-calling.pdf). You can also find the short version on the [RISC-V card](/files/riscv-card.pdf) that you will have access to in the exam.

If the above explanation did not fully click for you yet, don't worry. Let's go step by step and understand why conventions are useful and help us write code that can be used across programs and teams.
Let's take a look at the partial assembly code below. We already created a `main` and a `sum` label:

```armasm
.globl main
.data
    a: .word 1
    b: .word 2
    number: .word 0

.text
main:
    # Load the two numbers a and b into registers

sum:
    # Add the two numbers and put them in a register for main to find.

resume:
    la t0, number
    sw a0, 0(t0)
```

> :fire: Warm-up 1: Extend the program above to sum the two numbers `a` and `b` and store it in `number`.

![Problems that arise when using functions in assembly code](calling-conventions-problem.png "Problems that arise when using functions in assembly code")

Which registers did you use in the main to load `a` and `b`? What would
happen to your program if the code in `sum` used different registers? It
would no longer work. This is why [the calling conventions of
RISC-V](https://riscv.org/wp-content/uploads/2015/01/riscv-calling.pdf) assign
different roles for different registers:
- Some registers are to be used for *input parameters* and *return values* of functions
- **Callee-saved** registers are to be *restored* by the called function at the end of its execution (if it had changed their values). In other words, the code that called the function can safely treat these registers as if their value was unchanged by the function call.
- **Caller-saved** registers can be *overwritten* by the called function. In other words, the code that called the function should assume that these registers will be overwritten by the called function (and should be saved elsewhere if they are needed).

Register number             | Register name | Use                   | Note
--------:------             | ------:------ | :------------         | :-------------
`x0`                        | `zero`        | Always zero           | -
`x1 - x4`                   | `ra,sp, gp, tp`| Various uses         | Partially explained below
`x5 - x7` and `x28-x31`     | `t0 - t6`     | Temporary registers   | **Caller** must save these registers before calling a function it they need them later. Functions may at any time overwrite these registers!
`x8 - x9` and `x18 - x27`   | `s0 - s11`    | Saved registers       | **Callee** must save these registers. Thus, you can safely use these registers in your code and any function that you call **must** back them up and restore them if they decide to use them too.
`x10 - x17`                 | `a0 - a7`     | Function arguments    | Function arguments to called functions. Used as input parameters.
`x10` and `x11`             | `a0` and `a1` | Return values         | Since the input to a function is not useful anymore on return, `a0` and `a1` have a dual use as registers for the return values.

```armasm
addi s0, zero, 5
addi t0, zero, 5
jal fact         # function call!
add s1, t0, t0   # we don't know what is in t0, because it's caller-save!
add s1, s0, s0   # s0 is guaranteed to still contain 5, because it's callee-save!
```

If you take a look at the [RISC-V card linked at the top of the website](/files/riscv-card.pdf), you can now understand the register table.

![Calling conventions solve interface issues](calling-conventions-solution.png "Calling conventions solve interface issues")

> :fire:  Warm-up 2: Change your program to adhere to these register conventions as if the `sum` label was a function.

> :fire:  Warm-up 3: Read the [official calling conventions of RISC-V](https://riscv.org/wp-content/uploads/2015/01/riscv-calling.pdf). Since we will not be making use of floating point registers (`ft0` to `ft11`) you can skip Section 18.3. In this course we will just try to fit all parameters into the argument registers as it is explained there before utilizing the stack.

The official calling conventions talk about passing some function parameters via the stack. Let us now take a look at what happens if we run out of registers and how can we solve this by using the stack.

# Memory: the stack

It is easy to think of cases where the 32 registers we have are not enough. You may already have come to a situation where this is the case, but for any larger program, we definitely need to store data in memory. Similarly, if the calling conventions only define 8 registers to pass function arguments, what happens if we want to pass more data to a function than fits into these 8 registers?
You already worked with variables stored in the `.data` section: in a similar way, we could declare a region in memory that we use to back up or restore data from. However, defining specific variables is still not enough for cases where we do not know how many variables we will need.
In this case, what we need is a data structure where we *dynamically* add and remove data from, depending on what we need.

## Understanding the stack

A stack is a simple data structure that grows in one direction and that works according to the Last-in-First-Out (LIFO) principle. The idea is as simple as a tower of books where you are only ever able to pick up the top-most book. You can place more books on top of the tower, but have to pick them up again to reach the books at the bottom.
To realize a simple stack in assembly, we can just define a large memory region in the data section like this:

```armasm
.data
    stack: .space 500
.text
main:
    # ...
```

Now to use this stack, we would do the following actions:

1. Load the address of the stack into a register
1. When we want to push data on the stack:
    1. Store data at the address that the register points to
    1. Increment the pointer by the size of the data we just added, so that the register points to free space again
1. When we want to pop data from the stack, we:
    1. Decrement the pointer by the size of the last data element
    1. Read the content of the data stored at the current stack pointer

If you are now unsure about what the size of the data is that you want to put or retrieve from the stack, take a look again at the calling conventions or at the RISC-V sheet, both contain a list of common data types and their size in bytes in our 32-bit RISC-V configuration.

> :fire: Warm-up 4: Expand the example above with simple code that loads the address of the stack into a register, pushes two integers (4 and 5 for example) and then pops these integers again.

This simple stack that you have written can already help you to overcome all challenges that we described above:

- If we run out of registers, we can temporarily push the variables onto the stack. As long as we as developers remember where we can find the data and how many variables we pushed after this variable, we can always find it again.
- If we want to send complex data to a function or want to exceed the 8 registers that we can use to send function arguments, we can use such a stack and simply pass the pointer to the data on the stack.
- One additional issue we did not discuss yet is the problem of **program control flow**. Where should the function jump at the end? What happens on recursion? Or if a function wants to call another function? The functions should always remember who called them and where to *return* to. This is handled by the *return address* register (`ra` / `x1`), which also needs to backed up to the stack during nested function calls.

## Manipulating the stack in RISC-V

At this point, it may not surprise you anymore to hear that RISC-V actually has a dedicated register called the **stack pointer**, and that the calling conventions heavily rely on these mechanisms:

- The **stack pointer** (`sp` / `x2`) is already set up for you to point to the CPU stack. You can use it in your programs freely.
- In RISC-V (and other architectures) the stack however grows **downwards**. Thus, instead of increasing the pointer as you did in the warm-up above, you **decrement** it. See the excursion below for more details.
- To **push** data (e.g. `t0`) to the stack: first use `addi sp, sp, −4` (decrement the stack pointer to allocate space on the stack); then use `sw t0, sp` to write `t0` to the stack.
- To **pop** data from the stack (e.g. in `t0`): first load the data at the top
  of the stack using `lw t0, sp`; then update the stack pointer using `addi sp, sp, 4`.

> :fire: Warm-up 5: Change your code from the last warm-up to use the `sp` register and the provided stack.

## Excursion: The stack grows downwards!?

> :warning: The stack controlled by the stack pointer in RISC-V grows **downwards**! It is still a stack, but instead of adding a variable *on top* of the older one, you place the variable **below** the older one in memory. This means that when your last element on the stack is at address `0x100`, the next item of size 4 bytes will be at address `0x100 - 0x004 = 0x0FC` (and **not** at `0x104`).

If you want to understand more about this, read through the excursion below.

<details closed markdown="block">
  <summary>
    Excursion: Why does the stack grow downwards?
  </summary>
  {: .text-gamma .text-blue-000 }

There is no *technical* reason for this, this is just **convention**. You could equally well define that the stack grows upwards in the direction that is probably more intuitive to you. However, this decision may make more sense when looking at the general memory layout that we use for *all* the uses of the memory in RISC-V.

Since RISC-V is based on a Von Neumann architecture, the memory is used to store *both* instructions and data. Take a look at the memory overview below. You will see that in the memory, we need to store (from bottom to top, low address to high):

1. Reserved memory at the very first addresses (bottom in the graphic, but address 0x00
1. Text section, i.e., the instructions that are kept in memory. For programs you write with RARS, this means all instructions you write as RARS simulates a memory layout for you.
1. Data section where all static data is kept
1. Heap data for dynamic memory. You will learn more about this in the next session.
1. Stack

Both the stack and the heap can grow during the execution of programs. Since we may not always know how large both can get during execution, it is simpler to just have them share a big block of memory and let them grow towards each other. Then, we only need to make sure they never cross each other but until that happens, both can grow and shrink however they want.

![Memory Layout in RISC-V](memory-layout.png "Memory Layout in RISC-V")

> :bulb: *Why does the stack grow downwards?* Because it became a convention at some point that the **stack grows downwards** and **the heap grows upwards**. There are some reasons that make it a smart choice, but nowadays it is just a convention in RISC-V.

</details>

# Using the stack for function calls

Calling a function means multiple things at once:

1. We jump to a new address (or label) and expect the code there to execute for a few instructions
1. We may want to provide some input to the called function
1. We may expect some return values from the called function
1. The function is expected to jump back, also called *return*, to the code that originally called it
1. Any registers that are marked as caller-save must be saved before the function call and restored afterwards (if we want to preserve their value)
1. Any registers that are marked as callee-save must remain untouched by the called function

We have already discussed which registers are callee- and caller-saved. However, we did not discuss how these registers should be saved on the stack or in what order we should save them.
The first thing to do when calling a function is to save the caller-saved registers on the stack.
Since this procedure logically belongs to the caller function, it does not matter in which order you save the registers as long as you make sure that you restore them in the same order after returning from the function.

The next step to take when calling a function is to push on the stack the arguments that do not fit into registers.
Before jumping to the function, we fill the `ra` register with the return address: the address of the instruction that we want to execute when returning from the function. Most often, this will be the instruction after the jump to the function. This is why there is a special instruction in RISC-V, called the `jal` (jump and link) instruction, that first places the address of the next instruction into the `ra` register and then jumps to the given address.


# Summary: Complete calling conventions

> The complete list of things to do when calling a function is as follows:
>
> 1. Push caller-saved registers that you need to reuse to the stack (e.g. only save `t0` and `t1` if `t2-7` are unused)
> 1. Push function parameters that do not fit in registers onto the stack
> 1. Place all function parameters that belong into registers in the registers `a0` to `a7`
> 1. Call the function either via `jal` (or via another instruction as long as you make sure to store the return address to `ra`)
>
> In the called function, do the following:
>
> 1. Back up the return address register `ra` as a first thing on the stack (if we're planning to overwrite it either directly or by calling another function with `jal` from within the function)
> 1. Back up other callee-saved registers that will be used by this function (e.g. if we do not touch `s0-s7`, we can skip saving them)
> 1. Perform function tasks
> 1. Place function return in `a0` and `a1`.
> 1. Restore callee-saved registers and `ra`
> 1. Return to parent function via `ret` (or simply jump to `ra`)

With this complete calling conventions list, you should now understand the call stack diagram, which you can also find on the RISC-V card:

![Call stack diagram](call-stack-diagram.png "Call stack diagram")

Below, you can find a series of images that walk you through an example program and the usage of the stack (click or slide through the images).

{% include gallery.html images=page.gallery_images ratio_image="stack-album/convention-ratios.png" %}

<details closed markdown="block">
  <summary>
    Show stack example code
  </summary>
  {: .text-delta .text-blue-000 }

```armasm
{% include_relative functions-stack/stack-example.asm %}
```

</details>

### Exercise 1

Convert the following code to RISC-V assembly using RISC-V calling conventions.
Assume that `main` does not return like common functions.
Why is this assumption necessary right now?

```c
{% include_relative functions-stack/ex1.c %}
```

{% if site.solutions.show_session_3 %}

#### Solution

```armasm
{% include_relative functions-stack/sol1.asm %}
```

{% endif %}

# Additional exercises

### Exercise 2

We have compiled the function `func` from the code example below to 32-bit RISC-V (RV32I) using gcc.
The compiled function can be found below.
Translate the main function manually to RISC-V.
Follow the calling conventions to pass all arguments correctly.

> :bulb: The nice thing about calling conventions is that you don't have to
> understand the assembly code of `func` to be able to write the assembly code
> of `main`!

```c
{% include_relative functions-stack/ex2.c %}
```

```armasm
{% include_relative functions-stack/ex2.asm %}
```

{% if site.solutions.show_session_3 %}

#### Solution

```armasm
{% include_relative functions-stack/sol2.asm %}
```

{% endif %}

### Exercise 3

Fix the function `sum_fixme` in the below program.
Only add code at the designated `TODO` points, don't modify the existing code.
Use the stack to make sure *caller-saved* registers are saved by the *caller* and *callee-saved* registers are saved by the *callee*.
Note that `sum_fixme` acts both as a caller and a callee at different times. Your solution is correct if the execution terminates with

- no errors;
- the value 3 in `a0`;
- the value `0xdeadbeef` in `s0`.

```armasm
{% include_relative functions-stack/ex3.asm %}
```

{% if site.solutions.show_session_3 %}

#### Solution

```armasm
{% include_relative functions-stack/sol3.asm %}
```

{% endif %}

### Exercise 4

Consider the following recursive function which calculates `n!`.

```c
{% include_relative functions-stack/ex4.c %}
```

1. Convert this function to RISC-V.
1. Consider the call `fact(3)`. What is the state of stack when it reaches its maximum size (at the deepest level of recursion)?
1. In [exercise 4 of the first session](/exercises/c-asm-basics/#exercise-4) you implemented an iterative factorial function. Compare both factorial implementations in terms of memory usage. Which implementation do you prefer?

{% if site.solutions.show_session_3 %}

#### Solution

```armasm
{% include_relative functions-stack/sol4.asm %}
```

{% endif %}

# Excursion: Tail recursion

A [*tail call*](https://en.wikipedia.org/wiki/Tail_call) occurs whenever the last instruction of a subroutine (before the return) calls a different subroutine.
Compilers can take advantage of tail calls to reduce memory usage. This is because for tail calls, no additional stack frame needs to be entered. Instead, we can simply overwrite the function parameters, jump to the function and execute from there by reusing the original function stack frame.
This is possible since we do not expect to be returned to and instead refer to our original caller that is on our stack frame. Thus, when the (tail-) called function returns, it will not return to us but directly to the original code that called us.

The benefit of tail calls is that they are very light on stack usage. While non-tail recursion add a stack frame for each recursion depth, tail recursion only use a single stack frame for any recursion depth.

> :bulb: The call `fact(n-1)` in the previous exercise is **not** a tail call. Why not?

<details closed markdown="block">
  <summary>
    Solution
  </summary>
  {: .text-gamma .text-blue-000 }

The multiplication must be performed after the recursive function returns. Thus, the recursive function call is **not** the last instruction in the function.

</details>

### Excursion exercise

We have converted the factorial program to use tail recursion.
Translate this program to RISC-V.
Try to avoid using the call stack during the `fact_tail` implementation. Why is this possible?

```c
{% include_relative functions-stack/ex5.c %}
```

{% if site.solutions.show_session_3 %}

#### Solution

```armasm
{% include_relative functions-stack/sol5.asm %}
```

{% endif %}
