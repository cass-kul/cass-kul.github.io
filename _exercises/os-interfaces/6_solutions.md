---
layout: default
title: "Referentieoplossing"
nav_order: 5
parent: "Session 1: C introduction"
---

# Referentieoplossing

Een referentieoplossing voor deze oefenzitting is beschikbaar via de `os-intefaces` branch in de [xv6-riscv](https://github.com/besturingssystemen/xv6-riscv/tree/os-interfaces) repository.

Als je de oplossingen lokaal wil bekijken, kan je deze branch uitchecken:

```bash
git checkout os-interfaces
```

Per oefening is er een commit gemaakt die je via de onderstaande links kan bekijken.

- `puts`: [commit](https://github.com/besturingssystemen/xv6-riscv/commit/2ada830b637b8d94b25da3470abe4b03ae4172a1)
- Hello world: [commit](https://github.com/besturingssystemen/xv6-riscv/commit/7371606cfe438473c06aad5f2dc53cc85e8f120c)
- Zelfreflecterend proces: [commit](https://github.com/besturingssystemen/xv6-riscv/commit/19a1ee8262222c1192780577cc38b0083f508b46)
- Communicerende processen: [commit](https://github.com/besturingssystemen/xv6-riscv/commit/ceff1947db73ec7d38d6e8ce416ff7e1b0654f81)

## Aandachtspunten en veel voorkomende fouten

* Check steeds de return waarden van system calls en standard library functies voor een mogelijke foutcode. In de permanente evaluatieoefening kunnen zowel `pipe()` als `fork()` een foutcode teruggeven.
* Hardcode _nooit_ pointer adressen in je applicatie (bv. als hexadecimale getallen `0xbadc0debadc0de`). Gebruik steeds de runtime return waarde van `sbrk()` als pointer naar een adres op de heap. Zelfs als je adressen zou hardcoden die je bv. met `gdb` hebt opgezocht, geeft dit _geen_ garantie op correctheid in volgende uitvoeringen van je programma(!) Het besturingssysteem is namelijk altijd vrij om je applicatie op een ander adres in te laden (zelfs al is dit niet het geval voor xv6).
* Return in C nooit het address van een lokale, stack-gealloceerde variable. Wanneer je hier later, na de functieaanroep, van leest of naar schrijft, zal dit stack geheugen immers terug vrijgegeven zijn en zelfs mogelijks overschreven door een andere functieaanroep.
* Er is een groot verschil tussen ```sizeof(struct memlayout)``` en ```sizeof(struct memlayout*)```. Het eerste geeft de grootte in bytes van een `struct memlayout`, het tweede geeft de grootte in bytes van een pointer.
* Niet-geinitialiseerde variabelen in C hebben een niet-gedefineerde waarde. Dit betekent dat, zelfs als de testen slagen en je in praktijk verschillende waarden hebt, de C standaard _nooit_ garandeert dat een niet-geinitialiseerde variable een verschillende waarde heeft dan een andere variabele.
