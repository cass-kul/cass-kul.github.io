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

## Exercise 3.1

In a pipelined processor, each pipeline stage executes for one clock cycle. This means that the clock cycle needs to be adjusted to accommodate the most time-consuming pipeline stage.

In a single-cycle design, the entire execution with all stages executes in one clock cycle. Naturally, the clock cycle then needs to be as long as the sum of all the stages.

```
+---+-----------+--------------+
|   | Pipelined | Single-cycle |
+---+-----------+--------------+
| a |   500ps   |    1650ps    |
| b |   200ps   |     800ps    |
+---+-----------+--------------+
```

## Exercise 3.2

The total latency of an instruction is the time it takes between when the instruction starts to be fetched until its results are written back into memory -- in other words, the sum of all stages of execution.

In a pipelined processor, this equals the cycle time multiplied with the number of pipeline stages. In a single-cycle processor, this is simply the cycle time, as all stages execute during one cycle.

```
+---+-----------+--------------+
|   | Pipelined | Single-cycle |
+---+-----------+--------------+
| a |  2500ps   |    1650ps    |
| b |  1000ps   |     800ps    |
+---+-----------+--------------+
```

## Exercise 3.3

As the cycle time is determined by the most time-consuming stage, this is the one that is worth splitting up. The new cycle time will be determined by the new longest stage.

a) Stage to split: MEM, new clock cycle time: 400ps

b) Stage to split: IF, new clock cycle time: 190ps

---

## Exercise 4.1

The cycle times of the single-cycle and the pipelined processor can be calculated as before, and they will be 600ps and 200ps, respectively.

In the multi-cycle organization, same as for the traditional pipelined design, the clock cycle is limited by the longest stage, so the cycle time of this processor is also minimum 200ps.

## Exercise 4.2

For the single-cycle and the pipelined design, all instructions take the same amount of time regardless of which stages are used during their execution. In the case of the single-cycle processor, this is 600ps (1 cycle), for the pipelined processor, it is 1000ps (5 cycles, each taking 200ps).

In the multi-cycle processor, register instructions don't use the MEM stage, which means they only have to pass through 4 pipeline stages (4 cycles), adding up to 800ps. For some instructions though, all of the stages are used, so in the worst case the execution takes 1000ps.

The single-cycle and the multi-cycle designs outperform the pipelined design in terms of instruction latency, but due to the parallel nature of the pipelined design, that one still performs much better in terms of instruction throughput. This is demonstrated by the following exercise.

## Exercise 4.3

From these figures, we can see how much more efficient the pipelined design is, even for shorter programs.

## Exercise 4.4

For the single-cycle design, the original program takes 3 cycles to execute, which is `3 * 600ps = 1800ps`. As every instruction takes 600ps to execute, adding the nop instructions would result in an additional `50 * 600ps = 30,000ps`.

In the multi-cycle system, the original program took 13 cycles, as the first two instructions need 4 cycles each, the third one needs all 5. This gives a total execution time of `13 * 200ps = 2600ps`. Nop instructions do not access the memory, so they execute for 4 cycles. This means that adding the 50 extra instructions would increase the execution time by `50 * 4 = 200` cycles, which equals `200 * 200ps = 40,000ps`.

For the pipelined processor, the first instruction takes 5 cycles to execute. During this time, the pipeline already starts executing the next instructions, and after the 5th cycle, one instruction finishes in every cycle. As a result, the example program finishes in 7 cycles, `7 * 200ps = 1400ps`. If we add 50 nop instructions, those extend the execution time with 50 cycles, as in each cycle one nop instruction will complete, resulting in an extra time of `50 * 200ps = 10,000ps`.

## Exercise 4.5

As there is no parallelism in single-cycle and multi-cycle processors, there are also no hazards. Instructions only start executing once the previous once have completely finished and their modifications have been carried out in memory or the register file.

In the pipelined design, changing the first instruction like this would create a read after write (RAW) dependency between the first and the second instructions, as the second one uses the `t1` register the first instruction writes to. The second instruction needs the correct value of `t1` in its EX stage, but by then the first instruction is only in its MEM stage, the register file has not been written yet. To avoid this hazard, the processor either has to stall the second instruction until the correct value is available in `t1` or set up data forwarding between the pipeline registers.

---

## Exercise 5.1

```armasm
or t1, t2, t3  (1)
or t2, t1, t4  (2)
or t1, t1, t2  (3)
```

- Both (2) and (3) read `t1` after (1) writes it (RAW)
- (3) reads `t2` after (2) writes it (RAW)
- (2) writes `t2` after (1) reads it (WAR)
- (3) writes `t1` after (2) reads it (WAR)
- (3) writes `t1` after (1) writes it (WAW)

## Exercise 5.2

WAR and WAW dependencies do not cause hazards in the pipeline; it does not matter what the value of the register is when it is being written.

RAW dependencies cause hazards for two instructions that follow the instruction that writes the value.

```
   1    2    3    4    5    6    7    8
+----+----+----+----+----+----+----+----+
| IF | ID | EX | ME | WB |    |    |    | (1)
|    | IF | ID | EX | ME | WB |    |    | (2)
|    |    | IF | ID | EX | ME | WB |    | (3)
|    |    |    | IF | ID | EX | ME | WB | (4)
+----+----+----+----+----+----+----+----+
```

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

## Exercise 5.3

With full forwarding, register values that are calculated in the EX stage can be forwarded to the following instruction's EX stage, which eliminates the hazards in this code. This means that we don't need to add any nop instructions.

The execution time for this program is 7 cycles, 5 to execute the first instruction and 2 to finish the other two. With the increased cycle time, this amounts to `7 * 300ps = 2100ps`.

Without forwarding, we are forced to add the 4 nop instructions, which adds 4 additional cycles to the execution time. Even with the shorter cycle times, this is `(7+4) * 250ps = 2750ps`, which is 1.3 times longer than with full forwarding.

---

## Exercise 6.1

In this code, both `add` instructions will have to be stalled for one cycle. Both of them have a RAW dependency on a register value that is loaded from memory in the previous instruction. This value is only available in the MEM stage of the `lw` instruction, which runs in parallel with the EX stage of the `add` instruction. For this reason, the `add` instructions need to be stalled by one cycle, so that the correct register value can be forwarded to their EX stages.

```
+-----++----+----+----+----+----+----+----+
|  lw || IF | ID | EX | ME | WB |    |    |
| add ||    | IF | ID |XXXX| EX | ME | WB |
+-----++----+----+----+----+----+----+----+
```

In total, this means that we have 5 cycles for the first instruction, 6 (1 each) for completing the additional instructions, and 2 due to the two stalls. `5 + 6 + 2 = 13`

## Exercise 6.2

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

---

## Exercise 7.1

In this exercise, we need to pay attention to branches and jumps. The processor does no prediction, so it continues executing instructions that follow the branch instruction. The program counter is updated in the EX stage of the branch instructions, so the fetching of the correct next instruction can only start after this stage finished executing. This means that after each branch that is taken, the processor starts executing two incorrect instructions. These executions need to be stopped, the pipeline is flushed after the program counter updates.
