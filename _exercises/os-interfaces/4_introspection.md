---
layout: default
title: "Oefening: Introspection"
nav_order: 4
parent: "Session 1: C introduction"
---

# Zelfreflecterend proces

Voeg nu zelf een userspace programma toe genaamd `introspection.c`.
De bedoeling is dat dit programma zijn eigen memory layout uitprint.

We zijn geïnteresseerd in de locatie van:

* de stack
* de heap
* de .text sectie (de code van je programma)
* de .data sectie (de global variables van je programma)

Gebruik onderstaande `struct memlayout` om deze waarden te bewaren.

```c
struct memlayout {
    void* text;
    int* data;
    int* stack;
    int* heap;
};
```

Onderstaande methoden kan je gebruiken om de adressen van elke sectie te vinden:

* Zoek een adres op de stack door een lokale variabele (van type `int`) te declareren in een functie. Deze variabele zal altijd gealloceerd worden op de call stack van je proces. Het adres van deze variabele is dus een adres op de stack.
* Zoek een adres op de heap door een `int` te alloceren via `sbrk(sizeof(int))`. De return-waarde van deze system call geeft de oude waarde terug van de [`program break` (meer info)](https://en.wikipedia.org/wiki/Sbrk) wat het adres is van de nieuwe allocatie.
* Zoek een adres in de .text section door het adres van een functie op te slaan. Het adres van een functie kan je verkrijgen door de naam van de functie te typen (zonder `()`)
  
    ```c
    void* function_address = (void*)function_name;
    ```

* Zoek een adres in de .data section door een globale variabele (van type `int`) te declareren en het adres van deze variabele op te vragen.

Zorg ervoor dat de main-functie van je programma een `struct memlayout` aanmaakt. Sla in elk veld van de struct een correct adres op uit de bijhorende sectie van het programma.
Voeg daarna een functie toe die de waarden in `struct memlayout` afprint en vergelijk je resultaat met Figuur 3.4 in het xv6 boek.

> :exclamation: De bovenstaande werkwijzen geven telkens een adres terug uit een bepaalde sectie van het programma.
> Deze adressen zijn niet noodzakelijk de start- of eindadressen van deze secties.
> Ze vallen wel telkens in de range [`section start addr`, `section end addr`].
> Het is voor deze opgave **niet nodig** om het startadres te geven van een sectie. Een adres in de sectie-range is voldoende.

