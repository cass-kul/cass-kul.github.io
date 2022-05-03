---
layout: default
title: "Session 8: Performance and Microarchitecture"
nav_order: 7
nav_exclude: true
search_exclude: true
has_children: false
has_toc: false
---

## Table of contents
{: .no_toc .text-delta }

1. TOC
{:toc}

# Introduction

The goal of today's exercise session is to introduce you to some microarchitecure and low level optimization concepts. 
Learning about these optimizations will not only make you a better programmer, but will also give you more insight in to the wonderful low-level world and enhance your reasoning skills about it.
You should read the book from section 4.1 to 4.9 to get a better grasp on processor design and architecture.


## Improving performance across all abstraction layers


Below you see a figure of the abstraction layers we look at in the context of computing.

![Improving performance across all abstraction layers](/exercises/8-microarchitecture/abstraction-layers.drawio.svg){: .center-image }


# Instruction set architectural awareness

RISC vs CISC

# Microarchitectural awareness

Pipelining
out of order execution
speculative execution

Execution phases:

1. Instruction Fetch
1. Instruction Decode
1. Execute
1. Memory access
1. Writeback

## Single cycle vs pipelined design

5 stage riscv

## Hazards

### Data hazards

### Control hazards

## Spectre and Meltdown

## Exercise 1 - Microarchitecture and Performance

In this exercise we examine how pipelining affects the clock cycle time of the processor. Problems in
this exercise assume that individual stages of the datapaths a and b have the following latencies:

|   |  IF  |  ID  |  EX  |  MEM |  WB  |
|:-:|:----:|:----:|:----:|:----:|:----:|
| a | 300ps| 400ps| 350ps| 500ps| 100ps|
| b | 200ps| 150ps| 120ps| 190ps| 140ps|


### Exercise 1.1
What is the clock cycle time in a pipelined and single-cycle non-pipelined processor?

{% if site.solutions.show_session_8 %}
#### Solution

In a pipelined processor, each pipeline stage executes for one clock cycle. This means that the clock cycle needs to be adjusted to accommodate the most time-consuming pipeline stage.

In a single-cycle design, the entire execution with all stages executes in one clock cycle. Naturally, the clock cycle then needs to be as long as the sum of all the stages.

|   | Pipelined   | Single-cycle    |
|:-:|:-----------:|:---------------:|
| a | 500ps       | 1650 ps         |
| b | 200ps       | 800ps           |  

{% endif %}

### Exercise 1.2

What is the total latency of a `lw` instruction in a pipelined and single-cycle non-pipelined processor?

{% if site.solutions.show_session_8 %}
#### Solution
The total latency of an instruction is the time it takes between when the instruction starts to be fetched until its results are written back into memory -- in other words, the sum of all stages of execution.

In a pipelined processor, this equals the cycle time multiplied with the number of pipeline stages. In a single-cycle processor, this is simply the cycle time, as all stages execute during one cycle.

|   | Pipelined   | Single-cycle   |
|:-:|:-----------:|:--------------:|
| a | 2500ps      | 1650ps         |
| b | 1000ps      | 800ps          |  

{% endif %}

### Exercise 1.3

If we can split one stage of the pipelined datapath into two new stages, each with half the latency of the original stage, which stage would you split and what is the new clock cycle time of the processor?

{% if site.solutions.show_session_8 %}

#### Solution

As the cycle time is determined by the most time-consuming stage, this is the one that is worth splitting up. The new cycle time will be determined by the new longest stage.

|   | Stage to split | New clock cycle time  |
|:-:|:--------------:|:---------------------:|
| a | MEM            | 490ps                 |
| b | IF             | 190ps                 | 

{% endif %}

## Exercise 2 - Microarchitecture and Performance 2

Consider a processor where the individual instruction fetch, decode, execute, memory, and writeback stages in the datapath have the following latencies

|  IF  |  ID  |  EX  |  MEM |  WB  |
|:----:|:----:|:----:|:----:|:----:|
| 150ps| 50ps | 200ps| 100ps| 100ps|

We assume a classic RISC instruction set where all 5 stages are needed for loads (`lw`), but the writeback WB stage is not necessarily needed for stores (`sw`) and the memory MEM stage is not necessarily needed for register (R-format) instructions.
Instead of a single-cycle organization, we can use a multi-cycle organization where each instruction takes multiple clock cycles but one instruction finishes before another is fetched. In this organization, an instruction only goes through stages it actually needs (e.g. sw only takes four clock cycles because it does not need the WB stage).
Compare clock cycle times and execution times with single-cycle, multi-cycle, and pipelined organization.

