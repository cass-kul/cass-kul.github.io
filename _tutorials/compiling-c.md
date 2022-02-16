---
layout: default
title: Compiling C
nav_order: 1
nav_exclude: false
has_children: false
---

# Compiling C

In CASS, we will teach you how to interact (`program`) with the CPU on the lowest layer of abstraction that it understands: Assembly.
Since the jump from `higher-level` programming languages such as Python or Java to assembly is quite big, we first want you to have basic understanding of the C language. [The C language](https://en.wikipedia.org/wiki/C_(programming_language)) is a rather old programming language that has a closer connection to assembly than the higher-level programming languages you may know already.

## Running C programs

Programs written in C can not directly be executed. Instead, they have to be `compiled` first. `Compilation` is the step of transforming programming code into a language that the CPU understands : Assembly.
For [Java](https://www.javatpoint.com/is-java-interpreted-or-compiled) and [Python](https://www.geeksforgeeks.org/python-compiled-or-interpreted/) the compilation step is mostly hidden from the developer, and a simple command is enough to execute the code.
Thus, to compile C programs, we need to install a set of tools (a compiler) that allows us to run the generated `executable` code.

Below we show you three options of how to work with C from the Browser, from Windows, and from Linux.
For the first few sessions, compiling the rare C programs in the Browser may be enough for you but later, we will rely on you having access to a compiler. This is because compiling in the browser does not work with bigger projects like we will have for exercise session 6.

## A simple test program

You can test your compiler setup with the simple `hello world` example below.

```c
#include <stdio.h>

int main(void) {
    printf("Hello world!\n");
    return 0;
}
```

## Compiling C in the Browser

The website [Goodbolt](https://godbolt.org/) allows you to write C code on the left and visualize the compiled assembly instructions on the right. This is very useful if you just want to see how a C program looks like in assembly.
There are several configurations for you to choose from and the most important ones for this course will be:

- `x86-64 gcc 11.2` : Assembly for an x86-64 CPU. This will most likely be the architecture that you compile to when you want to run code on your own machine (if you don't have a newer ARM-based Mac for example)
- `RISC-V rv32gc gcc 10.2.0` : Assembly for a RISC-V CPU in the `rv32gc` configuration. For the sake of the uses of the goodbolt website, you can stick to this configuration if you want to see how C is compiled to RISC-V code.

Note, that these configurations may differ widely and you will understand in some weeks why that may be the case. For now, it is enough to just stick to the two mentioned configurations but feel free to play around with other configurations as well.

## Compiling C in Windows 10 with Windows Subsystem for Linux (WSL)

Compiling C in Windows can be rather complicated. In the past years, we advised students to install MinGW and compile on Windows. You can still find that description at the bottom of this page if the modern approach does not work for you.

A modern approach of working with C in Windows is to use integrated Linux support that is built into Windows called WSL.
There are good websites on how to enable and install WSL, for example the [official documentation by Microsoft](https://docs.microsoft.com/en-us/windows/wsl/install).
In essence, you only need to:

1. Open a PowerShell Window **as administrator** (see screenshot below how to do this if you are not sure).
1. Run the command `wsl --install`
1. Restart Windows (may take a minute)
1. After restarting, you should see an open terminal where Ubuntu is currently being installed. Ubuntu is the default Linux distribution recommended for WSL and there is no reason to change. If this installation fails for some reason, you can always restart it in an administrator Powershell with the command `wsl --install -d Ubuntu`
    - If for some reason there is an error, one first solution could be to change the wsl version to 1 (default is 2). Do this with the command `wsl --set-default-version 1`.
1. During installation, you will be asked for a username and password. While this choice is usually important, this installation is just a virtual machine on your Windows machine. Thus, security is not necessarily a big concern anymore. Feel free to choose a simple username/password combination like `ubuntu` for both username and password.
1. If the ubuntu window is not already open, you can now always start it by searching for and opening the `Ubuntu` app (see screenshot).

![Open a Powershell as administrator](/tutorials/img/open-powershell.png "Screenshot to show how to open a powershell in Windows as administrator")
![Installing WSL](/tutorials/img/install-wsl.png "Screenshot to show how to install WSL in a Powershell terminal")
![Opening Ubuntu](/tutorials/img/ubuntu.png "Screenshot to show how to open the Ubuntu app")

At this point, you have a fully functional Ubuntu virtual machine (VM) on your Windows system. There is no graphical interface, but we also do not need that for our purposes. You can always access the current folder that is open in Ubuntu by executing the command `explorer.exe .` in the Ubuntu VM. This will open a Windows Explorer window with the folder as it is stored in Ubuntu. You can use this to work on files from Windows and then execute the compiler from the Ubuntu Terminal.

Now you are set up with a Linux VM to work with. Keep reading below of how to set up Ubuntu to compile C programs.

## Compiling C in Linux

No matter if you already have a Linux OS running or if you are using WSL, open a new Terminal. In WSL, this is what you already see when you open Ubuntu and log in, on normal Ubuntu, you will have to search for the Terminal program or press `CTRL+ALT+T` simultaneously.

In the following, any command you should enter starts with a `$` sign that you do not enter yourself but that just signifies a command to be entered. This helps us to show you what output you should expect. Thus, all lines not starting with a `$` are output that you should expect (and there may of course be other output that we do not show here).

Once you have the terminal open, update the system (or skip this step if you know what you're doing):

```bash
$ sudo apt update && sudo apt upgrade -y
$ sudo apt autoremove -y
```

Then, install the `gcc` compiler package:

```bash
$ sudo apt install gcc -y
```

Once you did so, you can check that gcc was installed correctly by executing (Your output may differ):

```bash
$ gcc --version
gcc (Ubuntu 9.3.0-17ubuntu1~20.04) 9.3.0
Copyright (C) 2019 Free Software Foundation, Inc.
This is free software; see the source for copying conditions.  There is NO
warranty; not even for MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
```

Now, save the contents of the example program above into `hello.c`. You can do so either by using a graphical interface or by using command line text editors like `nano`. Doing so in `nano` is not too difficult:

```bash
$ nano hello.c
# Here you now see a window where you can enter code. You can paste text by pressing CTRL+SHIFT+V or if you're using Windows, also by right clicking into the terminal window.

# After you are done with the changes to the file, you exit nano by pressing CTRL+X and can confirm or deny that the file should be saved by pressing Y or N and confirming with ENTER.
```

Now, you can compile and run your program with the following commands:

```bash
$ gcc hello.c -o hello
$ ./hello
Hello world!
```

If you see the `Hello world!` output, you are done with the setup! :tada:

## Alternative: Compiling C in Windows with MinGW

If you can not make Windows Subsystem for Linux work or do not have access to Windows 10 AND refuse to use a Virtual Machine or Linux distribution, you may also have success with using MinGW. Note, that this description is from the previous years and we can not really support you if this does not work.

1. Get the MinGW installer: <https://sourceforge.net/projects/mingw/files/latest/download>
1. Run this installer
1. Install location at C:/MinGW
1. Packages to install include at least:
    1. mingw32-base
    1. mingw-developer-toolkit
    1. msys-base
1. Add C:/MinGW/bin to your PATH environment variables: `My Computer > Properties > Advanced > Environment Variables > Path`

More extended instructions can be found here: <http://www.mingw.org/wiki/Getting_Started>.
You can check if everything is working correctly by

1. Opening `Course Documents -> Exercise sessions`
1. Creating the file `hello-world.c` with the example code at the top
1. Open a command line
1. Use the `cd`(change directory) command to go to the folder in which you created `hello-world.c`
1. Execute the following command `gcc hello-world.c -o hello-world`
1. Now, execute the compiled program: simply type `hello-world` and press enter

If the terminal shows `Hello world` you are done.
