.data
    x: .word 1
    y: .word 2
    z: .space 4
.globl main
.text
foo:
    add a0, a0, a1
    ret

bar:
    addi sp, sp, -4
    sw   ra, 0(sp)
    jal  foo
    lw   ra, 0(sp)
    addi sp, sp, 4
    ret

main:
    lw  a0, x
    lw  a1, y
    jal bar
    sw  a0, z, t0
