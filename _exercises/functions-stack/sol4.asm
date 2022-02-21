.globl main

fact:
    addi sp, sp, -8   # Make space for 2 words on the stack
    sw   ra, 4(sp)    # Store the (caller-save) return address
    sw   a0, 0(sp)    # Store the (caller-save) register a0

    # if (n < 2)
    slti t0, a0, 2    # Set t0 to 1 if a0 (n) < 2
    beqz t0, _recurse # Branch to _recurse if a0 > 1 (because then t0 would be 0 now)

    # return 1;
    li   a0, 1        # Return 1 if a0 <= 1
    addi sp, sp, 8    # Free 2 words of space on stack
    ret

_recurse:
    #fact(n-1)
    addi a0, a0, -1   # Decrement $a0
    jal  fact         # Execute fact

    mv   t0, a0       # Move fact(n-1) result to t0
    lw   a0, 0(sp)    # Restore initial a0 (old n value)
    lw   ra, 4(sp)    # Restore initial ra
    addi sp, sp, 8    # Free 2 words of space on stack

    #n*fact(n-1);
    mul  a0, a0, t0   # a0 = a0 (n) * t0 (fact(n-1))
    ret               # return n * fact(n-1)

main:
    li  a0, 5         # Input will be 5
    jal fact          # a0 = fact(5);

