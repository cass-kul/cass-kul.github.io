---
layout: default
title: "Session 3: Functions and the Stack"
nav_order: 3
nav_exclude: false
has_children: false
has_toc: false
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
#include <stdio.h>
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

> Warm-up 1: Write a simple program in RARS that adds the two numbers `a` and `b` and stores it in `number`.

![Problems that arise when using functions in assembly code](calling-conventions-problem.png "Problems that arise when using functions in assembly code")

Which registers did you use to load the two numbers? What would have happened to your program if the code in `sum` would use different registers? Things would not work. Thus, the calling conventions of RISC-V demand that some registers are to be used for `input parameters` and `returns`, others (callee save) are to **be restored** by the called function, and even others (caller save) can be **safely overwritten** by the called function.

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

> Warm-up 2: Change your program to adhere to these register conventions as if the `sum` label was a function.



Let us now take a look at what happens if we run out of registers and how can we solve this by using memory.

# Memory: The stack

It is easy to think of cases where the 32 registers we have are not enough. You may already have come to a situation where this is the case but for any larger program, we definitely need to store data in memory.
You already worked with variables stored in the `.data` section: We can declare a region in memory that we then use to back up or restore data from. But defining specific variables is also not enough for cases where we do not know how many variables we will need.

## Understanding a stack

A stack is a simple data structure that grows in one direction and that works after the Last-in-First-Out (LIFO) principle. The idea is as simple as a pile of books where you are only ever able to pick up the top-most book. You can throw more books on the pile but have to pick them up again to reach the books at the bottom of the pile.
To realize a stack in assembly, we can just 

> :warning: Add exercise where they use own stack in data section

> :warning: Introduce stack pointer that takes over self-made stack. Change exercise to use SP


## Excurse: The stack grows downwards !?!

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

> Explanation and little exercises

# Complete calling conventions

> Revisit all stuff for first exercise

# Additional exercises
 
> additional exercises

# Bonus : Tail recursion