### Exercise 2.1

Calculate the clock cycle time for a single-cycle, multi-cycle, and pipelined implementation of this datapath.

{% if site.solutions.show_session_8 %}

#### Solution

The cycle times of the single-cycle and the pipelined processor can be calculated as before, and they will be 600ps and 200ps, respectively.

In the multi-cycle organization, same as for the traditional pipelined design, the clock cycle is limited by the longest stage, so the cycle time of this processor is also minimum 200ps.

In short:

- single-cycle: minimum 600ps
- multi-cycle: minimum 200ps
- pipeline: minimum 200ps

{% endif %}


### Exercise 2.2

What are the best and worst case total latencies for an instruction in each of the 3 designs (single-
cycle, multi-cycle, pipelined)? Note: express instruction latency both in number of cycles as well as in total time
(ps). Based on these numbers, which design would you prefer? Explain.

{% if site.solutions.show_session_8 %}
#### Solution

For the single-cycle and the pipelined design, all instructions take the same amount of time regardless of which stages are used during their execution. In the case of the single-cycle processor, this is 600ps (1 cycle), for the pipelined processor, it is 1000ps (5 cycles, each taking 200ps).

In the multi-cycle processor, register instructions don't use the MEM stage, which means they only have to pass through 4 pipeline stages (4 cycles), adding up to 800ps. For some instructions though, all of the stages are used, so in the worst case the execution takes 1000ps.

The single-cycle and the multi-cycle designs outperform the pipelined design in terms of instruction latency, but due to the parallel nature of the pipelined design, that one still performs much better in terms of instruction throughput. This is demonstrated by the following exercise.

In short:

- single-cycle: always the same: 1 cycle (600ps)
- multi-cycle: best case (R-format) = 4 cycles (4*200=800ps), worst case = 5 cycles (5*200=1000ps)
- pipeline: always the same: 5 cycles (5*200=1000ps)

{% endif %}

### Exercise 2.3

Consider the following RISC-V program:

```armasm
addi t0 , zero , 10
sw zero , 4( t1)
lw t2 , 10( t3)
```

For each of the 3 CPU designs (single-cycle, multi-cycle, pipelined), fill out the grid below where the horizontal axis represents time (every cell is 100 ps), and the vertical axis lists the instruction stream. 
First draw the clock signal indicating at which time intervals a new CPU cycle starts, and then visualize how the processor executes the instruction stream over time. 
Clearly indicate the start and end of each of the 5 datapath stages (IF, ID, EX, MEM, WB) for all instructions.
Note: you can assume the CPU starts from a clean state (e.g., after a system reset).

![Ex 2.3: Pipeline question](/exercises/8-microarchitecture/pipelining-diagrams.png){: .center-image }


{% if site.solutions.show_session_8 %}
#### Solution
{% endif %}

![Ex 2.3: Pipeline solution](/exercises/8-microarchitecture/sol2-3.png){: .center-image }

From these figures, we can see how much more efficient the pipelined design is, even for shorter programs.

### Exercise 2.4

What is the total time and cycles needed to execute the above RISC-V program from question (2.3) for each of the three CPU designs? 
What if we add 50 no-operation instructions (add zero, zero, zero)?
Provide a formula to explain your answer.

{% if site.solutions.show_session_8 %}

#### Solution

For the single-cycle design, the original program takes 3 cycles to execute, which is `3 * 600ps = 1800ps`. As every instruction takes 600ps to execute, adding the nop instructions would result in an additional `50 * 600ps = 30,000ps`.

In the multi-cycle system, the original program took 13 cycles, as the first two instructions need 4 cycles each, the third one needs all 5. This gives a total execution time of `13 * 200ps = 2600ps`. Nop instructions do not access the memory, so they execute for 4 cycles. This means that adding the 50 extra instructions would increase the execution time by `50 * 4 = 200` cycles, which equals `200 * 200ps = 40,000ps`.

For the pipelined processor, the first instruction takes 5 cycles to execute. During this time, the pipeline already starts executing the next instructions, and after the 5th cycle, one instruction finishes in every cycle. As a result, the example program finishes in 7 cycles, `7 * 200ps = 1400ps`. If we add 50 nop instructions, those extend the execution time with 50 cycles, as in each cycle one nop instruction will complete, resulting in an extra time of `50 * 200ps = 10,000ps`.

In short:

- single-cycle: 3 cycles (1800ps); 50 extra cycles (+30,000 ps)
- multi-cycle: 13 cycles (2600ps); 50*4 extra cycles (+40,000 ps)
- pipeline: 7 cycles (1400ps); 50*1 extra cycles (+10,000 ps)

