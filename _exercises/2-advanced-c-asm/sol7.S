.data
    array: .word 1, 2, 3, 4, 5
    num:   .word 0  # the number to multiply with
.globl main
.text
main:
    la a0, array        # a0 = array (address)
    addi t0, zero, 20   # t0 = 20 (5 * 4, the size of the array)
iterate:
    addi t0, t0, -4     # t0 = t0 - 4 (1 word = 4 bytes)
    add t1, t0, a0      # t1 = t0 + a0 (current element's address)
    lw t2, (t1)         # t2 = *t1
    lw t6, num          # t6 = the number to multiply with
    mv t4, zero         # t4 = 0
multloop:
    beqz t6, multend    # while (t6 != 0) {
    add t4, t4, t2      #     t4 = t4 + t2
    addi t6, t6, -1     #     t6 -= 1
    j multloop          # }

multend:
    sw t4, (t1)         # *t1 = t4
    bnez t0, iterate    # if (t0 != 0) { goto mult; }
