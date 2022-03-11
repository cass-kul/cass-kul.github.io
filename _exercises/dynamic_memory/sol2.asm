.data
a: .string "abcd"
b: .string "abcd"

.globl main
.text
streq:
	lb t0, (a0)
	lb t1, (a1)
	beq t0, t1, loop
	li a0, 0 			#return 0
	ret
loop:
	beqz t0, ret1
	addi a0, a0, 1
	addi a1, a1, 1
	j streq
ret1:
	li a0, 1			#return 1
	ret
	
main:
	la a0, a
	la a1, b
	jal streq