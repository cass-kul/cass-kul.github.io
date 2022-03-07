.data
    operation: .word 3  # change this between 0-3
    a:         .word 5
    b:         .word 1
.globl main
.text
main:
    lw t0, operation    # t0 = operation
    lw t1, a            # t1 = a
    lw t2, b            # t2 = b
    mv t3, zero         # t3: used to compare to t0
    beq t0, t3, case0   # if t0 == t3: go to case 0
    addi t3, t3, 1      # t3 += 1
    beq t0, t3, case1
    addi t3, t3, 1
    beq t0, t3, case2
    addi t3, t3, 1
    beq t0, t3, case3
    j end               # if none of the cases matched
                        # don't do anything (jump over cases)
case0:
    add a0, t1, t2
    j end               # jump to the end after each individual case
case1:
    sub a0, t1, t2
    j end
case2:
    addi a0, t1, 5
    j end
case3:
    addi a0, t2, 5
    j end

end:
