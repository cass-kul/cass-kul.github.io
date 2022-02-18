.data
    a: .word 2
    b: .word 1
    c: .space 4
.text
    lw t0, a            # t0 = *a;
    lw t1, b            # t1 = *b;
    la a2, c            # a2 = c;
    addi t2, zero, 1    # t2 = 1;
loop:
    beqz t1, end        # while (t1 != 0) {
    mul t2, t2, t0      #     t2 = t2 * t0;
    addi t1, t1, -1     #     t1--;
    j loop              # }
end:
    sw t2, (a2)         # *a2 = t2;