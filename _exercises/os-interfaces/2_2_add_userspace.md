---
layout: default
title: Programma toevoegen
nav_order: 1
parent: "Userspace"
grand_parent: "Session 1: C introduction"
---

# Eigen user space programma toevoegen

We zijn klaar om een simpel user space programma toe te voegen aan xv6.

* Maak een bestand `helloworld.c` in de directory `user`

```console
[ubuntu-shell]$ touch user/helloworld.c
```

* Schrijf in dit bestand een simpel C-programma dat de string *Hello, world!* print naar de terminal.

```console
[ubuntu-shell]$ gedit user/helloworld.c &
```

Bij het compileren van het besturingssysteem met `make qemu` worden ook alle programma's in de directory `user` gecompileerd naar Risc-V. Dit wordt gespecifieerd door middel van de `Makefile` in `xv6-riscv`.

We voegen nu het helloworld-programma toe aan de Makefile.

* Open het bestand `Makefile`

```console
[ubuntu-shell]$ gedit Makefile &
```

* Zoek naar de definitie van UPROGS en voeg het programma toe

```nix
UPROGS=\
    $U/_cat\
    ...
    $U/_helloworld\
    ...
    $U/_zombie\
```

> :information_source: De `UPROGS` Makefile variabele bevat alle user-space programma's die gecompileerd moeten worden.
> De Makefile zorgt ervoor dat een entry van de vorm `$U/_prog` het bestand `user/prog.c` zal compileren en installeren in de root directory als een uitvoerbaar bestand genaamd `prog`.

* Compileer `xv6` en start via qemu

```console
[ubuntu-shell]$ make qemu
```

* Voer het programma uit

```console
[xv6-shell]$ helloworld
Hello, World!
```
