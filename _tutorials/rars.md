---
layout: default
title: Installing and using RARS
nav_order: 1
nav_exclude: false
has_children: false
---

# Installing and using RARS

[RARS - RISC-V Assembler and Runtime
Simulator](https://github.com/TheThirdOne/rars) is an assembler and simulator
for the RISC-V architecture. It allows you to write RISC-V assembly programs,
and execute and step through the programs that you have written in assembly.

## Install instructions
Make sure you have at least Java 8 installed. Most Linux distributions have
something like `openjdk-8-jdk` in Ubuntu. If you are running Windows it is a bit
more complicated:

    Download Java: https://java.com/en/download/
    Run the installer
    Add Java to your PATH environment variables
        (My Computer > Properties > Advanced > Environment Variables > Path)
        Lots of documentation is online how to do this. One example is https://explainjava.com/java-path/

Once you have Java installed, download the JAR file of the [last RARS
release](https://github.com/TheThirdOne/rars/releases/tag/continuous).

To execute it, simply run `java -jar rars_xxxxxx.jar` (replace x with the
numbers of your specific file) when your terminal is in the same folder as the
JAR file. Double clicking the jar may equally work depending on how you set up
your system.


## How to use
1. Write your RISC-V assembly program in the `Edit` window:
   - Define a `.text` section for code with a `main` function,
   - Make your `main` function visible to other files (and to the simulator) with `.globl main`,
   - Don't forget to activate `Settings > "Initialize program counter to global main if defined"`.

   ![A program written in RARS](/tutorials/img/rars_program.png "Example of program wirtten in RARS")

2. Assemble your program:
   - Once your program is ready, you can assemble it using the wrench icon (or `run > Assemble`).
   - Before you can assemble your program, you have to save it!

3. Execute your program from the `Execute` window,
   - Execute the whole program using the first green arrow,
   - Other arrows can be used for single stepping instructions,
   - Memory and registers contents are displayed during/after execution.

The pictures below illustrate the execution of the program defined above. You
may notice that some instruction of your program (in the `Source` column) are
translated to multiple RISC-V instructions (in the `Basic` column). This is
because these source instructions are **pseudo instruction** (basically
syntactic sugar) that are converted to a sequence of RISC-V instruction by the
assembler.

The `Data Segment` window holds the values `2` (corresponding to variable `a`)
at address `0x10010000`, and `3` (corresponding to variable `b`) at addresses
`0x10010000+4`. The prefix `0x` indicates that the following number is given in
hexadecimal. Note that you can change the display of the data segment to decimal
numbers by unchecking the `Hexadecimal Values` box at the bottom of the window.

   ![Example of program ready to execute](/tutorials/img/rars_execute1.png "Example of program ready to execute in RARS")

At the end of the execution, the `Data Segment` window holds the value `9`
(corresponding to `a * b + b`) at address `0x10010000+8`:

   ![Result of the execution of the previous
   program](/tutorials/img/rars_execute_final.png "Result of the execution of
   the previous program")


## FAQ

- **Why can't I click on the wrench icon / why can't I assemble my program?**  
  Make sure that you have saved your program before you try to assemble it.
