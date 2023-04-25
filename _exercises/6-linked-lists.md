---
layout: default
title: "Session 6: Linked Lists"
nav_order: 6
nav_exclude: false
search_exclude: false
has_children: false
has_toc: false
---

<!-- TODO FOR NEXT YEAR: change uninitialized_list to empty_list -->
<!-- TODO FOR NEXT YEAR: change assembly malloc function to take bytes and not words (to be same as C) -->

## Table of contents
{: .no_toc .text-delta }

1. TOC
{:toc}

# Introduction

In this session, you will complete one big exercise as a recap of everything that you have learned about RISC-V and C up to now.
In [Session 4](https://cass-kul.github.io/exercises/4-dynamic-memory/#dynamic-data-structures), we already briefly discussed the concept of a linked list. Now, you will implement an interface with a number of operations on linked lists in C, and you will translate the C code to RISC-V code. You will start working on this implementation in the current exercise session. However, to fully complete the assignment will probably take more time than just one session. You can, if you choose, work on this interface for the rest of the semester, at your own pace. Questions can be asked in the current session, in the last session of the semester (this will also be a revision session), and on the discussion forum.

Implementing the full interface is a great way to prepare yourself for the RISC-V programming part of the exam. C programming will not be
evaluated on the exam. However, you will need to translate C code to RISC-V code. Therefore, we recommend to also implement the C part. Furthermore, implementing the interface in RISC-V will be a lot easier when you have C code that you can translate, especially if you wrote that C code yourself.

> :bulb: **Tip**: A good order in which to solve this assignment is to implement a function first in C, then translate this to RISC-V, then move on to the next C function and so forth. Improving at C will help your understanding of assembly and the opposite is true as well. Having the function implementation fresh in your memory will also help your assembly implementation.

> :warning: **Note**: We will not upload solutions for this exercise session. Instead, we provide a thorough testing suite and clear instructions on how to use it. As it is common for more complex programs, there is no single correct way of doing things. If your program passes the tests that we made, then you can assume that your program is also a good solution for the task.

# Dynamic memory

Sometimes we want to use a data structure, but we do not know how big it might become before running the program. To solve this problem, we can use dynamic memory to define data structures that might grow or shrink during runtime. The space reserved for dynamic allocation of memory is called **the heap**.
In session 4, we implemented a [stack structure](https://cass-kul.github.io/exercises/4-dynamic-memory/#exercise-3) by using the heap. We will now use the same concepts to create a list that is not limited in size before execution, as opposed to a regular array in C.

## Linked list

Simply put, a linked list is a data structure that allows to link different nodes with each other by using pointers. The assignment requires you to implement a one-directional linked list, where each node consists of a value and a pointer to the next node. For more details, see the section about [data structures](#data-structures).

Let's have a look at an example of how linked lists work:

1. **Initalization of the list**: We create an empty list where the pointer to the first element has the value `NULL`.
![Empty memory with list pointer](/exercises/6-linked-lists/images/linked_list_1.png)
2. **Adding an element to the list**: We add the value `5` to the linked list. We can do this by allocating some space on the heap for our new node and setting the value of the `first` pointer to the allocated memory. We can then write our value in memory and let the next pointer of the node point to `NULL`.
![Adding first node](/exercises/6-linked-lists/images/linked_list_2.png)
3. **Adding a second node to the list**: We now want to add a second node with the value `3` to the list. We can do this in the same way as the previous step. Note that we want to change the value of the `next` pointer of the previous node to point to our new node.
![Adding a second node](/exercises/6-linked-lists/images/linked_list_3.png)
4. **Removing a node**: We want to delete the previously added node with value `3`. To do this, we need to free the space used for the node we want to delete and make sure that the `next` pointer of the node with value `5` is changed to have the `NULL` value, since there will be no longer a next node in the list.
![Removing a node](/exercises/6-linked-lists/images/linked_list_4.png)

Now that you understand the basics, we can move on to the exercise.

# RARS setup

Before you begin, make sure that RARS is configured correctly. Open the `Settings` menu in RARS and make sure that the options `Assemble all files in directory` and `Initialize program counter to global main if defined` are enabled. This will allow you to work easily with multiple files.

# Linked lists interface

To get started, download [linked_list.zip](/exercises/6-linked-lists/exercise-files.zip). Inside, you will find the following files:

* `c/linked_list.h`: header file containing the definition of the interface functions.
* **+** `c/linked-list.c`: the template in which you need to implement all function definitions.
* `c/linked-list-tests.c`: the C test suite. This file contains the main function that executes all tests in the suite. Look at the implementation of the different functions to get an idea of how to use the linked list interface.
* `c/Makefile`: File that is used to build the C project. Use the command `make` inside the C folder to generate the test suite linked-list and run it. You can try this out immediately after downloading. It should simply fail all tests.
* `asm/linked-list-tests.asm`: the RISC-V test suite. Keep this file open while writing your RISC-V functions. Whenever the test suite fails a certain test, the failing assertion will be highlighted in the simulator. This can be used to quickly discover bugs in your implementation.
* `asm/malloc.asm`: Our own `malloc` implementation, which is our solution to the complex allocator exercise from session 4. In your implementation you are expected to use `malloc` and `free` to allocate memory, as you would do in C (including the error handling!).
* **+** `asm/main.asm`: the main function that executes the test suite. It’s possible to write your own tests in this main function before executing the test suite, if you want.
* **+** `asm/list-*.asm`: a separate file for each interface function that you need to implement. We use separate files per function because RISC-V implementations can become long, and working in a big file can be quite an annoying experience in RARS.

You should only edit the files that start with a **+**.

## Data structures

You can use the following data structure to represent a `List` element:

``` c
struct List {
    struct ListNode *first;
};
```

The element only contains a pointer to the first node of the list. Upon initialization, the value of `first` will be `NULL` since there is no node to point to.

For the nodes (elements of the list), you should use the following data structure:

```c
struct ListNode {
    int value;
    struct ListNode *next;
};
```

The `value` attribute stores the content of the list element and `next` is a pointer to the next node in the list.

## Functions

In order to make to program work, you will need to implement a number of functions. In this section you can find a description and expected operation of each function. If you are still unsure about what the behavior of the function should be, have a look at the test suite.
Each function will return a [status code](#error-codes), indicating whether an error occurred during execution.

> :bulb: **Tip**: Implement the functions in the given order. For some of the more complicated functions, you might need to use a previously written function. The test suite will check the functions in the order below and will abort if a test fails.

> :bulb: **Tip**: In assembly, you can use `malloc` and `free` as defined in the `malloc.asm` file. For `malloc`, pass the number of *words* to allocate (i.e., 1 when you want to allocate 4 bytes), and for `free` pass the address that should be freed. `malloc` will return the address that was allocated (or `NULL`, indicating insufficient memory), while `free` will return nothing.

* ```struct List *list_create();``` <br>
  Creates a new list by allocating a `struct List` and returning the address of this list. In C, you can assume that `malloc` will work correctly, but in RISC-V you should return `OUT_OF_MEMORY` if `malloc` fails!
* ```status list_append(struct List *list, int value);``` <br>
  Appends a value to the end of an existing list by allocating a new `ListElement` struct and adding it to the chain. Returns either `OK`, `OUT_OF_MEMORY`, or `UNINITIALIZED_LIST`.
* ```int list_length(struct List *list);``` <br>
  Counts the number of `ListItem`s in the list and returns the length of this list. Can return `UNINITIALIZED_LIST` if the list was not initialized.
* ```status list_get(struct List *list, int index, int *value);``` <br>
Gets the value at position index in an existing list. Stores this value at the address stored in the `int *value` pointer. Returns either `OK`, `INDEX_OUT_OF_BOUNDS`, `UNINITIALIZED_LIST`, or `UNINITIALIZED_RETVAL`.
* ```status list_print(struct List *list);``` <br>
Prints all elements of the list to the console. Returns either `OK` or `UNINITIALIZED_LIST`. This function is not tested by the test suites.
* ```status list_remove_item(struct List *list, int index);``` <br>
Removes the item with the provided index from the list. Returns either `OK`, `INDEX OUT OF BOUND`, or `UNINITIALIZED_LIST`.
* ```status list_insert(struct List *list, int index, int value);``` <br>
Inserts an element with the provided value at the provided index in the list. Thus, executing with index `0` should insert the new element in the
front of the list, and so forth. Returns either `OK`, `INDEX_OUT_OF_BOUNDS`, `UNINITIALIZED_LIST`, or `OUT_OF_MEMORY`.
* ```status list_delete(struct List *list);``` <br>
Frees all allocated memory that was used for the list (all items and the list itself). Returns either `OK` or `UNINITIALIZED_LIST`.

> :bulb: **Tip**: Before translating a complex function to RISC-V it might be a good idea to explicitly write down (in comments) which registers you will
> allocate to which variables. This makes it much easier to keep track of sometimes very hard to read RISC-V code. It might make your life a lot easier if you have to fix a bug at a later time.

## Test suites and debugging

We provide an extensive test suite for both your C and RISC-V program. The tests will be run on every interface function for all kinds of edge cases.
The C suite should be relatively straightforward to use. Whenever you execute your program, the test suite will test each of the interface functions.
Whenever a certain part of a test fails, you will get an **assertion error** together
with a line number in the test suite. Check out the error in the suite to figure out what your implementation did wrong.

The RISC-V suite is a little bit more complicated. It follows exactly the same structure as the C suite, thus, if you get lost, take a look at the
C implementation as well. Since there is no direct way of using assertions
in RISC-V, we hacked our own version in the simulator. We use macros to execute the same assertions as the ones in C. When the assertion fails, however, we throw an exception by executing `lw t0, 0xdeadbeef`. The exception you will see in RARS whenever an assertion fails is of the following structure:

```
line 131: Runtime exception at 0x004002ac:
Load address not aligned to word boundary 0xdeadbeef
```

While this error message means nothing for your program, the line number points you to the assertion in `linked-list-tests.asm` that failed
for your program. By double-clicking the message, RARS will highlight this line of code in the source file. Thus, this system makes it very easy to see where the test suite fails and why. Whenever you have an exception, make sure to check both the messages and the Run I/O tab. For errors that often occur, our exception handler prints messages with hints to Run I/O tab. This will hopefully speed up your debugging process.

## Error codes

All functions, except `list_create`, return a status code describing whether the function was executed successfully. These are the possible codes:

```c
typedef enum {
  OK = 1,
  UNINITIALIZED_LIST = -1,
  OUT_OF_MEMORY = -2,
  INDEX_OUT_OF_BOUNDS = -3,
  UNINITIALIZED_RETVAL = -4,
} status;
```

* `UNINITIALIZED_LIST` is returned whenever a function is called with the value `NULL` filled in as the list parameter.
* `OUT_OF_MEMORY` occurs whenever `malloc` returns `NULL`, and thus the function failed to execute.
* `INDEX_OUT_OF_BOUNDS` occurs in functions that ask for an index parameter when that index is invalid (e.g., has a negative value).
* `UNINITIALIZED_RETVAL` is used whenever a function provides a return value via a parameter. Thus, the function is supplied a pointer to which to write
this return value. If that pointer points to `NULL`, return this error code.

{% if site.solutions.show_session_6 %}

# Partial solutions

We provide a partial solution to the first two functions (`list-create` and `list-append`). These should help you to troubleshoot minor mistakes in your code if you are stuck. If you understand these two first functions, it should not be difficult for you to also implement the remaining functions.

### list_create

```text
{% include_relative 6-linked-lists/partial-solutions/list-create.asm %}
```

### list_append

```text
{% include_relative 6-linked-lists/partial-solutions/list-append.asm %}
```

{% endif %}
