.data
    x: .word 0x10
    y: .word 0x20
    z: .space 4

.text

.globl main
doubleIt:
    # No need to execute the entire prologue/epilogue
    # For such simple functions
    add a0, a0, a0
    ret
sum:
    addi sp, sp, -8 # Make space for 2 words on the stack
    sw ra, 4(sp)    # Save the return address
    sw a0, 0(sp)    # Save the first argument a0 because of doubleIt call

    mv a0, a1       # b (currently in a1) is our input. Move it to a0 for doubleIt.
    jal doubleIt

    lw t0, 0(sp)    # Restore the saved argument (a) to t0
    add a0, t0, a0  # Add a (t0) to the result of doubleIt (a0)

    lw ra, 4(sp)    # Restore the return address
    addi sp, sp, 8  # Restore stack pointer
    ret
main:
    lw a0, x
    lw a1, y
    jal sum
    sw a0, z, t0
