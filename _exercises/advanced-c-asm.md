---
layout: default
title: "Session 2: Advanced C & assembly"
nav_order: 2
nav_exclude: true
search_exclude: true
has_children: false
has_toc: false
---

## Table of contents
{: .no_toc .text-delta }

1. TOC
{:toc}

# Introduction

After the more theory-oriented session 1, this time we will dive into more
complicated exercises (after covering a few more concepts). Of course, if anything
is unclear, you can check back with the [previous exercise](/exercises/c-asm-basics),
ask your teaching assistant, or post in the Toledo forums!

Let's start off by practicing everything you've learned about RISC-V in the previous
session.

### Exercise 1

Take the following C code:

```c
switch (operation) {
    case 0: result = a + b; break;
    case 1: result = a - b; break;
    case 2: result = a + 5; break;
    case 3: result = b + 5; break;
}
```

Convert this code into RISC-V assembly!
Assume that the variables `operation`, `a`, and `b` are integers stored in memory (the data segment).
You can store the result in the `a0` register.

> :bulb: Tip: If at first you're scared of the `switch` statement, don't be!
> Think about how you would convert it into consecutive `if` statements in C.

# Functions in C

In this session, we will briefly introduce functions in C, but the detailed description of how to
translate them into assembly will be the topic of the [third session](/exercises/functions-stack).

You probably remember that every C program must contain the `int main(void)` function,
this is where the execution will start. Remember that the first `int` means that
the function will return an integer value, while `(void)` shows that the function
does not take any arguments.

You can use the same syntax to define your own functions in your file:

```c
int difference(int, int);

int main(void) {
    int x = 5;
    int y = 13;
    int d = difference(x, y);
    // ...
}

int difference(int a, int b) {
    if (a >= b) {
        return a - b;
    } else {
        return b - a;
    }
}
```

## Function declarations

What is the role of the first line in the example above?

```c
int difference(int, int);
```

The compiler moves linearly in the file, it needs to already know the functions
when using them (in `main` or in other functions).
For this reason, it's sometimes necessary to include the function declaration on
top of the file.

In the example above, it would have also been fine to just move the function definition
above `main`, in which case you don't need the declaration on the first line anymore.
(But think of an example where two functions call each other, in that case one of them
has to go above the other!)

> :pencil: When you include a header file, such as `#include <stdio.h>`, that file
> also [contains](https://www.tutorialspoint.com/c_standard_library/stdio_h.htm) a list of function declarations, just like this one! This is how your
> compiler knows the list of functions implemented by the standard library.

### Exercise 2

Write a C program that computes the factorial of every number between 1 and 10.
Avoid duplicating code (use loops and functions where applicable).

# Structs

We often want to group different variables into one object. For example if our
program handles user data, and we want to store the name and age of each user,
it's a lot more convenient to group these two variables into one object.

This is possible in C using structs.

```c
struct person {
    int age;
    char *name;
};

int main(void) {
    struct person John;
    John.age = 42;
    John.name = "John";
}
```

You can refer to the variables inside the struct using the `.` operator. These values
are going to be placed in consecutive memory by the compiler, but sometimes the compiler
leaves some empty space between the different fields (e.g., for optimization reasons). This is called
**padding**.

If you have a pointer to a struct, you can still refer to the fields of the pointed object:

```c
void birthday(struct person *sp) {
    (*sp).age += 1;
}
```

This notation is a bit cumbersome, so you can replace it with the `->` operator:

```c
void birthday(struct person *sp) {
    sp->age += 1;
}
```

Think about this function! Would it work as intended if we passed the struct itself as the parameter,
not a pointer to it? Try it out!

<details>
  <summary>Solution</summary>

Whenever we call a function, the parameters passed to that function are copied.
If we pass the struct itself, the function will operate on a copy of it. We can
update the fields of this copy, but those changes will not be reflected in the
original struct. This is why we need to pass a pointer (= create a copy of the pointer),
because that will point to the location of the original struct, which will allow
the function to update it.
</details>

### Exercise 3

Define a struct containing a float, double, long, string, and a
single char. Print the size of the struct. Create a new instance of this struct
and print the addresses of each field. Draw the memory lay-out chosen by
the compiler. Did the compiler introduce padding? If so, where and how
much?

# Fixed-length arrays

We have already seen integer variables in both C and assembly. How can we create
an array of many integers? Let's say for example, that we want to store how many
classes we have on each day. We could of course just declare a variable for each
day (`int monday, tuesday, ...;`), but this would get out of hand quickly if we
want to perform an operation on all variables.

We can instead create an array with a fixed number of elements:

```c
int classes[7] = {4, 3, 1, 4, 2, 0, 0};
```

> :pencil: You might be wondering: isn't it redundant to first declare that the array
> will contain 7 elements, then list 7 elements? You're right, you can omit the number
> from between the square brackets: `int pair[] = {32, 64};`.
>
> You can also
> omit elements from the *initializer list* on the right side (if you first specify the length of the array): `int classes_two[7] = {4, 3, 1, 4, 2};`.
> This array will be the same as the `classes` array declared above. If you specify fewer elements
> in the list than the number on the left, the remaining elements will be initialized to
> zero.

## Representation in memory

Arrays are a collection of homogeneous elements, and they are stored contiguously in memory.
The array from above would have the following (partial) representation in memory:

<center>
<img src="/exercises/img/array.png" alt="Values of the array in memory" />
</center>

Notice two things: first, in this example, `int` values take up 4 bytes in memory: the
first integer is stored in bytes `0x100-0x103`, the second in `0x104-0x107`, and
so on. Second, this example uses [big-endian](https://nl.wikipedia.org/wiki/Endianness) notation for demonstration purposes, while the x86 and RISC-V
architectures uses little-endian representation.

When we create an array, the variable (`classes`) itself will point to the first element of the array.
It has some special properties, but for the purposes of this course we can think of it as
a regular pointer. This means for example that we can copy it to another pointer
or pass it to a function expecting a pointer argument:

```c
int classes[7] = {4, 3, 1, 4, 2, 0, 0};
int *copy = classes;
```

## Elements of the array

So now we know that the `classes` variable points to the first element of the array. That means that if
we want to read or write that value, we can just write `*classes`, as we've done with other pointers.

But how can we access the other elements of the array? Since we know that they are placed next to each
other in memory, we can simply add an offset to the pointer to access further elements! If we want to get the
third element of the array, we can write `*(classes + 2)`, because we know that we have to move 2 places to the right in
memory compared to the first element.

> :pencil: Hold on! How come we increment the pointer by 1 for each element
> if the memory addresses increase by 4 for each `int`? If `int`s take up 4 bytes
> in memory, we should also increment the pointer by 4 to get to the next `int`, right?
>
> Well, in C, when you increment an `int` pointer by `N`, it will increment by `N * sizeof(int)` so that it automatically points to the next `int` in memory. [The same is true for other pointer types.](https://stackoverflow.com/a/5610311/3680834)
>
> Keep this in mind though for when you're doing arithmetic with pointers in assembly,
> as there you will have to take care of this yourself!

So for example, if we want to change the value stored for Thursday, we can just write:

```c
*(classes + 3) = 5;
```

This notation is a bit verbose, so C allows us to shorten it using the index notation:
```c
classes[3] = 5;
```

Of course, you can also use a variable to index into an array. If you want to iterate over all
the elements of the array, this is a very handy way of doing it (keep in mind that
the first element is at index `0`!):

```c
for (int i = 0; i < 7; ++i) {
    printf("%d ", classes[i]);
}
```

With regular arrays, it's problematic to detect how long an array is. If all the information we have available
is the starting address, how can we tell where the last value of the array is?

In the example above, we explicitly iterated over 7 values, because we know that the week has 7 days.
But what happens if we want to write a function that operates on arrays of varying sizes?

A possible option is to designate a special value as a termination indicator; if our arrays can only contain
positive numbers, we can use a special 0 or negative number as the last value of the array. This way, we can just
iterate over the values of the array until we encounter that special value. This, however, only works if
the possible values are limited. If our array can contain any integer values, what can we do?

### Exercise 4

Write a C program that prints the array `1, 2, 3, 4, 5` on a single
line separated by spaces, together with the addresses of the elements.
Ask the user for an integer, multiply all elements
of the original array with this integer and print the array again. Now, define
a function to print the array to avoid duplicating your code. Don’t hardcode the size of the array in the code!

Hint: Don't be discouraged if your solution looks ugly, you can ask the teaching assistant whether it's correct! :)

## Strings

How can strings be represented in C? If you think about it, strings are just arrays of characters,
that's also how C handles them. One advantage of characters in the [ASCII encoding](https://www.asciitable.com/) (that C uses) is that they have a
limited set of valid values, so we will be able to use the approach outlined above for indicating the end
of strings.

In C, we always use a null byte `\0` to indicate the end of strings. All the functions in the standard library
that operate on strings will expect to see a null byte at the end of the strings they receive as parameters.

That means that if we want to create a string containing the word "hello", we need to write the following:

```c
char hello[] = {'h', 'e', 'l', 'l', 'o', '\0'};
```

Notice that this means that we use one extra byte to store the string, compared to the number of characters!

C also has special syntax for strings (that we have seen before) to make it easier to work with them.

```c
char hello[] = "hello";
```

This will allocate the same array as the example before, complete with the terminating null byte.

### Exercise 5

Write a C program that asks the user for a string and outputs
the length of the string.
You can use
the function `fgets` to read a whole string from the console.

First write a version using the function `strlen`
declared in the header `string.h`. Then create a second version where `strlen`
is not used. Note that the last character of the string will be the line feed
(hex `0x0a`).

### Exercise 6

Modify the program above so that it prints the hexadecimal
representation of each character in the string in order. Verify the
output using an ASCII table. Hint: use the format
string `%02x`.

# Arrays in assembly

In RISC-V assembly, there is no strong notion of arrays in memory. But since we
know that arrays are just consecutive values in memory, we can implement them the
same way in assembly. You can use comma-separated values to reserve consecutive
words in memory:

```armasm
.data
    array: .word 1, 2, 3, 4
```

### Exercise 7

Write a RISC-V program that multiplies all numbers in an
array with a constant number without using the `mul` instruction.

## Strings in assembly

For strings, we again have special syntax:

```armasm
.data
    str: .string "hello"
```

This string notation behaves the same way as in C, complete with the terminating
zero byte.

### Exercise 8

Translate the C program calculating the length of a string without `strlen` from exercise 5
to RISC-V. The string can be provided in the data section. The resulting
length can be stored in register a0.

### Exercise 9

Write a RISC-V program that searches for a given zero-terminated
substring in a string (e.g., `loss` in `blossom`) and returns 1 if it is present, 0 if it isn’t. Define the
strings in the data section and place the result in register `a0`. First, write
a solution assuming that the characters of the string are 32-bit words (use
`.word` instead of `.string`). What changes if the characters are bytes (using
`.string`)?
