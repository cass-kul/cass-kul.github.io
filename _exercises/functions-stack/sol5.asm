.globl main

fact_tail:
    # if (n < 2)
    slti	t0, a0, 2       # Set t0 to 1 if a0 (n) < 2
    beqz	t0, _recurse    # Branch to _recurse if a0 > 1 (because then t0 would be 0 now)
    
    # return result;
    mv a0, a1
    ret
    
_recurse:
    #fact_tail(n - 1, n * result);
    mul 	a1, a0, a1  # a1 = n * result
    addi	a0, a0, -1  # a0 = n - 1
    j	fact_tail       # a0 = fact_tail(n - 1, n * result)
        # Note: NO JAL here -> ra is not overwritten
        # We don't need to use jal since there is no code to be executed after the tail call!
        # Thus no need to back-up ra on the stack at all.
    
fact:
    li 	a1, 1
    addi sp, sp, -4
    sw	ra, 0(sp)
    jal 	fact_tail
    lw	ra, 0(sp)
    addi	sp, sp, 4
    ret
    
main:
    li	a0, 5   # Input will be 5
    jal	fact    # a0 = fact(5);
    