{% endif %}


### Exercise 4.5

Recall the RISC-V program from above.

```armasm
addi t0 , zero , 10
sw zero , 4( t1)
lw t2 , 10( t3)
```

Describe the performance implications for each of the three CPU designs, if in the RISC-V program the first instruction is changed to `addi t1, zero, 10` (hint: hazards).

{% if site.solutions.show_session_8 %}
#### Solution

As there is no parallelism in single-cycle and multi-cycle processors, there are also no hazards. Instructions only start executing once the previous once have completely finished and their modifications have been carried out in memory or the register file.

In the pipelined design, changing the first instruction like this would create a read after write (RAW) dependency between the first and the second instructions, as the second one uses the `t1` register the first instruction writes to. The second instruction needs the correct value of `t1` in its EX stage, but by then the first instruction is only in its MEM stage, the register file has not been written yet. To avoid this hazard, the processor either has to stall the second instruction until the correct value is available in `t1` or set up data forwarding between the pipeline registers.

{% endif %}


## Exercise 3 - Forwarding
The code below describes a simple function in RISC-V assembly.

```armasm
or t1 ,t2 ,t3
or t2 ,t1 ,t4
or t1 ,t1 ,t2
```

Assume the following cycle times for each of the options related to forwarding:
- Without forwarding: 250ps
- With Full Forwarding: 300ps

### Exercise 3.1
Indicate the dependencies and their type: Read After Write (RAW), Write After Read (WAR), Write
after Write (WAW).

{% if site.solutions.show_session_8 %}
#### Solution

- Both (2) and (3) read `t1` after (1) writes it (RAW)
- (3) reads `t2` after (2) writes it (RAW)
- (2) writes `t2` after (1) reads it (WAR)
- (3) writes `t1` after (2) reads it (WAR)
- (3) writes `t1` after (1) writes it (WAW)
{% endif %}

### Exercise 3.2
Assume there is no forwarding in the pipelined processor. Indicate hazards and add nop (no operation) instructions to eliminate them.

{% if site.solutions.show_session_8 %}
#### Solution

WAR and WAW dependencies do not cause hazards in the pipeline; it does not matter what the value of the register is when it is being written.

RAW dependencies cause hazards for two instructions that follow the instruction that writes the value.

|  1 |  2 |  3 |  4 |  5 |  6 |  7 |  8 |     |
|:--:|:--:|:--:|:--:|:--:|:--:|:--:|:--:|:---:|
| IF | ID | EX | ME | WB |    |    |    | (1) |
|    | IF | ID | EX | ME | WB |    |    | (2) |
|    |    | IF | ID | EX | ME | WB |    | (3) |
|    |    |    | IF | ID | EX | ME | WB | (4) |

