.globl main
.data
	in1:	.word 	1, 2, 3, 4, 5
	in2:	.word	5, 4, 3, 2, 1
	out:	.space	20
	n:	.word	5

.text

#Takes in1 in a0, in2 in a1, out in a2 and n in a3
sum:
	beqz	a3, end		# Abort if n==0
	lw	t0, (a0)
	lw	t1, (a1)
	add	t0, t0, t1
	sw	t0, (a2)
	addi	a0, a0, 4
	addi	a1, a1, 4
	addi	a2, a2, 4		# Add 4 to $a 0-3
	addi	a3, a3, -1	# n--
	j	sum
end:	
	ret
main:
	la	a0, in1
	la	a1, in2
	la	a2, out
	la	t0, n			
	lw	a3, (t0)		# Prepare params
	jal	sum		# Call sum
