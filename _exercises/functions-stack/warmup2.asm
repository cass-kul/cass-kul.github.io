.globl main
.data
    a: .word 1
    b: .word 2
    number:  .word 0

.text
main:
    # Load the two numbers a and b into registers
	la a0, a
	la a1, b

sum:
    # Add the two numbers and put them in a register for main to find.
	add a0, a0, a1

resume:
    la t6, number
    sw a0, 0(t6)