If instruction (1) writes a register value, that write will happen in clock cycle 5, in the WB stage. The earliest that value can be read is in the same clock cycle. (Writes to the register file happen in the first half of the cycle, reads in the second, this is why it's possible to read the correct value in the same cycle it gets written.)

As register values are read in the ID stage, that means that instructions (2)-(3) would still load the stale register value, they either need to be stalled or the correct value needs to be forwarded to their EX stage.

In this case, we manually stall instructions by inserting nops to mitigate the two RAW hazards:

```armasm
or t1, t2, t3
nop
nop
or t2, t1, t4
nop
nop
or t1, t1, t2
```

{% endif %}

### Exercise 3.3
Assume there is full forwarding in the pipelined processor. 
Indicate the remaining hazards and add nop (no operation) instructions to eliminate them.
Compared the speedup achieved by adding full forwarding to a pipeline with no forwarding.

{% if site.solutions.show_session_8 %}
#### Solution

With full forwarding, register values that are calculated in the EX stage can be forwarded to the following instruction's EX stage, which eliminates the hazards in this code. This means that we don't need to add any nop instructions.

The execution time for this program is 7 cycles, 5 to execute the first instruction and 2 to finish the other two. With the increased cycle time, this amounts to `7 * 300ps = 2100ps`.

Without forwarding, we are forced to add the 4 nop instructions, which adds 4 additional cycles to the execution time. Even with the shorter cycle times, this is `(7+4) * 250ps = 2750ps`, which is 1.3 times longer than with full forwarding.

{% endif %}


## Exercise 4 - Code Optimization
The code below describes a simple function in RISC-V assembly(A = B + E; C = B + F;).

```armasm
lw t1 , 0( t0)
lw t2 , 4( t0)
add t3 , t1 , t2
sw t3 , 12( t0)
lw t4 , 8( t0)
add t5 , t1 , t4
sw t5 , 16( t0)
```

### Exercise 4.1
Assume the above program will be executed on a 5-stage pipelined processor with forwarding and hazard detection. 
How many clock cycles will it take to correctly run this RISC-V code?

{% if site.solutions.show_session_8 %}
#### Solution

In this code, both `add` instructions will have to be stalled for one cycle. Both of them have a RAW dependency on a register value that is loaded from memory in the previous instruction. This value is only available in the MEM stage of the `lw` instruction, which runs in parallel with the EX stage of the `add` instruction. For this reason, the `add` instructions need to be stalled by one cycle, so that the correct register value can be forwarded to their EX stages.

|Inst |  1 |  2 |  3 |  4 |  5 |  6 |  7 |
|:---:|:--:|:--:|:--:|:--:|:--:|:--:|:--:|
|  lw | IF | ID | EX | ME | WB |    |    |
| add |    | IF | ID |XXXX| EX | ME | WB |

In total, this means that we have 5 cycles for the first instruction, 6 (1 each) for completing the additional instructions, and 2 due to the two stalls. `5 + 6 + 2 = 13`
{% endif %}

## Exercise 4.2
Reorganize the code to optimize the performance. (Hint: try to remove the stalls)

{% if site.solutions.show_session_8 %}
#### Solution

If we avoid using a register value in an instruction that is loaded from memory in the previous instruction (without changing the result of the program), we can eliminate the stalls.

```armasm
lw t1, 0(t0)
lw t2, 4(t0)
lw t4, 8(t0)
add t3, t1, t2
sw t3, 12(t0)
add t5, t1, t4
sw t5, 16(t0)
```

{% endif %}

## Exercise 5 - Branching
The code below describes a simple function in RISC-V assembly.

```armasm
      add x1 , x0 , x0
bar:
      bne x1 , x0 , exit
      bge x1 , x0 , foo
      addi x1 , x1 , -100
      add x5 , x5 , x5
      add x6 , x1 , x1
      sub x1 , x1 , x2
foo:
      addi x1 , x1 , 1
      jal x10 , bar
exit:
      xor x20 ,x21 ,x22
      nop
```

Fill out the following instruction/time diagram for the following set of instructions until the instruction on line 13 (xor) fully executes and commits.
Execution starts from line 1.

![Instruction time diagram](/exercises/8-microarchitecture/instruction-time-diagram.png){: .center-image }


{% if site.solutions.show_session_8 %}
#### Solution

In this exercise, we need to pay attention to branches and jumps. The processor does no prediction, so it continues executing instructions that follow the branch instruction. The program counter is updated in the EX stage of the branch instructions, so the fetching of the correct next instruction can only start after this stage finished executing. This means that after each branch that is taken, the processor starts executing two incorrect instructions. These executions need to be stopped, the pipeline is flushed after the program counter updates.

![Instruction time diagram](/exercises/8-microarchitecture/sol5.png){: .center-image }


{% endif %}

# General architectural awareness

## Loop fission
break a loop into multiple loops over the same index range
each new loop takes only part of the original loop's body
improve locality of reference for both data and code

<table>
<tr>
<th>example code</th>
<th>with loop fission</th>
</tr>
<tr>
<td>
{% highlight c %}
int i, a[100], b[100];
for (i = 0; i < 100; i++) {
   a[i] = 1;
   b[i] = 2;
}
{% endhighlight %}
</td>
<td>
{% highlight bash %}
int i, a[100], b[100];
for (i = 0; i < 100; i++) {
   a[i] = 1;
}
for (i = 0; i < 100; i++) {
   b[i] = 2;
}
{% endhighlight %}
</td>
</tr>
</table>

## Loop unrolling

Decreases # instructions
Less jumps/conditional branches
Better for pipeline
Might also perform worse due to micro-architecture!

<table>
<tr>
<th>example code</th>
<th>with loop unrolling</th>
</tr>
<tr>
<td>
{% highlight c %}
for (int i=0; i<N; i++)
{
   sum += data[i];
}
{% endhighlight %}
</td>
<td>
{% highlight c %}
/* assume N is a multiple of 4 */
for (int i=0; i<N; i+=4)
{
   sum1 += data[i+0];
   sum2 += data[i+1];
   sum3 += data[i+2];
   sum4 += data[i+3];
}
sum = sum1 + sum2 + sum3 + sum4;
{% endhighlight %}
</td>
</tr>
</table>

## Loop tiling