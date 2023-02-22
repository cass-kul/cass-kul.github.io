.data
    a: .word 3
    b: .word 4
    c: .space 4
.text
    lw t0, a          # t0 = *a;
    lw t1, b          # t1 = *b;
    la a2, c          # a2 = c;
    mul t0, t0, t0    # t0 = t0 * t0;
    mul t1, t1, t1    # t1 = t1 * t1;
    add t2, t0, t1    # t2 = t0 + t1;
    sw t2, (a2)       # *a2 = t2;
