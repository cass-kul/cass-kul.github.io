---
layout: default
title: xv6 shell
nav_order: 1
parent: "Session 1: C introduction"
---

# xv6 shell

Wanneer je xv6 start met ```make qemu``` beland je in een simpele shell-omgeving.

* Voer het commando ``ls`` uit in de xv6 shell

    ```console
    [xv6-shell]$ ls
    ```

Het resultaat van het ls-commando toont de root directory van het file system van xv6. In de startdirectory staan alle user space programma's. Deze programma's kan je uitvoeren vanuit de xv6 shell.
Daarnaast staat er ook een README-bestand.

* Lees `README` met behulp van het `cat`-commando

    ```console
    [xv6-shell]$ cat README
    ```

* Maak een folder aan genaamd `testfolder` en `cd` naar die folder.
  
  ```console
  [xv6-shell]$ mkdir testfolder
  [xv6-shell]$ cd testfolder
  ```

* Verifieer nu met `ls` dat je in de lege folder zit
  
    ```console
    [xv6-shell]$ ls
    ```

Je krijgt nu de melding `exec ls failed`. De xv6 shell is namelijk een zeer simpele shell.

Wanneer je in `shell` (de standaard shell in de meeste Linux-distributies) een commando uitvoert, zoekt `shell` in alle directories in een variabele genaamd `$PATH` naar dit programma.
De shell van xv6 (het programma `sh`) heeft geen `$PATH`-variabele en zoekt dus enkel in de huidige directory naar uitvoerbare programma's.
Je kan alsnog `ls` uitvoeren door een relatief of absoluut pad te specifiëren.

* Voer ls uit in `sh` met een relatief pad

    ```console
    [xv6-shell]$ ../ls
    ```

* Voer ls uit in `sh` met een absoluut pad

    ```console
    [xv6-shell]$ /ls
    ```

Sluit de shell af met de toetsenbordcombinatie ```CTRL+A x```.

> :bulb: ```CTRL+A x``` != ```CTRL+A+x```. Duw eerst op ```CTRL+A```, laat dit los, en druk vervolgens op ```x```.
