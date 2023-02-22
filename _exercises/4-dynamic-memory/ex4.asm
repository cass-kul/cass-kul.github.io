allocate_stack:
    mv t0, a0
    mv a0, sp
    sub sp, sp, t0
    ret
