---
layout: default
title: "Oefening: Library toevoegen"
nav_order: 3
parent: "Session 1: C introduction"
---

# Library functie toevoegen

Als er enkel een string afgeprint moet worden zonder interpolatie van variabelen, gebruikt men meestal de functie `puts` uit libc.
De beperkte libc versie die xv6 aanbiedt, implementeert deze functie echter niet.
Je hebt in de vorige oefening dus waarschijnlijk de (minder efficiënte) `printf` functie gebruikt.
In deze oefening moeten jullie `puts` implementeren als een library functie en de oplossing van de vorige oefening aanpassen om deze functie gebruiken.

De declaratie van `puts` is als volgt (dit is een vereenvoudigde versie zonde return-type, de versie in libc geeft een `int` terug om fouten weer te geven):

```c
void puts(const char* str);
```

`puts` schrijft de null-terminated string `str` naar stdout gevolgd door een newline (`\n`).

Om ervoor te zorgen dat alle xv6 user-space programma's `puts` kunnen gebruiken, moet de declaratie eerst toegevoegd worden aan `user/user.h`.
Maak daarna een nieuw bestand aan (`user/puts.c`) waarin `puts` geïmplementeerd zal worden.
Om ervoor te zorgen dat dit bestand gecompileerd wordt, moet je de `ULIB` variabele in de `Makefile` uitbreiden met `$U/puts.o`.
De `ULIB` variabele bevat de object files die aan alle user-space programma's worden toegevoegd.
Dit zijn dus onder andere alle bestanden die library functies implementeren.

Implementeer nu de `puts` functie in `user/puts.c`.
Het is de bedoeling om enkel de `write` system call te gebruiken (gebruik dus zeker *niet* `printf` om `puts` te implementeren).
Andere library functies de geen system calls veroorzaken (zoals `strlen`) mogen wel gebruikt worden.

> :information_source: Met behulp van een ["system call"](https://en.wikipedia.org/wiki/System_call) kan een user programma een service van het onderliggende besturingssysteem aanvragen. System calls zijn gestandardiseerd in de Portable Operating System Interface (POSIX) standaard. Tijdens het programmeren van user programma's, kan je de verwachte argumenten en return waarden voor een system call opvragen via het Linux commando `man` (sectie 2), bijvoorbeeld [`man 2 write`](https://linux.die.net/man/2/write). Let wel, in tegenstelling tot de Linux kernel, is xv6 een educationeel klein besturingssysteem dat expliciet **niet** bedoeld is om de volledige POSIX standaard te implementeren. Gebruik de Linux `man` pages dus vooral als leidraad, maar verwacht niet dat xv6 alle system calls of randgevallen steeds zal implementeren!

