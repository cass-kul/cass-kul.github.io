---
layout: default
title: GitHub Classroom
nav_order: 0
parent: "Session 1: C introduction"
---

# GitHub classroom

De submissie van de permanente evaluatie zal gebeuren via GitHub classroom.
Jullie krijgen hiervoor een kopie van de xv6 repository.
Hierin kunnen jullie met `git` zelf wijzigingen toevoegen en committen.

* Klik op [deze link](https://classroom.github.com/a/dO_SIWTY) om een persoonlijke repository aan te maken.

Wanneer je een e-mail krijg van GitHub dat je repository klaar is, moet je deze clonen naar je eigen machine. Dit kan enkele minuten duren.

> :warning: Om bij GitHub te authenticeren via de command line maken we gebruik van ssh met public/private key authentication.
> Onderstaand clone-commando zal pas werken na het uitvoeren van het commando ```ssh-add <pad-naar-je-private-key>```.
> Het genereren en gebruik van deze ssh keys wordt uitgelegd in de laatste sectie van [deze tutorial](https://github.com/besturingssystemen/klaarzetten-werkomgeving).
> Je zal je key ook aan GitHub moeten toevoegen, dit staat [hier](https://docs.github.com/en/authentication/connecting-to-github-with-ssh/adding-a-new-ssh-key-to-your-github-account) uitgelegd.

* Clone je persoonlijke repository, waarbij je `<GitHubUsername>` (inclusief `<>` haakjes) vervangt door je GitHub username:

```console
[ubuntu-shell]$ git clone git@github.com:besturingssystemen-2021-2022/os-interfaces-<GitHubUsername>.git
```

* Verifieer dat je repository correct gecloned is door `make qemu` uit te voeren.

```console
[ubuntu-shell]$ cd os-interfaces-<GitHubUsername>
[ubuntu-shell]$ make qemu
```

Indien `make qemu` ervoor zorgt dat xv6 opstart, is je repository correct gecloned.
