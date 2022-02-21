---
layout: default
title: "Session 3: Functions and the Stack"
nav_order: 3
nav_exclude: false
search_exclude: true
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
// Include convenient library functions
# include <stdio.h>
// Module function for easy reuse
int sum(int a, int b)
{
    return a + b;
}
// Main function where the program starts
int main()
{
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
$ - gcc sum.c -o sum
$ - ./sum
Enter a number:
5
Result: n+2=7
$ -
{% endhighlight %}
</td>
</tr>
</table>

You already know functions from other languages than C, they are very useful to bundle common tasks or make the program simpler to think about. In essence, functions allow for **abstraction** and **modularization** (via *parameters* and *return* values).

But how can we do this in assembly? There is almost no concept of a `function` or `procedure` in assembly. If languages like C are compiled to assembly code, how do they transform their functions to assembly code then?
The answer is simple and slightly difficult at the same time:

1. Functions can be implemented using **common low-level primitives** such as **labels**, **jumps**, and **registers**. Doing this is simple and you may already have done so intuitively during the last sessions.
1. *However*, making sure that you can **always** and **deterministically** reuse or call a function requires some effort. You may already have experienced that different developers use different registers to do the same thing. What if you use register `x5` to pass a parameter to a function but the other developer expects the parameter in `x6`? What happens if we run out of registers? These and other situations require for a clear set of **conventions** that we expect everyone to adhere to - even (or especially) compilers! This is the slightly difficult part of functions in assembly.

# First steps towards common calling conventions

> :bulb: TL;DR: The official calling conventions are [here on the official RISC-V website](https://riscv.org/wp-content/uploads/2015/01/riscv-calling.pdf) and you can find the short version on the [RISC-V card](/files/riscv-card.pdf) that you will also have access to in the exam.

If the above explanation did not fully click for you yet, don't worry. Let's go step by step and understand why conventions are useful and help us write code that can be used across programs and teams.
Let's take a look at the partial assembly code below. We already created a `main` and a `sum` label

```armasm
.globl main
.data
    a: .word 1
    b: .word 2
    number:  .word 0

.text
main:
    # Load the two numbers a and b into registers

sum:
    # Add the two numbers and put them in a register for main to find.

resume:
    sw a0, number

```

> :fire:  Warm-up 1: Write a simple program in RARS that adds the two numbers `a` and `b` and stores it in `number`.

![Problems that arise when using functions in assembly code](calling-conventions-problem.png "Problems that arise when using functions in assembly code")

Which registers did you use to load the two numbers? What would have happened to your program if the code in `sum` would use different registers? Things would not work. Thus, [the calling conventions of RISC-V](https://riscv.org/wp-content/uploads/2015/01/riscv-calling.pdf) demand that some registers are to be used for `input parameters` and `returns`, others (callee save) are to **be restored** by the called function, and even others (caller save) can be **safely overwritten** by the called function.

Register number             | Register name | Use                   | Note
--------:------             | ------:------ | :------------         | :-------------
`x0`                        | `zero`        | Always zero           | -
`x1 - x4`                   | `ra,sp, gp, tp`| Various uses         | Partially explained below
`x5 - x7` and `x28-x31`     | `t0 - t6`     | Temporary registers   | **Caller** must save these registers before calling the function. Functions may at any time overwrite these registers!
`x8 - x9` and `x18 - x27`   | `s0 - s11`    | Saved registers       | **Callee** must save these registers. Thus, you can safely use these registers in your code and any function that you call **must** back them up and restore them if they decide to use them too.
`x10 - x17`                 | `a0 - a7`     | Function arguments    | Function arguments to called functions. Used as input parameters.
`x10` and `x11`             | `a0` and `a1` | Return values         | Since the input to a function is not useful anymore on return, `a0` and `a1` have a dual use as registers for the return values.

If you take a look at the [RISC-V card linked at the top of the website](/files/riscv-card.pdf), you now understand the register table.

![Calling conventions solve interface issues](calling-conventions-solution.png "Calling conventions solve interface issues")

> :fire:  Warm-up 2: Change your program to adhere to these register conventions as if the `sum` label was a function.

> :fire:  Warm-up 3: Read the [official calling conventions of RISC-V](https://riscv.org/wp-content/uploads/2015/01/riscv-calling.pdf). Since we will not be making use of floating point registers (`ft0` to `ft11`), Section 18.3 applies to us and in this course we will just try to fit all parameters into the argument registers as it is explained there before utilizing the stack.

The official calling conventions talk about passing some function parameters via the stack. Let us now take a look at what happens if we run out of registers and how can we solve this by using the stack.

# Memory: The stack

It is easy to think of cases where the 32 registers we have are not enough. You may already have come to a situation where this is the case but for any larger program, we definitely need to store data in memory. Similarly, if the calling conventions only define 8 registers to pass function arguments, what happens if we want to pass more data to a function than fits into these 8 registers?
You already worked with variables stored in the `.data` section: We could declare a region in memory that we then use to back up or restore data from. But defining specific variables is also not enough for cases where we do not know how many variables we will need.
This is where a data structure could be useful where we dynamically add and remove data from, depending on what we need.

## Understanding a stack

A stack is a simple data structure that grows in one direction and that works after the Last-in-First-Out (LIFO) principle. The idea is as simple as a pile of books where you are only ever able to pick up the top-most book. You can throw more books on the pile but have to pick them up again to reach the books at the bottom of the pile.
To realize a simple stack in assembly, we can just define a large memory region in the data section like this:

```armasm
.data
    stack: .word 500
.text
main:
    ...
```

Now to use this stack, we would do the following actions:

1. Load the address of the stack into a register
1. When we want to push data on the stack:
    1. Put data at the address that the register points to
    1. Increment the pointer by the size of the data you just added so that there is again free space at the stack address
1. When we want to pop data from the stack, we:
    1. Decrement the pointer by the size of the last data element
    1. Read the content of the data stored at the current stack pointer

If you are now unsure about what the size of the data is that you want to put or retrieve from the stack, take a look again at the calling conventions or at the RISC-V sheet, both contain a list of common datatypes and their size in bytes in our RISC-V 32-bit configuration.

> :fire: Warm-up 4: Expand the example above with simple code that loads the address of the stack into a register, pushes two integers (4 and 5 for example) and then pops these integers again.

This simple stack that you have written can already help you to overcome all challenges that we described above:

- If we run out of registers, we can temporarily push the variables onto the stack. As long as we as developers remember where we can find the data and how many variables we pushed after this variable, we can always find it again.
- If we want to send complex data to a function or want to exceed the 8 registers that we can use to send function arguments, we can use such a stack and simply pass the pointer to the data on the stack.
- One additional issue we did not discuss yet is the problem of **program control flow**. What happens on recursion? Or if a function wants to call another function? The functions should always remember who called them and where to *return* to. Thus, it would be a good idea to also put the *return address* (`ra`, `x1`) on the stack.

At this point, it may not surprise you anymore to hear that RISC-V actually has a built-in instructions to deal with the stack, has a dedicated register that is called the **stack pointer** and that the calling conventions heavily rely on these mechanisms:

- The **stack pointer** (`sp` or `x2`) is already set up for you to point to the CPU stack. You can use it in your programs freely.
- In RISC-V (and other architectures) the stack however grows **downwards**. Thus, instead of increasing the pointer as you did in the warm-up above, you **decrement** it. See the excurse below for more details.
- To push data to the stack, you use `addi sp,sp,−4` (by decrementing the stack pointer), to pop data you use `addi sp,sp,4`. Note, that this only changes the pointer, you still need to read or write the data to the stack pointer.

> :fire: Warm-up 5: Change your code from the last warm-up to use the `SP` and the provided stack.

## Excurse: The stack grows downwards !?

> :warning: The stack controlled by the stack pointer in RISC-V grows **downwards** ! It is still a stack but instead of adding a variable *on top* of the older one, you place the variable **below** the older one in memory. This means that when your last element on the stack is at address `0x100`, the next item of size 4 bytes will be at address `0x100 - 0x004 = 0x0FC` (and **not** at `0x104`).

If you want to understand more about this, read through the excurse below.

<details closed markdown="block">
  <summary>
    Excurse: Why does the stack grow downwards?
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

> :bulb: *Why does the stack grow downwards?* Because it became a convention at some point that the **stack grows downwards** and **the heap grows upward**. There are some reasons that make it a smart choice, but nowadays it is just a convention in RISC-V.

</details>

# Using the stack for function calls

Calling a function means multiple things at once:

1. We jump to a new address (or label) and expect the code there to execute for a few instructions.
1. We may want to provide some input to the called function
1. We may expect some return values from the called function
1. The function is expected to jump back, also called *return*, to the code that originally called it
1. Any registers that are marked as caller-save must be saved before the function call and restored afterwards
1. Any registers that are marked as callee-save must remain untouched by the called function

We have already discussed which registers are callee- and caller-save. However we did not discuss how these registers are then to be saved on the stack or in what order we should save them.
The graphic on the RISC-V cheat sheet shows the convention of how to do this. The first thing to do when calling a function is to save the caller-save parameters on the stack. Since this procedure logically belongs to the caller function, it does not matter in which order you save the registers that you need to save, as long as you make sure that you back up all registers marked as caller-save on the stack.
The next step to do when calling a function is to push the arguments to the function on the stack that do not fit into registers.
When jumping to the function, we then fill the `ra` register with the address of the instruction that should be returned to. Most often, this will be the instruction after the jump to the function. This is why there is a special instruction in RISC-V, called the `jal` instruction that first places the address of the next instruction into the ra register and then jumps to the given address.

# Complete calling conventions

> The complete list of things to do when calling a function is as follows:
>
> 1. Push all caller-save registers to the stack. If not all caller-save registers have been used, we do not need to save all (e.g. only save `t0` and `t1` if `t2-7` are unused)
> 1. Push function parameters that do not fit in registers onto the stack
> 1. Place all function parameters that belong into registers in the registers `a0` to `a7`
> 1. Call the function either via `jal` or via another instruction as long as the return address is filled with the next instruction after the jump
>
> In the called function, do the following:
>
> 1. Back up the return address register `ra` as a first thing on the stack
> 1. Back up other callee-save registers that will be used by this function. Unused registers can be skipped if this function does not need them (e.g. if we do not touch `s0-s7`, we can skip saving them)
> 1. Perform function tasks
> 1. Place function return in `a0` and `a1`.
> 1. Restore callee-save registers and `ra`
> 1. Return to parent function via `ret` (or simply jump to `ra`)

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

Convert the following code to Risc-V assembly.
Assume that `main()` does not return like common functions.
Why is this assumption necessary right now?
Use Risc-V calling conventions.

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

We have compiled the function `func` from the code example below to Risc-V 32-bit (RV32I) using gcc.
The compiled function can be found below.
Translate the main function manually to Risc-V.
Follow the calling conventions to pass all arguments correctly.

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
Only add code at the designated `TODO`-points, don't modify the existing code.
Use the stack to make sure *caller-save* registers are saved by the *caller* and *callee-save* registers are saved by the *callee*.
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

{% if site.solutions.show_session_3 %}

#### Solution

```armasm
{% include_relative functions-stack/sol4.asm %}
```

{% endif %}

# Bonus : Tail recursion

A [*tail call*](https://en.wikipedia.org/wiki/Tail_call) occurs whenever the last instruction of a subroutine (before the return) calls a different subroutine.
Compilers can take advantage of tail calls to reduce memory usage. This is because for tail calls, no additional stack frame needs to be entered. Instead, we can simply overwrite the function parameters, jump to the function and execute from there by reusing the original function stack frame.
This is possible since we do not expect to be returned to and instead refer to our original caller that is on our stack frame. Thus, when the called function returns, it will not return to us but directly to the function that called the tail function.

The benefit of tail calls is that they are very light on stack usage. where before, recursions add a stack frame for each recursion depth, tail recursion can do so with a single stack frame for any recursion depth.

> :bulb: The call `fact(n-1)` in the previous exercise is **not** a tail call. Why not?

<details closed markdown="block">
  <summary>
    Solution
  </summary>
  {: .text-gamma .text-blue-000 }

The calculation of the factorial is done after the recursive function returned. Thus, the recursive function call is **not** the last instruction in the function.

</details>

### Bonus exercise

We have converted the factorial program to use tail recursion.
Translate this program to Risc-V.
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
