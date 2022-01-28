---
layout: default
title: "Permanente evaluatie"
nav_order: 5
parent: "Session 1: C introduction"
---

# Communicerende processen 
Permanente evaluatie
{: .label .label-yellow}

We weten nu hoe we user space programma's kunnen toevoegen aan xv6.
Als laatste deel van deze oefenzitting en als *permanente evaluatie* is het de bedoeling dat je het programma `introspection.c` uitbreidt _in een nieuw bestand_ genaamd `evaluation.c`.
Maak dus eerst een kopie:

```console
[ubuntu-shell]$ cp user/introspection.c user/evaluation.c
```

en pas de `Makefile` aan om dit nieuwe bestand te compileren.

Het doel van deze oefening is de memory layout van een parent process te vergelijken met dat van een child process.
Naast informatie over de memory layout van de processen, zijn we ook geïnteresseerd in de *waarden* op deze memory locations.
Bijkomend zal het child process zelf niets mogen afprinten maar zijn layout informatie delen met de parent via een pipe.

Je programma zal de volgende stappen moeten uitvoeren:

1. Initialiseer een `struct memlayout` op dezelfde manier als in de vorige oefening;
1. Zorg ervoor dat alle gealloceerde variabelen geïnitialiseerd zijn;
1. `fork` een nieuw process en zorg dat er een `pipe` gedeeld wordt tussen parent en child;
1. In het child process:
    1. Initialiseer een `struct memlayout` op dezelfde manier als in de vorige oefening.
       Je moet hiervoor de stack en data variabelen hergebruiken maar maak wel een nieuwe heap allocatie aan;
    1. Zorg ervoor dat alle gealloceerde variabelen geïnitialiseerd zijn (gebruik een *andere waarde* dan in het parent process);
    1. Kopieer de waarden in een `struct memvalues` (zie hieronder);
    1. Zend eerst de `struct memlayout` en dan de `struct memvalues` naar de parent via de pipe;
1. In het parent process:
    1. Ontvang `struct memlayout` en `struct memvalues` van het child process;
    1. Print deze structs via `print_mem` (zie hieronder);
    1. Initialiseer een `struct memvalues` met de waarden in het parent process;
    1. Print de structs van het parent process via `print_mem`.

```c
struct memvalues {
    int data;
    int stack;
    int heap;
};

// who should be either "parent" or "child"
void print_mem(const char* who, struct memlayout* layout, struct memvalues* values) {
    printf("%s:stack:%p:%d\n", who, layout->stack, values->stack);
    printf("%s:heap:%p:%d\n", who, layout->heap, values->heap);
    printf("%s:data:%p:%d\n", who, layout->data, values->data);
    printf("%s:text:%p\n", who, layout->text);
}
```

Denk voor je begint aan de implementatie na over wat de output van je programma zal zijn.
Probeer voor jezelf te voorspellen wat de relatie gaat zijn tussen adressen en waarden van variabelen in parent en child processen.

## Testen

We hebben een paar simpele testen gegeven die jullie kunnen gebruiken om te verifiëren dat er geen grote fouten gemaakt zijn.
Je kan deze uitvoeren via het volgende commando:

```console
[ubuntu-shell]$ make test
```

Let wel: we kijken jullie code ook nog handmatig na en het feit dat de testen slagen, wilt niet zeggen dat je een perfecte score zult halen!.

> :warning: Zorg steeds voor het indienen dat de testen zowel lokaal als in de GitHub Actions cloud werken.

> :bulb: De testen worden automatisch uitgevoerd op GitHub wanneer je nieuwe code pusht.
> Verifieer dat alles werkt door naar de "Actions" tab te gaan op de GitHub
> webinterface van je repository (of kijk naar het groene vinkje of rode
> kruisje dat naast je commit verschijnt).

## Indienen

Dit deel van de opgave moet ingediend worden en telt mee voor de permanente evaluatie van de oefeningen.

* Commit en push het bestand `evaluation.c` naar je repository

```console
[ubuntu-shell]$ git status # Aangepaste en nieuwe bestanden zijn aangegeven in het rood onder de heading "Changes not staged for commit" en "Untracked files"
[ubuntu-shell]$ git add user/evaluation.c # Voeg ook andere aangepaste bestanden toe die nodig zijn
[ubuntu-shell]$ git status # Alle bestanden die je wil committen zouden nu aangegeven moeten zijn in het groen onder de heading "Changes to be committed"
[ubuntu-shell]$ git commit -m "Added introspection program"
[ubuntu-shell]$ git push
```

> :bulb: Controleer op de webpagina van je repository of het bestand correct gecommit is.

