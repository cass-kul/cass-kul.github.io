.data
    number:  .word 5
.text
    lw t0, number        # t0 = *number;
    mv t1, t0            # t1 = t0;
loop:                    # do {
    addi t1, t1, -1      #     t1--;
    ble t1, zero, end    #     if (t1 <= 0) { goto end; }
    mul t0, t0, t1       #     t0 *= t1;
    j loop               # } while (true);
end: